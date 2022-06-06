local Service = require "Service" 
local MsgService = class("MsgService",Service)     
local GateWayControl = require "MsgService.GateWayControl"     
local AgentObj =  require "MsgService.AgentObj.AgentObj" 
local netpack = require "skynet.netpack"  
function MsgService:Command_OpenGateWay(source,conf)--开始执行服务
	assert(not self.GateWayControlObj,"当前路由器已经被注册")--如果当前已经注册的话
	self._login  = assert(conf.login,"未传入要登录的 登录服务器")--当前要登入的服务器
	self.GateWayControlObj = GateWayControl.new(conf,self)--创建一个新的网络控制器
    skynet.call(self:GetLoginHandle(), "lua", "register_gate", self:GateWayName(),skynet.self())--向登录服务器注册当前的消息服务器
end  
--关闭完全后，关闭服务器
function MsgService:Command_CloseGateWay(source) 
	assert( self.GateWayControlObj,"试图关闭一个 空的路由节点")
	self.GateWayControlObj:CloseGateWay()--关闭当前的服务器
	self.GateWayControlObj = nil   
    skynet.call(self:GetLoginHandle(), "lua", "unregister_gate", self:GateWayName() )--调用loginService的注册消息，同样注册一下 
end 

function MsgService:Command_Login(source,uid)
    skynet.error("用户:".. uid .." 正在登入网关服务器")--输出用户登入 
    if self._AgentList[uid] then--如果用户已经登入的话
        skynet.call( userInfo:GetHandle(),"lua","logout") --T掉上一个FD的连接
        return self._AgentList[uid]:GetSUBID() --获取到其 minor ID
    end   
	self._AgentList[uid] = AgentObj.new(uid,self:AllocAgentMinorId()) --生成一个用户对象  
    return self._AgentList[uid]:GetSUBID()  
end 
function MsgService:Command_Write(source,uid,msg) 
	print("HHAHAHA",uid)  
	local userInfo = assert(self._AgentList[uid],"未寻找到指定的端口信息")--获取到用户登录的信息
	self.GateWayControlObj:WriteHandler(userInfo:GetScoket(),msg)
end 
function MsgService:Command_Logout(source,uid) 
	local userInfo = assert(self._AgentList[uid],"用户当前不在线")--如果当前连接用户不存在的话   
	self.GateWayControlObj:CloseClient(userInfo:GetScoket())--主动登出 
	userInfo:SetSocket(nil)
end 
function MsgService:Command_Kick(source,uid)
    skynet.error("开始准备将用户踢出去",uid)    
    local userInfo = assert(self._AgentList[uid],"user not found") 
    skynet.call(userInfo:GetHandle(),"lua","logout",1)--向角色发送登出服务，让角色断网  
end  

--真正当一个用户彻底退出后，会执行清除登录用户的步骤
function MsgService:Command_CleanUser(source,uid)  
	local userInfo = assert(self._AgentList[uid],"未寻找到指定的端口信息")--获取到用户登录的信息
	if userInfo:GetSocket() then--真到这一步了，早就断网了
		print("当前程序出现了 一个 奇怪的错误")
	end   
	self._AgentList[uid]  = nil   --清数据
end  

function MsgService:RegisterCommand(commandTable) 
	commandTable.open =  handler(self,MsgService.Command_OpenGateWay) --当用户收到了打开 消息服务器的消息时
	commandTable.close =  handler(self,MsgService.Command_CloseGateWay)--当用户收到了关闭 消息服务器的消息时
	
	commandTable.login = handler(self,MsgService.Command_Login) --当一个账号登录成功后，会进入这里
	commandTable.write = handler(self,MsgService.Command_Write)  
	commandTable.logout = handler(self,MsgService.Command_Logout)
	commandTable.kick =  handler(self,MsgService.Command_Kick)     
	commandTable.cleanUser = handler(self,MsgService.Command_CleanUser)     --清除登录信息（一个agent完全退出后，本次的登录就全部结束了，需要将agent所关联的事物给清除）
end   

function MsgService:AllocAgentMinorId()--生成subid
    self._subid  = self._subid  + 1
    return self._subid
end 

--获取到当前服务器的名字
function MsgService:GateWayName()
	return self._gatewayName 
end  
function MsgService:GetLoginHandle()
	return self._login 
end  
   
function MsgService:Auth(fd, msg, sz)
	local userInfo  
	local retStatus = ErrorType.ExecuteSuccess
	local message = netpack.tostring(msg, sz)--解析当前的网络包
	local uid, subID = string.match(message, "([^:]*):([^:]*)")--获取到用户名称 
	local uid =  Tool:Base64Decode(uid)
	local subID = Tool:Base64Decode(subID) 
	if not uid or not subID then 
		retStatus = ErrorType.ExecuteFailed  --返回未知错误
		goto err
	end      
	userInfo = self._AgentList[uid] 
	if not userInfo then
		retStatus = ErrorType.UserNotLoggedIn 
		goto err 
	end  
	if not userInfo:CompareSubID(subID)then 
		retStatus = ErrorType.ConnectServerIndexError 
		goto err
	end  
	if userInfo:GetSocket() then--如果当前有用户登入的话  
		skynet.call(userInfo:GetHandle(),"lua","logout") --发送离线信息
	end
	userInfo:SetSocket( fd )   
    skynet.send(userInfo:GetHandle(),"lua","auth_success",uid,subID)  
	goto success
::err:: 
	self.GateWayControlObj:CloseClient(fd)--验证失败关闭套接字
::success::
	return retStatus,uid
end  
function MsgService:MsgDispose(userName,message)
	local userInfo = assert(self._AgentList[userName], "无效的套接字 用户不存在于当前服务器")
    local msgTable = self:AnalysisMsg(msg)   
    assert(msgTable,"message fromat error")         
	skynet.send(userInfo:GetHandle(),"client",table.unpack(msgTable))  
end  

function MsgService:AnalysisMsg(msg)--解析一条消息  
    local ret,msgtable = pcall(function (msg) return table.pack(string.unpack("<I4 i8 i4 i4 i4 s4",msg)) end,msg)   
    return msgtable
end 
function MsgService:InitServerData(gatewayName)   
	self._gatewayName = assert(gatewayName,"not input server name")  --当前的服务名称   
    self._AgentList = {}--记录指定用户对应的
	self.GateWayControlObj = nil
	self._login = nil --当前登入的登录服务器
	self._subid = 1 --一组绝对不会重复的ID 
end     

local MsgService = MsgService.new(...)