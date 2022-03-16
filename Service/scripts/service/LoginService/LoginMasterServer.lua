require "Tool.Class"
require "skynet.manager"
local skynet = require "skynet"
local socket = require "skynet.socket"
local crypt = require "skynet.crypt"  
local LoginMasterServer = class("LoginMasterServer")  
--[[Error Code:
	401 Unauthorized . unauthorized by auth_handler
	403 Forbidden . login_handler failed
	406 Not Acceptable . already in login (disallow multi login) 
Success:
	200 base64(subid)]]  
local socket_error = {} 
function LoginMasterServer:ctor(conf) 
	self:InitServerData(conf) 
	self:InitServer()  
end

function LoginMasterServer:InitServerData(conf)  
	assert(conf.login_handler,"没有实现登录回调")
	assert(conf.command_handler,"没有实现命令回调") 
	assert(conf.port,"没有填写端口信息")
	assert(not conf.instance or conf.instance <= 0,"协助服务数目错误")
	assert(conf.name ,"未设置名称") 
	self._conf = conf 
	self._host = conf.host or "0.0.0.0"
	self._instanceNum = conf.instance or 8
	self._port = tonumber(conf.port)
	self._name = conf.name

	self._userLogin = {} 
	self._slave = {}
	self._chooseSlaveIndex = 0 
end   

function LoginMasterServer:InitServer()
	skynet.start(function()   
		self:MasterInit() 
	end)
end 

local function assert_socket(service, v, fd)
	if v then return v end 
	skynet.error(string.format("%s failed: socket (fd = %d) closed", service, fd))
	error(socket_error)
end

function LoginMasterServer:Write(service, fd, text)
	assert_socket(service, socket.write(fd, text), fd)
end 

function LoginMasterServer:Accept(fd,addr)   
	local slave = self:GetNextSlave()
	local ok, server, uid = skynet.call(slave, "lua",fd, addr)--开始验证
	if not ok then
		if ok ~= nil then
			self:Write("response 401", fd, "401 Unauthorized\n") 
		end
		error(server)
	end 
	if not self._conf.multilogin then
		if self._userLogin[uid] then
			self:Write("response 406", fd, "406 Not Acceptable\n")
			error(string.format("User %s is already login", uid))
		end
		self._userLogin[uid] = true
	end 
	local ok, err = pcall(self._conf.login_handler, server, uid, secret ) 
	self._userLogin[uid] = nil
	if ok then
		err = err or ""
		self:Write("response 200",fd,  "200 "..crypt.base64encode(err).."\n")
	else
		self:Write("response 403",fd,  "403 Forbidden\n")
		error(err)
	end
end  

function LoginMasterServer:CreateSlaveServer() 
	for i=1,self._instanceNum do  
		table.insert(self._slave, skynet.newservice(SERVICE_NAME,self._port,self._name))
	end 
end

function LoginMasterServer:GetNextSlave()
	local index = (self._chooseSlaveIndex % self._instanceNum) + 1
	self._chooseSlaveIndex = self._chooseSlaveIndex+1
	return self._slave[index]
end 

function LoginMasterServer:MasterInit()
	skynet.register(self._name)
	self:CreateSlaveServer()
	skynet.dispatch("lua", function  (_,source,command, ...)
		skynet.ret(skynet.pack(self._conf.command_handler(command, ...)))
	end)  
	local fd = socket.listen(self._host , self._port)
	socket.start(fd ,function(fd, addr)
		local ok, err = pcall(self.Accept,self,fd,addr)
		if not ok and err ~= socket_error then 
			skynet.error(string.format("invalid client (fd = %d) error = %s", fd, err)) 
		end 
		socket.close_fd(fd)
	end) 
end  
return  LoginMasterServer