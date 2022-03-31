local BaseModule = require "BaseService.BaseModule" 
local SystemService = class("SystemService",BaseModule)     
function SystemService:InitModuleData(tableData) 
    self._systemPlayers = {}--当前登入系统的角色信息 
end   
--需要重写 用于获取系统信息
function SystemService:Command_Request_SystemInfo(source) 
    local SystemInfo = {}  
    SystemInfo.id = self._manager:GetSystemID()
    SystemInfo.name = self._manager:GetSystemName()
    return SystemInfo  
end 

--角色登录系统
function SystemService:Command_LoginSystem(source,playHandle)
    local systemId = self._manager:GetSystemID()--首先获取到当前的系统ID 
    if self._systemPlayers[playHandle] then --如果当前角色已经进入了系统的haunt
        return G_ErrorConf.RepetSystem --重复登入
    end
    --角色记录当前系统
    skynet.call(playHandle,"lua","register_system",self._manager:GetSystemID(),skynet.self())
    self:EnterSystem(playHandle) --角色进入当前系统
    return G_ErrorConf.ExecuteSuccess
end
--角色离开系统
function SystemService:Command_UnRegisterAgent(source,playHandle) 
    if not self:IsEnterSystem(playHandle) then 
        return G_ErrorConf.NotLoginSystem
    end  
    skynet.send(playHandle,"lua","unregister_system",self.sysID,skynet.self()) 
    self:LeaveSystem() 
    return G_ErrorConf.ExecuteSuccess
end
  
function SystemService:RegisterCommand(commandTable) 
	commandTable.login_system = handler(self,SystemService.Command_LoginSystem)--角色登入系统
	commandTable.unregister_agent = handler(self,SystemService.Command_UnRegisterAgent) --角色离开系统
    commandTable.request_system_info = handler(self,SystemService.Command_Request_SystemInfo)
end  
function SystemService:RegisterNetCommand(serverTable) 
end  
 
function SystemService:EnterSystem(playHandle) 
    self._systemPlayers[playHandle] = true
end

function SystemService:LeaveSystem(playHandle) 
    self._systemPlayers[playHandle] = false
end

function SystemService:IsEnterSystem(playHandle) 
   return self._systemPlayers[playHandle]
end 
--获取到一个玩家是否进入了大厅
function SystemService:GetPlayerHallHandle(playHandle)
    if not self._systemPlayers[playHandle] then
        return nil
    end
    return self._systemPlayers[playHandle].hallIndex
end
--获取到一个玩家是否进入了大厅
function SystemService:GetPlayer(playHandle)
    return self._systemPlayers[playHandle] 
end  
--初始化函数
function  SystemService:Init()  
end
return SystemService 