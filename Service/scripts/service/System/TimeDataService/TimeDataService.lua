local BaseService = require "Template.Service.BaseService" 
local Player = require "TimeDataService.Player" 
local TimeDataService = class("TimeDataService",BaseService)  
function TimeDataService:Command_EnterSystem(source,userHandle,uid)   
    if self._playerList[userHandle] then 
        return G_ErrorConf.RepetSystem
    end  
    local player = Player.new()  
    self._playerList[userHandle] = player 
    return skynet.call(userHandle,"lua","register_system",self:GetSystemID(),skynet.self()) 
end 

function TimeDataService:Command_LeaveSystem(userHandle,uid)  
    if not self._playerList[uid] then 
        skynet.error("data isexist system error")
    end   
    self._playerList[uid] = nil
    return skynet.call(userHandle,"lua","unregister_system",self._manager:GetSystemID(),skynet.self()) 
end  

function TimeDataService:Command_RequestSystem(source,userHandle)  
    local sendObj = BaseMessageObj.new(self,userHandle) 
    sendObj:SetCMD("Net_Request_Heartbeat")
    sendObj:SetErrCode(G_ErrorConf.ExecuteSuccess)
    local playerInfo = self._playerList[userHandle] --取得当前角色的详细信息
    if not playerInfo then
        sendObj:Send(G_ErrorConf.PlayerSys_UserNotExist) 
        return 
    end   
    sendObj:SetParam2(playerInfo:GetNeedAuth() and 1 or 0 )--查询当前的角色信息 
    sendObj:Send() 
end  
function TimeDataService:Command_RequestSimpleSystemMsg(source,userHandle)  
    local SystemInfo = {}  
    SystemInfo.id = self:GetSystemID()
    SystemInfo.name = self:GetSystemName()
    return SystemInfo   
end  

function TimeDataService:GetSystemName()
    return "时钟管理系统"
end 
function TimeDataService:RegisterCommand(commandTable)     
	commandTable.enter_system   = handler(self,TimeDataService.Command_EnterSystem) 
	commandTable.leave_system   = handler(self,TimeDataService.Command_LeaveSystem)
	commandTable.request_system = handler(self,TimeDataService.Command_RequestSystem) 
	commandTable.request_simple_system_msg = handler(self,TimeDataService.Command_RequestSimpleSystemMsg) 
end 

--请求大厅信息 
function TimeDataService:Server_Heartbeat(sendObj,userHandle,param1,param2,param3,param4,str)    
    sendObj:SetCMD("Net_Heartbeat")  
    local playerInfo = self._playerList[userHandle] --取得当前角色的详细信息
    if not playerInfo then 
        return G_ErrorConf.PlayerSys_UserNotExist
    end
    print("客户端发送了心跳 当前在10秒内接收到的心跳包个数:",playerInfo:Heartbeat(),skynet.time())
end 

function TimeDataService:RegisterNetCommand(serverTable)
    serverTable.Net_Heartbeat = handler(self,TimeDataService.Server_Heartbeat)--进入桌子 
end  
 

function TimeDataService:HeartbeatAuth()    
    local timeNow = skynet.time() 
    --local anomlayList = {} 
    for v,k in pairs(self._playerList) do  
        local ret  = k:HeartbeatAuth(timeNow)  
        if ret == 0 then 
            print("用户" .. v .. "心跳异常 警告",skynet.time()) 
            --anomlayList[v] = k  
            k:SetNeedAuth(false)  
            return skynet.call(v,"lua","logout") 
        end  
    end   
    --for v,k in pairs(anomlayList) do 
    --    self._playerList[v] = nil 
    --end 
    skynet.timeout(50, handler(self,TimeDataService.HeartbeatAuth))--每一百毫秒计算一次
end   
--初始化数据
function TimeDataService:InitServerData(...)    
    self._playerList = {}  

end  
--初始化系统
function TimeDataService:InitSystem()   
    skynet.timeout(10, handler(self,TimeDataService.HeartbeatAuth))--每一百毫秒计算一次
end     
local TimeDataService = TimeDataService.new(...) 