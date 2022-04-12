local Player = require "PlayerInfoService.Player" 
local AgentDataBaseOper = require "PlayerInfoService.AgentDataBaseOper" 
local BaseService = require "Template.Service.BaseService"     
local PlayerInfoService = class("PlayerInfoService",BaseService)  

function PlayerInfoService:Command_EnterSystem(source,userHandle,uid)  
    if self._playerList[uid] then 
        skynet.error("data isexist system error")
    end  
    local player = Player.new(uid) 
    player:SetUserData(self._database:GetUserInfo(uid))
    self._playerList[userHandle] = player
    return skynet.call(userHandle,"lua","register_system",self:GetSystemID(),skynet.self()) 
end 

function PlayerInfoService:Command_LeaveSystem(userHandle,uid)  
    if not self._playerList[uid] then 
        skynet.error("data isexist system error")
    end   
    self._playerList[uid] = nil
    return skynet.call(userHandle,"lua","unregister_system",self._manager:GetSystemID(),skynet.self()) 
end  

function PlayerInfoService:Command_RequestSystem(source,userHandle)  
    local sendObj = BaseMessageObj.new(self,userHandle) 
    sendObj:SetCMD("Net_Request_PlayerInfo")
    sendObj:SetErrCode(G_ErrorConf.ExecuteSuccess)
    local playerInfo = self._playerList[userHandle] --取得当前角色的详细信息
    if not playerInfo then
        sendObj:Send(G_ErrorConf.PlayerSys_UserNotExist) 
        return 
    end  
    local errorCode = playerInfo:GetErrorCode() --获取到错误码
    if errorCode ~= G_ErrorConf.ExecuteSuccess then 
        sendObj:Send(G_ErrorConf.errorCode) 
        return 
    end 
    sendObj:SetJson(playerInfo:GetUserData())--查询当前的角色信息 
    sendObj:Send() 
end  

function PlayerInfoService:RegisterCommand(commandTable)     
	commandTable.enter_system   = handler(self,PlayerInfoService.Command_EnterSystem)
	commandTable.leave_system   = handler(self,PlayerInfoService.Command_LeaveSystem)
	commandTable.request_system = handler(self,PlayerInfoService.Command_RequestSystem) 
end 
function PlayerInfoService:RegisterNetCommand(serverTable) 
end    
 
--初始化数据
function PlayerInfoService:InitServerData(...)    
    self._playerList = {} 
    self._database = AgentDataBaseOper.new()
end  
 
--初始化系统
function PlayerInfoService:InitSystem()    
end   
local PlayerInfoService = PlayerInfoService.new(G_SysIDConf:GetTable().PlayerSystem) --这是角色系统