require("Config.SystemIDConfig")--打开系统id配置
require("Config.NetCommandConfig")
local ServiceModle = require "ServiceModle.ServiceModle" 
local AgentService = class("AgentService",ServiceModle)    
function AgentService:Command_Login(source, uid, sid,username)--登录成功
	assert(source and uid and sid,"参数传入有误") 
    self._gate   = source
    self._userid = uid
    self._subid  = sid  
    self._username = username 
    --self._surviveStatus = 1 --1代表健康 2代表断网 3代表正在退出系统
    self._netStatus = true --网络连接是否正常 false代表断开连接 true代表已连接
    self._serviceHandle = skynet.self()
    --程序一上来就会寻找系统管理服务
    self._systemControlHandle = {
        [G_SysIDConf:GetTable().SystemManager]= {handle = skynet.localname(".SystemManager")}
    } 
end  

--退出时一定会退出当前的服务器
function AgentService:Command_Logout(source)  
    skynet.send(self._gate, "lua", "logout", self._username) --登出的实际意义是断网
end 

function AgentService:Command_Disconnect(source) --gate发现client的连接断开了，会发disconnect消息过来这里不要登出 
    skynet.error(string.format("disconnect"))
end 

function AgentService:Command_Write(source,msgId,param1,param2,param3,param4,str)    
    if not self._netStatus then 
        skynet.error(source,"网络连接已断开,消息被截留")
        return 
    end 
    if msgId ~= 300 then
        skynet.error(string.format("(%d)Message => msgID:%-4d param1:%-4d param2:%-4d param3:%-4d param4:%-4d str:%s", skynet.self(),msgId,param1,param2,param3,param4,str == "" and "空" or str ))
    end 
    skynet.call(self._gate, "lua", "write",self._username,self:PackMsg(msgId,param1,param2,param3,param4,str))
end

function AgentService:Command_RegisterSystem(source,systemID,handle)   
    self._systemControlHandle[systemID] = {handle = handle}
end 

function AgentService:Command_UnRegisterSystem(source,systemID)--断开与系统的连接
    self._systemControlHandle[systemID] = nil
end 

function AgentService:Command_AuthSuccess(source)--登录验证成功的消息  
    local handle = self._systemControlHandle[G_SysIDConf:GetTable().SystemManager].handle 
    skynet.send(handle, "lua", "auth_success",self._systemControlHandle,self._userid ) --角色会把当前拥有的系统发送给系统管理，然后由系统管理判断是否需要添加
end 
function AgentService:Command_SetNetStatus(source,netStatus)--登录验证成功的消息   
    self._netStatus = netStatus
end 

function AgentService:RegisterCommand(commandTable)
	commandTable.login             =  handler(self,AgentService.Command_Login)
	commandTable.logout            =  handler(self,AgentService.Command_Logout)--1是踢人 
	commandTable.setNetStatus      =  handler(self,AgentService.Command_SetNetStatus)--设置当前用户的网络连接状态 
	commandTable.disconnect        =  handler(self,AgentService.Command_Disconnect)
	commandTable.write             =  handler(self,AgentService.Command_Write)
	commandTable.register_system   =  handler(self,AgentService.Command_RegisterSystem)
	commandTable.unregister_system =  handler(self,AgentService.Command_UnRegisterSystem)
	commandTable.auth_success      =  handler(self,AgentService.Command_AuthSuccess)--客户端在正在连接成功时的调用消息 
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
            skynet.send(systemInfo.handle,"client",FindSystem.cmdName,self._serviceHandle,param1,param2,param3,param4,str)  
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
    self._systemControlHandle = nil     
end    

local AgentService = AgentService.new()
 

