local BaseModule = require "BaseService.BaseModule" 
local TableModule = class("TableModule",PlayerModule)        
local TableManager = require "HallSystemModule.Hall.StructManager.TableManager.TableManager"    
function TableModule:InitModuleData(tableData)
    self._tableData = tableData --获取到自己的数据  
    self._tableMan = TableManager.new(tableData)   
end   

function TableModule:RegisterCommand(commandTable)
end   

function TableModule:Server_PlayerReady(systemHandle,msgName,sendObj,userHandle,param1,param2,param3,param4,str)  
    local playerPlugin = self._manager:GetPlayerPlugin()--获取到玩家的插件
    local playMan = playerPlugin:GetManager()--获取到玩家管理节点
    local tableID = playMan:GetPlayerTable() --获取到玩家的桌子
    if not tableID then 
        skynet.send(userHandle,"lua","write",G_NetCommandConf:FindCommand(self.systemID,"Net_LeaveHall"),-1)  
        return 
    end  
    local ret = self._tableMan:EnterReadyModule(tableID,userHandle) --获取到取消准备的返回
    skynet.send(userHandle,"lua","write",G_NetCommandConf:FindCommand(self.systemID,"Net_LeaveHall"),ret)    
end 
function TableModule:Server_PlayerSitDown(systemHandle,msgName,sendObj,userHandle,param1,param2,param3,param4,str)  
    local playerPlugin = self._manager:GetPlayerPlugin()--获取到玩家的插件
    local playMan = playerPlugin:GetManager()--获取到玩家管理节点
    local tableID = playMan:GetPlayerTable() --获取到玩家的桌子
    if not tableID then 
        skynet.send(userHandle,"lua","write",G_NetCommandConf:FindCommand(self.systemID,"Net_LeaveHall"),-1)  
        return 
    end  
    local ret = self._tableMan:EnterUnReadyModule(tableID,userHandle) --获取到取消准备的返回
    skynet.send(userHandle,"lua","write",G_NetCommandConf:FindCommand(self.systemID,"Net_LeaveHall"),ret)  
end  

function TableModule:Server_SetTableParam(systemHandle,msgName,sendObj,userHandle,param1,param2,param3,param4,str)  
    skynet.send(userHandle,"lua","write",G_NetCommandConf:FindCommand(self.systemID,"Net_LeaveHall_ret"),0) 
end
function TableModule:Server_RequestTableInfo(systemHandle,msgName,sendObj,userHandle,param1,param2,param3,param4,str)  
    skynet.send(userHandle,"lua","write",G_NetCommandConf:FindCommand(self.systemID,"Net_LeaveHall_ret"),0) 
end
function TableModule:Server_EnterTable(systemHandle,msgName,userHandle,param2,param3,param4,str)   
    local playerPlugin = self._manager:GetPlayerPlugin()--获取到玩家的插件
    local playerManager = playerPlugin:GetPlayerManager()
    assert(playerManager:GetPlayer(userHandle),"player not enter hall") --角色没有进入到大厅  
    self._tableMan:PlayerEnterTable(tableId,userHandle,isLook)--将用户加入到桌子里面 
    --返回桌子的信息
    skynet.send(userHandle,"lua","write",G_NetCommandConf:FindCommand(self.systemID,"Net_LeaveHall_ret"),1)  
end 

function TableModule:Server_LeaveTable(systemHandle,msgName,sendObj,userHandle,param1,param2,param3,param4,str)  
    local player=  assert( self._playerMan:GetPlayer(userHandle),"player not enter hall") --角色没有进入到大厅
    local tableData = assert(player:GetTable(),"player does not enter table") --角色没有进入到大厅
    self._tableMan:PlayerLeaveTable(tableData,player)
    --返回是否成功
    skynet.send(userHandle,"lua","write",G_NetCommandConf:FindCommand(self.systemID,"Net_LeaveHall_ret"),1)
end     

function TableModule:RegisterNetCommand(serverTable)
    serverTable.Net_PlayerReady = handler(self,TableModule.Server_PlayerReady)--角色进入准备模式 
    serverTable.Net_PlayerCancelReady = handler(self,TableModule.Server_CancelReady)--角色进入未准备模式 
    serverTable.Net_PlayerSitDown = handler(self,TableModule.Server_PlayerSitDown)
    serverTable.Net_PlayerStand = handler(self,TableModule.Server_PlayerStand)----角色进入观战模式 
    serverTable.Net_EnterTable = handler(self,TableModule.Server_EnterTable)--进入桌子
    serverTable.Net_LeaveTable = handler(self,TableModule.Server_LeaveTable)--角色将退出桌子

    serverTable.Net_StartGame = handler(self,TableModule.Net_StartGame)----玩家开始游戏（仅房主可以操作）   
    serverTable.Net_EnterGame = handler(self,TableModule.Net_EnterGame)----玩家尝试加入一场游戏  
    serverTable.Net_LeaveGame = handler(self,TableModule.Net_LeaveGame)----玩家尝试离开一场游戏  
    serverTable.Net_LookGame = handler(self,TableModule.Net_LookGame)----加入游戏观战模式  
end   

function TableModule:GetTableManager()
    return self._tableMan
 end       
function TableModule:InitModule()--重写
end 
 
function  TableModule:Init()   
end

return TableModule
