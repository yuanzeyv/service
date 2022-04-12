local BaseModule = require "Template.Service.BaseModule" 
local TableModule = class("TableModule",BaseModule)      
local TableManager = require "Template.Hall.Hall.Manager.TableManager.TableManager"    
function TableModule:InitModuleData(tableData)
    self._tableData = tableData --获取到自己的数据  
    self._tableMan = TableManager.new(tableData,self:GetManager())   
end   

function TableModule:RegisterCommand(commandTable)
end   

function TableModule:Server_PlayerReady(sendObj,userHandle,param1,param2,param3,param4,str)  
    --首先获取到角色是否进入到了大厅 
    sendObj:SetCMD("Net_PlayerReady") 
    local hallMan = self._manager:GetHallPlugin()  --获取到桌子的管理
    local player = hallMan:GetPlayer(userHandle)
    if not player then return G_ErrorConf.NotLoginHall end  --玩家没有进入大厅
    local tableId = player:GetTable()
    if not tableId then return G_ErrorConf.PlayerNotEnterTable end --玩家乜有加入到桌子  
    return self._tableMan:EnterReadyModule(tableID,userHandle)--玩家进入准备模式 
end 

function TableModule:Server_PlayerUnready(sendObj,userHandle,param1,param2,param3,param4,str)   
    sendObj:SetCMD("Net_PlayerUnready") 
    local hallMan = self._manager:GetHallPlugin()  --获取到桌子的管理
    local player = hallMan:GetPlayer(userHandle)
    if not player then return G_ErrorConf.NotLoginHall end  --玩家没有进入大厅
    local tableId = player:GetTable()
    if not tableId then return G_ErrorConf.PlayerNotEnterTable end --玩家乜有加入到桌子  
    return self._tableMan:EnterUnReadyModule(tableID,userHandle)--玩家进入准备模式 
end  
function TableModule:Server_PlayerStand(sendObj,userHandle,param1,param2,param3,param4,str)   
    sendObj:SetCMD("Net_PlayerUnready") 
    local hallMan = self._manager:GetHallPlugin()  --获取到桌子的管理
    local player = hallMan:GetPlayer(userHandle)
    if not player then return G_ErrorConf.NotLoginHall end  --玩家没有进入大厅
    local tableId = player:GetTable()
    if not tableId then return G_ErrorConf.PlayerNotEnterTable end --玩家乜有加入到桌子  
    return self._tableMan:EnterLookModule(tableID,userHandle)--玩家进入准备模式   
end
function TableModule:Server_StartGame(sendObj,userHandle,param1,param2,param3,param4,str) --由房主来开始一场游戏 
    sendObj:SetCMD("Net_PlayerUnready") 
    local hallMan = self._manager:GetHallPlugin()  --获取到桌子的管理
    local player = hallMan:GetPlayer(userHandle)
    if not player then return G_ErrorConf.NotLoginHall end  --玩家没有进入大厅
    local tableId = player:GetTable()
    if not tableId then return G_ErrorConf.PlayerNotEnterTable end --玩家乜有加入到桌子  
    local startList = self._tableMan:StartGame(tableID,userHandle)--玩家进入准备模式{会返回一个列表，包含观战人员名单，加入游戏人员名单，未准备观战人员名单}
    --创建一场游戏
    --对这场游戏进行通讯，将名单传入给游戏
    --等待游戏返回成功加入的名单
    return G_ErrorConf.ExecuteSuccess
end
function TableModule:Server_EnterGame(sendObj,userHandle,param1,param2,param3,param4,str)  
    sendObj:SetCMD("Net_PlayerUnready") 
    local hallMan = self._manager:GetHallPlugin()  --获取到桌子的管理
    local player = hallMan:GetPlayer(userHandle)
    if not player then return G_ErrorConf.NotLoginHall end  --玩家没有进入大厅
    local tableId = player:GetTable()
    if not tableId then return G_ErrorConf.PlayerNotEnterTable end --玩家乜有加入到桌子  
    return self._tableMan:EnterPlayModule(tableID,userHandle)--玩家进入准备模式 
end
function TableModule:Server_LeaveGame(sendObj,userHandle,param1,param2,param3,param4,str)
    sendObj:SetCMD("Net_PlayerUnready") 
    local hallMan = self._manager:GetHallPlugin()  --获取到桌子的管理
    local player = hallMan:GetPlayer(userHandle)
    if not player then return G_ErrorConf.NotLoginHall end  --玩家没有进入大厅
    local tableId = player:GetTable()
    if not tableId then return G_ErrorConf.PlayerNotEnterTable end --玩家乜有加入到桌子  
    return self._tableMan:PlayerLeaveGame(tableID,userHandle)--玩家进入准备模式 
end 

function TableModule:RegisterNetCommand(serverTable)
    serverTable.Net_PlayerReady = handler(self,TableModule.Server_PlayerReady)--角色进入准备模式 
    serverTable.Net_PlayerUnready = handler(self,TableModule.Server_PlayerUnready)--角色进入未准备模式  
    serverTable.Net_PlayerStand = handler(self,TableModule.Server_PlayerStand)----角色进入观战模式  

    serverTable.Net_StartGame = handler(self,TableModule.Server_StartGame)----玩家开始游戏（仅房主可以操作）   
    serverTable.Net_EnterGame = handler(self,TableModule.Server_EnterGame)----玩家尝试加入一场游戏  
    serverTable.Net_LeaveGame = handler(self,TableModule.Server_LeaveGame)----玩家尝试离开一场游戏    
end   

function TableModule:GetTableManager()
    return self._tableMan
 end       
function TableModule:InitModule()--重写
end 
 
function  TableModule:Init()   
end

return TableModule
