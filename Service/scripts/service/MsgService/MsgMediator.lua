local MsgExecuteFinal = require "MsgService.MsgExecuteFinal" 
local netpack = require "skynet.netpack"
local crypt = require "skynet.crypt" 
local ConnectObj = require "MsgService.ConnectObj.ConnectObj" 
local b64encode = crypt.base64encode
local b64decode = crypt.base64decode
local MsgMediator = class("MsgMediator")   
function MsgMediator:GetUserName(uid, subid)--根据用户名称 客户端记录的subid 和 服务名称组合为一个专属名称
	return string.format("%s@%s#%s", b64encode(uid), b64encode(self._MsgServiceObj:GateWayNameName()), b64encode(tostring(subid)))
end

function MsgMediator:CleanUserNetInfo(username)--清除登录用户的连接状态
	local u = self._userOnline[username]
	if not u then return end	
	u.fd =  nil 
end   
--角色成功创建爱你之后
function MsgMediator:Login(username) 
	assert(not self._userOnline[username],"用户已经登录了")--如果当前用户已经登录过了的话,
	self._userOnline[username] = {}--设置用户在线  
	self._userOnline[username].username = username
	self._userOnline[username].fd = nil 
end
 
function MsgMediator:Write(username,msg)--写一个数据
	local u = self._userOnline[username] --如果当前用户在线的话
	if not u.fd then return end  
	self._MsgServiceObj:WriteClient(u.fd,string.pack(">I2",#msg) .. msg ) --写数据
end

function MsgMediator:Command_Login(source,uid) --login校验成功后，会调用登录命令 uid为用户账号 
	local subid = self._MsgExecuteObj:LoginHandler(uid) 
	return subid --登录会返回一个subid 用于登录防护
end 
function MsgMediator:Command_Write(source,username,msg) 
	self._MsgExecuteObj:WriteHandler(username,msg)
end 
function MsgMediator:Command_Logout(source,username) 
	local userInfo = assert(self._userOnline[username],"用户当前不在线")--如果当前连接用户不存在的话  
	if userInfo.fd then  
		self._MsgServiceObj:CloseClient(userInfo.fd)--主动登出
	end 
end 
function MsgMediator:Command_Kick(source,username)
	self._MsgExecuteObj:KickHandler(username)
end  

--真正当一个用户彻底退出后，会执行清除登录用户的步骤
function MsgMediator:Command_CleanUser(source,username)  
	if self._userOnline[username].fd or self._userOnline[username] .ip then--真到这一步了，早就断网了
		print("当前程序出现了 一个 奇怪的错误")
	end 
	self:CleanUserNetInfo()  
	self._userOnline[username]  = nil   --清数据
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
	CMD.cleanUser = handler(self,MsgMediator.Command_CleanUser)     --清除登录信息（一个agent完全退出后，本次的登录就全部结束了，需要将agent所关联的事物给清除）
	return CMD
end
--处理消息派发请求
function MsgMediator:DoRequest(fd, message)
	local u = assert(self._netConnection[fd], "无效的套接字 用户可能已经断开了连接")    
	local ret , result = pcall(MsgExecuteFinal.RequestHandler,self._MsgExecuteObj, u:GetUserName(), message) 
	if not ret then skynet.error(result..":message dispos error fd:"..fd) end  
end

function MsgMediator:Request(fd, msg, sz)
	local message = netpack.tostring(msg, sz)  
	local ok, err = pcall(self.DoRequest,self,fd, message)
	if not ok then
		skynet.error(string.format("Invalid package %s : %s", err, message))   
	end
end

function MsgMediator:DoAuth(fd, message, addr)
	local username, index = string.match(message, "([^:]*):([^:]*)") --获取到用户名称 
	index = tonumber(index)--这个index可用用来校验是否登录成功 目前不用
	if not index then return G_ErrorConf.ConnectServerIndexError end  
	local u = self._userOnline[username] 
	if not u then  return G_ErrorConf.UserNotLoggedIn end  --用户未登入
	--如何考虑挤人的情况呢？
	if u.fd then--如果当前有用户登入的话
		skynet.error("这里本不该进入")
		self._MsgExecuteObj:ExtrudeOffline(username)--退出之前的用户
	end
	u.fd = fd 
	self._netConnection[fd]:SetDisposeObj(self.Request,self) 
	self._netConnection[fd]:SetUserInfo(u)   
	self._MsgExecuteObj:AuthSuccess(username) --连接新用户
	return G_ErrorConf.ExecuteSuccess --验证成功
end 

function MsgMediator:Auth(fd, msg, sz)--(还应该加入一个 20秒不验证，关闭当前连接 )
	local message = netpack.tostring(msg, sz)--解析当前的网络包
	result = self:DoAuth(fd,message) 
	if result ~= G_ErrorConf.ExecuteSuccess then 
		skynet.error(fd .. " Auth Result:" .. result)--输出错误日志  
		self._MsgServiceObj:CloseClient(fd)--验证失败关闭套接字
		return
	end 
end    

function MsgMediator:OpenGateWayHandle(source)
	local servername = self._MsgServiceObj:GateWayNameName()  --调用上一级的 注册服务
    skynet.call(self:GetLoginHandle(), "lua", "register_gate", servername, skynet.self())--调用loginService的注册消息，同样注册一下
	return self._MsgExecuteObj:OpenGateWayHandle(servername)
end 
function MsgMediator:CloseGateWayHandle(source)--关闭监听的情况下
	local servername = self._MsgServiceObj:GateWayNameName() 
	return self._MsgExecuteObj:CloseGateWayHandle(servername)
end             

function MsgMediator:MessageDispose(fd, msg, sz)
	local netObj = self._netConnection[fd]
	if netObj then 
		netObj:ExecuteHandle(fd,msg,sz)
	else
		skynet.error("正准备执行一个错误的 网络套接字" ,fd ) 
		self._MsgServiceObj:CloseClient(fd)
	end  
end  

function MsgMediator:SocketOpenHandle(fd, addr)--打开 
	self._netConnection[fd] = ConnectObj.new(fd,addr)
	self._netConnection[fd]:SetDisposeObj(self.Auth,self) --设置处理函数 
	self._MsgServiceObj:Openclient(fd)
end 

function MsgMediator:SocketCloseHandle(fd)--我要确认,他是原子操作
	skynet.error(string.format("(%d)对应的套接字，进入了SocketClose,将清除连接信息",fd))  
	local netInfo = assert(self._netConnection[fd],"连接信息不存在")
	local username = netInfo:GetUserName()  
	if username then--断网回调
		self:CleanUserNetInfo(username)--清除用户的网络连接数据 
		self._netConnection[fd] = nil --删除连接状态信息
		self._MsgExecuteObj:DisconnectHandler(username)
	end   
end

function MsgMediator:SocketErrorHandle (fd,msg) --错误的消息处理 
	skynet.error(string.format("(%d)对应的套接字，进入了SocketError,程序即将退出socket",fd) )   
	local netInfo = self._netConnection[fd] --有可能很久之前就退出了，但是却没有完全退出，之后就会给我发一个error
	if netInfo then--断网回调 
		self._MsgExecuteObj:ErrorHandler(netInfo:GetUserName() )
	else 
	end 
end

function MsgMediator:SocketWarningHandle(fd)
	skynet.error("enter WarningDispose" .. fd)  
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
	self._userOnline = {} --userOnline 和 登录 验证列表是独立的。 
	self._netConnection = {}  
end 
return MsgMediator 