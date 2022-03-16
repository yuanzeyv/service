require "Tool.Class"
require "skynet.manager"
local skynet = require "skynet"
local socket = require "skynet.socket"
local crypt = require "skynet.crypt"  
local LoginSalveServer = class("LoginSalveServer") 
--[[ Protocol: 
	line (\n) based text protocol

	1. Server->Client : base64(8bytes random challenge)
	2. Client->Server : base64(8bytes handshake client key)
	3. Server: Gen a 8bytes handshake server key
	4. Server->Client : base64(DH-Exchange(server key))
	5. Server/Client secret := DH-Secret(client key/server key)
	6. Client->Server : base64(HMAC(challenge, secret))
	7. Client->Server : DES(secret, base64(token))
	8. Server : call auth_handler(token) -> server, uid (A user defined method)
	9. Server : call login_handler(server, uid, secret) ->subid (A user defined method)
	10. Server->Client : 200 base64(subid)
Success:
	200 base64(subid)]]
local socket_error = {} 
function LoginSalveServer:AssertSocket(service, v, fd)
	if v then return v end
	skynet.error(string.format("%s failed: socket(fd = %d) closed", service, fd))
	error(socket_error)
end

function LoginSalveServer:Auth(fd, addr) 
	socket.limit(fd, 8192)
	local userInfo = self:AssertSocket("auth",socket.readline(fd),fd)
	local userInfoEncode = crypt.base64decode(userInfo)
	local ok, server, uid =  pcall(self._authHandler,userInfoEncode)
	return ok, server, uid
end

function LoginSalveServer:RetPack(ok, err, ...)
	if ok then 
		return skynet.pack(err, ...) 
	end  
	if err == socket_error then
		return skynet.pack(nil, "socket error")
	else
		return skynet.pack(false, err)
	end
end

function LoginSalveServer:AuthFd(fd, addr)
	skynet.error(string.format("connect from %s (fd = %d)", addr, fd))
	socket.start(fd)
	local msg,len = self:RetPack(pcall(self.Auth,self, fd, addr))
	socket.abandon(fd)
	return msg, len
end

function LoginSalveServer:ctor(conf) 
	self:InitServerData(conf);
	self:InitServer();
end 

function LoginSalveServer:InitServerData(conf) 
	assert(conf.auth_handler,"未实现登录验证")
	self._authHandler = conf.auth_handler 
end

function LoginSalveServer:LaunchSlave()
	skynet.dispatch("lua", function(_,_,...) 
		local ok, msg, len = pcall(self.AuthFd,self,...)
		if ok then
			skynet.ret(msg,len)
		else
			skynet.ret(skynet.pack(false, msg))
		end
	end)
end

function LoginSalveServer:InitServer()  
	skynet.start(function()  
		self:LaunchSlave()  
	end)  
end

return LoginSalveServer