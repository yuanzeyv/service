 local BaseModule = require "Template.Service.BaseModule" 
local SystemModule = class("SystemModule",BaseModule)     
function SystemModule:InitModuleData(tableData) 
    self._systemPlayers = {}--当前登入系统的角色信息 
end   
--需要重写 用于获取系统信息
function SystemModule:Command_RequestSimpleSystemMsg(source) 
    local SystemInfo = {}  
    SystemInfo.id = self._manager:GetSystemID()
    SystemInfo.name = self._manager:GetSystemName()
    return SystemInfo  
end 

--角色登录系统
function SystemModule:Command_EnterSystem(source,playHandle) 
    print("ABCASCASCASc")
    if self:GetPlayer(playHandle) then --如果当前角色已经进入了系统的hua
        return G_ErrorConf.RepetSystem --重复登入
    end 
    self:EnterSystem(playHandle) --角色进入当前系统
    --角色记录当前系统
    skynet.call(playHandle,"lua","register_system",self._manager:GetSystemID(),skynet.self())
end
     
--角色离开系统
function SystemModule:Command_LeaveSystem(source,playHandle) 
    if not self:GetPlayer(playHandle)  then --获取到当前用户是否登入了系统 并且加入了大厅
        return G_ErrorConf.NotLoginSystem
    end  
    local hallIndex = hallManager:GetPlayerHallHandle(userHandle)--玩家登入的大厅索引
    if not hallIndex then
        return G_ErrorConf.NotLoginHall
    end   
    local PlayerManager = self._manager:GetPlayerPlugin()  
    if not PlayerManager:GetHall(hallIndex) then --没有找到与索引对应的大厅
        return G_ErrorConf.HallNotExist 
    end
    if not PlayerManager:IsEnterHall(hallIndex,userHandle)  then--本模块是当前角色是否进入了大厅
        return G_ErrorConf.DataChaos--数据混乱
    end  
    --发送退出大厅的请求 
    local retState = skynet.call(hallHandle,"lua","playerLeaveHall",playHandle)--玩家请求退出大厅
    if retState ~= G_ErrorConf.ExecuteSuccess then --如果退出不成功的话
        return retState --无法离开
    end  
    skynet.send(playHandle,"lua","unregister_system",self.sysID,skynet.self()) 
    self:LeaveSystem() 
    PlayerManager:LeaveHall(hallHandle,playHandle)
    return G_ErrorConf.ExecuteSuccess
end
  

function SystemModule:Command_RequestSystem(source,userHandle)   
end  

function SystemModule:RegisterCommand(commandTable)   
	commandTable.enter_system   = handler(self,SystemModule.Command_EnterSystem)
	commandTable.leave_system   = handler(self,SystemModule.Command_LeaveSystem)
	commandTable.request_system = handler(self,SystemModule.Command_RequestSystem) 
	commandTable.request_simple_system_msg = handler(self,SystemModule.Command_RequestSimpleSystemMsg)  
end  
function SystemModule:RegisterNetCommand(serverTable) 
end  
 
function SystemModule:EnterSystem(playHandle) 
    self._systemPlayers[playHandle] = {}
end

function SystemModule:LeaveSystem(playHandle) 
    self:LeaveHall(playHandle)
    self._systemPlayers[playHandle] = nil
end

function SystemModule:IsEnterSystem(playHandle) 
   return self._systemPlayers[playHandle]
end 
--获取到一个玩家是否进入了大厅
function SystemModule:GetPlayerHallHandle(playHandle)
    if not self._systemPlayers[playHandle] then
        return nil
    end
    return self._systemPlayers[playHandle].hallIndex
end
--进入了大厅
function SystemModule:EnterHall(HallIndex,playHandle)
    if not self._systemPlayers[playHandle] then
        return nil
    end
    self._systemPlayers[playHandle].hallIndex = HallIndex
end 
--离开了大厅
function SystemModule:LeaveHall(playHandle)
    if not self._systemPlayers[playHandle] then
        return nil
    end
    self._systemPlayers[playHandle].hallIndex = nil
end 
--获取到一个玩家是否进入了大厅
function SystemModule:GetPlayer(playHandle)
    return self._systemPlayers[playHandle] 
end  
--初始化函数
function  SystemModule:Init()  
end
return SystemModule 