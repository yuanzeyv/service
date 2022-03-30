--return -1 被登入的系统ID不存在
--return -2 登入系统失败
--return -3 玩家已经加入了房间了
--return -4 玩家重复登入了系统了
--return -5 玩家未登入系统
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
        return -4 --重复登入
    end  
    print("ascscac")
    --角色记录当前系统
    skynet.call(playHandle,"lua","register_system",self._manager:GetSystemID(),skynet.self())
    print("CCc")
    self:EnterSystem(playHandle) --角色进入当前系统
    return 0 
end
--角色离开系统
function SystemService:Command_UnRegisterAgent(source,playHandle) 
    if not self:IsEnterSystem(playHandle) then 
        return -5
    end 
    assert(self:IsEnterSystem(playHandle),"player is register" )--首先判断当前角色是否存在于当前系统，如果存在，返回错误码
    skynet.send(playHandle,"lua","unregister_system",self.sysID,skynet.self()) 
    self:LeaveSystem() 
    return 0
end
  
function SystemService:RegisterCommand(commandTable) 
	commandTable.login_system = handler(self,SystemService.Command_LoginSystem)--角色登入系统
	commandTable.unregister_agent = handler(self,SystemService.Command_UnRegisterAgent) --角色离开系统
    commandTable.request_system_info = handler(self,SystemService.Command_Request_SystemInfo)
end 

function SystemService:Server_EnterHall(playHandle,msgName,sendObj,userHandle,hallIndex,param2,param3,param4,str) 
    assert(self:HallIsExist(hallIndex),"not find hall")--没有找到这个大厅
    local enterStatus = skynet.call(hallId,"lua","playerEnterHall",playHandle) 
    assert(self:HallIsExist(hallIndex),"enter hall failed")--没有找到这个大厅 
    self:EnterHall(playHandle,hallIndex) --玩家加入大厅 
    --进入大厅后，大厅会发送消息给客户端
end

function SystemService:Server_LeaveHall(playHandle,msgName,sendObj,userHandle,param1,param2,param3,param4,str)
    assert(self:HallIsExist(hallIndex),"not find hall")--没有找到这个大厅
    local levelStatus = skynet.call(hallId,"lua","playerLeaveHall",playHandle)--离开时会发送消息
    assert(self:HallIsExist(hallIndex),"leave hall failed")--没有找到这个大厅  
    self:LeaveHall(playHandle,hallHandle)    
end
--请求大厅信息
function SystemService:Server_RequestHallList(playHandle,msgName,sendObj,userHandle,param1,param2,param3,param4,str)   
    for v,k in pairs(self._hallArray) do --循环比那里当前大厅数据
        local hallDes = skynet.call(k,"lua","requestHallInfo")--取到大厅的描述
        hallInfo[v] =  hallDes--加入大大厅队列中
    end     
    --向角色返回大厅的详细请求数据
    skynet.send(playHandle,"lua","write",NetCommandConfig:FindCommand(self._manager:GetSystemID(),"Net_Request_HallList_RET"),0,0,1,1,Json.Instance():Encode(hallInfo))
end 
function SystemService:RegisterNetCommand(serverTable)
    serverTable.Net_EnterTable = handler(self,SystemService.Server_EnterTable)--进入桌子
    serverTable.Net_LeaveTable = handler(self,SystemService.Server_LeaveTable)--离开桌子 
    serverTable.Net_Request_HallList = handler(self,SystemService.Server_RequestHallList)--请求大厅信息 
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

function  SystemService:Init()  
end
return SystemService 