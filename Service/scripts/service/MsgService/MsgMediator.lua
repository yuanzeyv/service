require "Tool.Class"  
local netpack = require "skynet.netpack"
local skynet = require "skynet"
local crypt = require "skynet.crypt"
local socketdriver = require "skynet.socketdriver"  
local MsgExecuteFinal = require "MsgService.MsgExecuteFinal" 
local b64encode = crypt.base64encode
local b64decode = crypt.base64decode
local MsgMediator = class("MsgMediator")   
function MsgMediator:GetUserName(uid, subid)
	return string.format("%s@%s#%s", b64encode(uid), b64encode(self._MsgServiceObj:GetName()), b64encode(tostring(subid)))
end

function MsgMediator:GetIp(username)
	local u = self._userOnline[username]
	if u and u.fd then
		return u.ip
	end
end

function MsgMediator:Logout(username)
	local u = self._userOnline[username]--首先查询当前对应用户名的用户
	self._userOnline[username] = nil --设置为空
	if u.fd then--如果拥有fd
		self._MsgServiceObj:Closeclient(u.fd)--关闭这个客户端连接
		self._connection[u.fd] = nil--设置连接为空
	end
end

function MsgMediator:Login(username)
	assert(self._userOnline[username] == nil)--如果没有查询到用户在线信息
	self._userOnline[username] = {--设置用户在线  
		username = username, 
		fd =  nil,
		ip =  nil,
	}
end

function MsgMediator:Write(username,msg)--写一个数据
	local u = self._userOnline[username] --如果当前用户在线的话
	if not u.fd then--拥有fd
		return 
	end  
	self._MsgServiceObj:WriteClient(u.fd,string.pack(">I2",#msg) .. msg ) --写数据
end

function MsgMediator:Command_Login(uid) --login校验成功后，会调用登录命令 uid为用户账号
	return self._MsgExecuteObj:LoginHandler(uid)
end 
function MsgMediator:Command_Write(username,msg) 
	self._MsgExecuteObj:WriteHandler(username,msg)
end 
function MsgMediator:Command_Logout(uid, subid) 
	self._MsgExecuteObj:LogoutHandler(uid, subid)
end 
function MsgMediator:Command_Kick(uid, subid) 
	self._MsgExecuteObj:KickHandler(uid, subid)
end 

function MsgMediator:FindCommand(key)
	return self._command[key]
end 

function MsgMediator:GetCMDList()
	local CMD = {}
	CMD.login = handler(self,MsgMediator.Command_Login)  
	CMD.write = handler(self,MsgMediator.Command_Write)  
	CMD.logout = handler(self,MsgMediator.Command_Logout)
	CMD.kick =  handler(self,MsgMediator.Command_Kick)   
	return CMD
end

function MsgMediator:DoRequest(fd, message)
	local u = assert(self._connection[fd], "无效的套接字 用户可能已经断开了连接")   
	local ret , result = pcall(MsgExecuteFinal.RequestHandler,self._MsgServiceObj, u.username, message) 
	if not ret then 
		print(result..":message dispos error fd:"..fd)
	end  
end

function MsgMediator:Request(fd, msg, sz)
	local message = netpack.tostring(msg, sz) 
	local ok, err = pcall(self.DoRequest,self,fd, message)
	-- not atomic, may yield
	if not ok then
		skynet.error(string.format("Invalid package %s : %s", err, message))  
		if self._connection[fd] then
			self._GateserverWr.closeclient(fd)
		end
	end
end

function MsgMediator:DoAuth(fd, message, addr)
	local username, index = string.match(message, "([^:]*):([^:]*)") --获取到用户名称
	index = tonumber(index)--这个index可用用来校验是否登录成功 目前不用
	assert(index,"400 Bad Request") 
	local u = self._userOnline[username] 
	assert(u ,"404 User Not Found")     
	u.fd = fd
	u.ip = addr
	self._connection[fd] = u
	return "200 OK" 
end 

function MsgMediator:Auth(fd, addr, msg, sz)
	local message = netpack.tostring(msg, sz)--解析当前的网络包
	local ok, result = pcall(self.DoAuth,self, fd, message, addr)  --调用解析
	if not ok then 
		skynet.error(result)--输出错误日志  
		self._MsgServiceObj:CloseClient(fd)--验证失败关闭连接
	end  
end

function MsgMediator:MessageDispose(fd, msg, sz) --如果收到了消息
	local addr = self._handshake[fd]--首先判断当前是否已经连接了
	if addr then--如果当前需要验证的话
		self:Auth(fd,addr,msg,sz)--开始验证
		self._handshake[fd] = nil
	else   
		self:Request(fd, msg, sz)
	end
end

function MsgMediator:OpenListenHandle(source)
	local servername = self._MsgServiceObj:GetName()  --调用上一级的 注册服务
    skynet.call(self:GetLoginHandle(), "lua", "register_gate", servername, skynet.self())--调用loginService的注册消息，同样注册一下
	return self._MsgExecuteObj:RegisterHandler(servername)
end 
function MsgMediator:CloseListenHandle(source) 
	local servername = self._MsgServiceObj:GetName()  --调用上一级的 注册服务
	return self._MsgExecuteObj:UnregisterHandler(servername)
end  
function MsgMediator:ConnectDispose(fd, addr)
	self._handshake [fd] = addr --连接会把握手给打开
	self._MsgServiceObj:Openclient(fd)--并且打开客户端
end 

function MsgMediator:DisconnectDispose(fd) 
	self._handshake[fd] = nil --设置当前握手
	local c = self._connection[fd] --获取到连接信息
	if c then--如果当前拥有连接信息的话
		self._connection[fd] = nil 
		self._MsgExecuteObj:DisconnectHandler(c.username) 
	end
end
function MsgMediator:ErrorDispose (fd)
	self._handshake[fd] = nil --设置当前握手
	local c = self._connection[fd] --获取到连接信息
	if c then--如果当前拥有连接信息的话
		self._connection[fd] = nil 
		self._MsgExecuteObj:ErrorHandler(c.username) 
	end
end
function MsgMediator:WarningDispose (fd)
	skynet.error("fd:"..fd .."generate warning")
end
 

function MsgMediator:ctor(conf)  
	self:InitServerData(conf)  
end  
function MsgMediator:SetLoginHandle(loginServer)
	self._loginservice = loginServer
end 
function MsgMediator:GetLoginHandle()
	return self._loginservice
end 
function MsgMediator:InitServerData(msgServiceObj) 
	self._MsgServiceObj = assert(msgServiceObj,"not msgServiceObj")--主服务对象
	self._MsgExecuteObj = MsgExecuteFinal.new(self)
	self._command = self:GetCMDList()  
 
	self._loginservice = nil
	self._userOnline = {}--用户在线列表
	self._handshake = {}--用户握手列表
	self._connection = {}--用户连接列表 
end 
return MsgMediator 