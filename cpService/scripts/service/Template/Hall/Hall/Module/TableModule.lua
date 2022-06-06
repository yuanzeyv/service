local BaseModule = require "Template.Service.BaseModule" 
local TableModule = class("TableModule",BaseModule)      
local TableManager = require "Template.Hall.Hall.Manager.TableManager.TableManager"    
function TableModule:InitModuleData(tableData) 
    self._tableMan = TableManager.new(tableData,self)   
end    

function TableModule:Server_PlayerReady(sendObj,userHandle,param1,param2,param3,param4,str)   
    sendObj:SetCMD("Net_PlayerReady")  
    local player = self._manager:GetEnterPlayer(userHandle)--获取到玩家的信息
    if not player then return ErrorType.NotLoginHall end --如果进入成功的话
    return self._tableMan:EnterReadyModule(userHandle)--玩家进入准备模式
end 

function TableModule:Server_PlayerUnready(sendObj,userHandle,param1,param2,param3,param4,str)   
    sendObj:SetCMD("Net_PlayerUnready") 
    local player = self._manager:GetEnterPlayer(userHandle)
    if not player then return ErrorType.NotLoginHall end  
    return self._tableMan:EnterUnReadyModule(userHandle)--玩家进入准备模式 
end  
function TableModule:Server_PlayerStand(sendObj,userHandle,param1,param2,param3,param4,str)   
    sendObj:SetCMD("Net_PlayerUnready") 
    local player = self._manager:GetEnterPlayer(userHandle)
    if not player then return ErrorType.NotLoginHall end  
    return self._tableMan:EnterLookModule(userHandle)--玩家进入准备模式   
end
function TableModule:Server_StartGame(sendObj,userHandle,param1,param2,param3,param4,str) --由房主来开始一场游戏 
    sendObj:SetCMD("Net_PlayerUnready") 
    local player = self._manager:GetEnterPlayer(userHandle)
    if not player then return ErrorType.NotLoginHall end   
    return self._tableMan:StartGame(userHandle)--玩家进入准备模式    
end
function TableModule:Server_EnterGame(sendObj,userHandle,param1,param2,param3,param4,str)  
    sendObj:SetCMD("Net_PlayerUnready") 
    local player = self._manager:GetEnterPlayer(userHandle)
    if not player then return ErrorType.NotLoginHall end 
    return self._tableMan:EnterGame(userHandle)--玩家进入准备模式    
end
function TableModule:Server_LeaveGame(sendObj,userHandle,param1,param2,param3,param4,str)
    sendObj:SetCMD("Net_PlayerUnready") 
    local player = self._manager:GetEnterPlayer(userHandle)
    if not player then return ErrorType.NotLoginHall end 
    return self._tableMan:LeaveGame(userHandle)--玩家进入准备模式 
end 
--请求大厅信息
function TableModule:Server_EnterTable(sendObj,userHandle,tableID,param2,param3,param4,str)
    sendObj:SetCMD("Net_EnterTable") 
    local player = self._manager:GetEnterPlayer(userHandle) 
    if not player then return ErrorType.NotLoginHall end  --玩家是否进入了大厅   
    sendObj:SetParam2(userHandle)
    return self._tableMan:EnterTable(tableID,userHandle)--玩家进入桌子 
end  

function TableModule:Server_LeaveTable(sendObj,userHandle,param1,param2,param3,param4,str)    
    sendObj:SetCMD("Net_LeaveTable") 
    local player = self._manager:GetEnterPlayer(userHandle)
    if not player then return ErrorType.NotLoginHall end  
    return self._tableMan:LeaveTable(userHandle)--玩家进入桌子  
end   

function TableModule:Server_TableAllInfo(sendObj,userHandle,param1,param2,param3,param4,str)    
    sendObj:SetCMD("Net_TableAllInfo")  
    local player = self._manager:GetEnterPlayer(userHandle) 
    if not player then return ErrorType.NotLoginHall end 
    local retStatus,playerList =  self._tableMan:GetTablePlayerList(userHandle)--玩家进入桌子 
    if retStatus ~= ErrorType.ExecuteSuccess then 
        return retStatus
    end 
    sendObj:SetJson(playerList)
    return ErrorType.ExecuteSuccess 
end   

function TableModule:RegisterNetCommand(serverTable)
    serverTable.Net_PlayerReady = handler(self,TableModule.Server_PlayerReady)--角色进入准备模式 
    serverTable.Net_PlayerUnready = handler(self,TableModule.Server_PlayerUnready)--角色进入未准备模式  
    serverTable.Net_PlayerStand = handler(self,TableModule.Server_PlayerStand)----角色进入观战模式  
    serverTable.Net_TableAllInfo = handler(self,TableModule.Server_TableAllInfo)----角色进入观战模式  

    

    serverTable.Net_StartGame = handler(self,TableModule.Server_StartGame)----玩家开始游戏（仅房主可以操作）   
    serverTable.Net_EnterGame = handler(self,TableModule.Server_EnterGame)----玩家尝试加入一场游戏  
    serverTable.Net_LeaveGame = handler(self,TableModule.Server_LeaveGame)----玩家尝试离开一场游戏  

    serverTable.Net_EnterTable = handler(self,TableModule.Server_EnterTable)----玩家尝试加入一场游戏  
    serverTable.Net_LeaveTable = handler(self,TableModule.Server_LeaveTable)----玩家尝试离开一场游戏    
end    

function TableModule:GetTableListInfo()
    return self._tableMan:GetTableListInfo()
end   
return TableModule
