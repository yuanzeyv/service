
local netpack = require "skynet.netpack"
local skynet = require "skynet"
local crypt = require "skynet.crypt"
local socketdriver = require "skynet.socketdriver" 
local GateServer = require "MsgService.MsgServiceCore" 
local b64encode = crypt.base64encode
local b64decode = crypt.base64decode
require "Tool.Class"  
local MsgMediator = class("MsgMediator")       

function MsgMediator:GetUserId(username) 
	local uid, servername, subid = username:match "([^@]*)@([^#]*)#(.*)"
	return b64decode(uid), b64decode(subid), b64decode(servername)
end

function MsgMediator:GetUserName(uid, subid, servername)
	return string.format("%s@%s#%s", b64encode(uid), b64encode(servername), b64encode(tostring(subid)))
end

function MsgMediator:GetIp(username)
	local u = self._userOnline[username]
	if u and u.fd then
		return u.ip
	end
end

function MsgMediator:Logout(username)
	local u = self._userOnline[username]
	self._userOnline[username] = nil
	if u.fd then
		self._Gateserver:Closeclient(u.fd)
		self._connection[u.fd] = nil
	end
end

function MsgMediator:Login(username)
	assert(self._userOnline[username] == nil)--以base64转码的ID如果存在问题的haunt
	self._userOnline[username] = { 
		version = 0, 
		username = username, 
		fd =  nil,
		ip =  nil,
	}
end

function MsgMediator:Write(username,msg)
	local u = self._userOnline[username]  
	if u.fd then 
		self._Gateserver:WriteClient(u.fd,string.pack(">I2",#msg) .. msg ) 
	end
end

function MsgMediator:GetCMDList()
	local CMD = {}
	CMD.login = self._config.login_handler 
	CMD.write = self._config.write_handler 
	CMD.logout = self._config.logout_handler
	CMD.kick =  self._config.kick_handler
	return CMD
end

function MsgMediator:DoRequest(fd, message)
	local u = assert(self._connection[fd], "无效的套接字 用户可能已经断开了连接")  
	local ret , result = pcall(self._config.request_handler, u.username, message) 
end

function MsgMediator:Request(fd, msg, sz)
	local message = netpack.tostring(msg, sz) 
	local ok, err = pcall(self.DoRequest,self,fd, message)
	-- not atomic, may yield
	if not ok then
		printf("Invalid package %s : %s", err, message)
		if self._connection[fd] then
			self._GateserverWr.closeclient(fd)
		end
	end
end

function MsgMediator:DoAuth(fd, message, addr)
	local username, index = string.match(message, "([^:]*):([^:]*)")  
	index = tonumber(index)
	assert(index,"400 Bad Request") 
	local u = self._userOnline[username] 
	assert(u ,"404 User Not Found")    
	assert(index > u.version,"403 Index Expired")    
	u.version = index
	u.fd = fd
	u.ip = addr
	self._connection[fd] = u
	return "200 OK" 
end 

function MsgMediator:Auth(fd, addr, msg, sz)
	local message = netpack.tostring(msg, sz)
	local ok, result = pcall(self.DoAuth,self, fd, message, addr)  
	if not ok then 
		skynet.error(result)--输出错误日志  
	end
	--socketdriver.send(fd, netpack.pack(result)) 
	if not ok then
		self._Gateserver:Closeclient(fd)
	end
end

function MsgMediator:GetHandleList()
	local handlerList = {} 
	handlerList.command = function (cmd, source, ...) 
		local b = ... 
		local f = assert(self._command[cmd]) 
		return f(...)
	end
	handlerList.open = function(source, gateconf)
		local servername = assert(gateconf.servername)  --调用上一级的 注册服务
		return self._config.register_handler(servername)
	end 
	handlerList.connect = function (fd, addr)
		self._handshake [fd] = addr --连接会把握手给打开
		self._Gateserver:Openclient(fd)--并且打开客户端
	end 
	handlerList.disconnect = function(fd)
		self._handshake [fd] = nil
		local c = self._connection[fd]
		if c then
			c.fd = nil
			self._connection[fd] = nil
			if self._config.disconnect_handler then
				self._config.disconnect_handler(c.username)
			end
		end
	end
	handlerList.error = handlerList.disconnect
	handlerList.message = function (fd, msg, sz)
		local addr = self._handshake[fd]
		if addr then
			self:Auth(fd,addr,msg,sz)
			self._handshake[fd] = nil
		else   
			self:Request(fd, msg, sz)
		end
	end
	return handlerList;
end

function MsgMediator:ctor(conf)  
	self:InitServerData(conf)  
end  

function MsgMediator:InitServerData(conf)
	assert(conf.login_handler,"没有设置登录回调 ")
	assert(conf.logout_handler,"没有设置登出回调")
	assert(conf.kick_handler,"没有设置踢人回调")
	assert(conf.request_handler,"没有设置请求回调") 
	self._Gateserver = GateServer.new(self:GetHandleList())
	self._config = conf
	self._command = self:GetCMDList()  

	self._expired_number = nil--最大接收消息数
	self._userOnline = {}--用户在线列表
	self._handshake = {}--用户握手列表
	self._connection = {}--用户连接列表 
end 
  
return MsgMediator 