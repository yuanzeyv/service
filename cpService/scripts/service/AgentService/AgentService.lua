local NetService = require "NetService" 
local AgentService = class("AgentService",NetService)    
function AgentService:Command_Login(source, uid, sid,username)--登录成功 
	assert(source and uid and sid,"参数传入有误") 
    self._gate     = source --消息服务器
    self._userid   = uid    --用户的uid
    self._subid    = sid    --用户的subid
    self._username = username --用户的登录名称    
    self._systemControlHandle[SystemConfig["SystemManager"].SysID]= {handle = skynet.localname(".SystemManager")} --每个系统都有一个别名
end   

function AgentService:Command_Logout(source)  
    skynet.send(self._gate, "lua", "logout", self._username) --登出的实际意义是断网
    return ErrorType.ExecuteSuccess
end 

function AgentService:Command_Disconnect(source) --收到网络连接关闭的信息时，走这里
    skynet.error(string.format("disconnect"))
    return ErrorType.ExecuteSuccess
end 

function AgentService:Command_Write(source,msgId,param1,param2,param3,param4,str)     
    --local _ =  msgId ~= 300 and   skynet.error(string.format("(%d)Message => msgID:%-4d param1:%-4d param2:%-4d param3:%-4d param4:%-4d str:%s", skynet.self(),msgId,param1,param2,param3,param4,str == "" and "空" or str ))
    skynet.send(self._gate, "lua", "write",self._username,self:PackMsg(msgId,param1,param2,param3,param4,str))
end
function AgentService:Command_GetUserInfo(source,msgId,param1,param2,param3,param4,str)     
    local ret = {}    
    ret["uid"]   = self._userid   
    ret["uname"] = self._username
    return ret
end

function AgentService:Command_RegisterSystem(source,systemID,handle)   
    self._systemControlHandle[systemID] = {handle = handle}
    return ErrorType.ExecuteSuccess
end 

function AgentService:Command_UnRegisterSystem(source,systemID)--断开与系统的连接
    self._systemControlHandle[systemID] = nil
    return ErrorType.ExecuteSuccess
end  
function AgentService:Command_AuthSuccess(source)--登录验证成功的消息  
    local handle = self._systemControlHandle[SystemConfig["SystemManager"].SysID].handle 
    skynet.send(handle, "lua", "auth_success",self:GetHandle(),self._systemControlHandle,self._userid ) --角色会把当前拥有的系统发送给系统管理，然后由系统管理判断是否需要添加
    return ErrorType.ExecuteSuccess
end   

function AgentService:RegisterCommand(commandTable)
	commandTable.login             =  handler(self,AgentService.Command_Login)
	commandTable.logout            =  handler(self,AgentService.Command_Logout)--1是踢人  
	commandTable.disconnect        =  handler(self,AgentService.Command_Disconnect)
	commandTable.write             =  handler(self,AgentService.Command_Write)
	commandTable.register_system   =  handler(self,AgentService.Command_RegisterSystem)
	commandTable.unregister_system =  handler(self,AgentService.Command_UnRegisterSystem)
	commandTable.auth_success      =  handler(self,AgentService.Command_AuthSuccess)--客户端在正在连接成功时的调用消息 
	commandTable.get_user_info      =  handler(self,AgentService.Command_GetUserInfo)--客户端在正在连接成功时的调用消息 
 end 
function AgentService:__InitNetEventDispatch() 
    skynet.register_protocol {
        name = "client",
        id = skynet.PTYPE_CLIENT,
        pack = skynet.pack,
        unpack = skynet.unpack,
        dispatch =function(_,source,msgId,param1,param2,param3,param4,str)   
            local FindSystem = assert(G_NetCommandConf:FindByIndex(msgId),"没有找到指定消息")--寻找到消息ID对应的数据信息  
            local systemInfo = assert(self._systemControlHandle[FindSystem.systemID],"消息".. msgId.."没有找到指定的系统" )--通过系统ID查找指定系统
            skynet.send(systemInfo.handle,"client",msgId,self:GetHandle(),param1,param2,param3,param4,str)  
        end 
    }
end
function AgentService:PackMsg(msgId,param1,param2,param3,param4,str)
    return string.pack("<I4 i4 i4 i4 i8 s4",msgId,param1 or 0 ,param2 or 0 ,param3 or 0 ,param4 or 0 ,str or "")
end   
function AgentService:InitServerData(...)
    self._gate   = nil
    self._userid = nil
    self._subid  = nil   
    self._systemControlHandle = {}     
end    
local AgentService = AgentService.new("AgentControl")