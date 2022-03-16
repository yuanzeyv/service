local skynet = require "skynet"
require "Tool.Class" 
local TableService = class("TableService")    
local TableManager = require "HallSystemModule.Hall.StructManager.TableManager"
function TableService:ctor(manager, tableData)   
    self:InitData(manager, tableData)
end 
function TableService:InitData(manager, tableData)   
    self._manager = manager  
    self._tableData = tableData   
    self._commandList = self:GetCMD()
    self._serviceList = self:GetServer() 
    self._tableMan = TableManager.new(tableData)   
end

function  TableService:Init()
end 
 
function TableService:GetCMD()
    local CMD = {}    
    return CMD
end  
function TableService:FindCommand(cmd)
    return self._commandList[cmd]
end   

function TableService:FindService(cmd)
    return self._serviceList[cmd]
end 
   

function TableService:InitServiceData(tableManager,playerManager)
    self._tableMan = assert(tableManager,"param miss") 
    self._playerMan =  assert(playerManager,"param miss")   
    self._commandArray = self:CommandList() 
end   
function TableService:Server_CancelReady(userHandle)
    local player=  assert( self._playerMan:GetPlayer(userHandle),"player not enter hall") --角色没有进入到大厅
    local tableData = assert(player:GetTable(),"player does not enter table") --角色没有进入到大厅
    self._tableManager:PlayerCancelReady(tableData,player)
    skynet.send(userHandle,"lua","write",NetCommandConfig:FindCommand(self.systemID,"Net_LeaveHall_ret"),0)
end  
function TableService:Server_PlayerReady(userHandle,msgName,param1,param2,param3,param4,str) 
    local player=  assert( self._playerMan:GetPlayer(userHandle),"player not enter hall") --角色没有进入到大厅
    local tableData = assert(player:GetTable(),"player does not enter table") --角色没有进入到大厅
    self._tableManager:PlayerReady(tableData,player)
    self._tableManager:CheckStartGame(tableData)--每次加入一场游戏，都会判断一下是否游戏开始了
    skynet.send(userHandle,"lua","write",NetCommandConfig:FindCommand(self.systemID,"Net_LeaveHall_ret"),1)
end
function TableService:Server_PlayerStand(userHandle,msgName,param1,param2,param3,param4,str) 
    local player=  assert( self._playerMan:GetPlayer(userHandle),"player not enter hall") --角色没有进入到大厅
    local tableData = assert(player:GetTable(),"player does not enter table") --角色没有进入到大厅
    self._tableManager:PlayerStandUp(tableData,player) 
    skynet.send(userHandle,"lua","write",NetCommandConfig:FindCommand(self.systemID,"Net_LeaveHall_ret"),1)
end
function TableService:Server_PlayerSitDown(userHandle,msgName,param1,param2,param3,param4,str)
    local player=  assert( self._playerMan:GetPlayer(userHandle),"player not enter hall") --角色没有进入到大厅
    local tableData = assert(player:GetTable(),"player does not enter table") --角色没有进入到大厅
    self._tableManager:PlayerSitDown(tableData,player)  
    skynet.send(userHandle,"lua","write",NetCommandConfig:FindCommand(self.systemID,"Net_LeaveHall_ret"),0)
end 

function TableService:Server_SetTableParam(userHandle,msgName,tableId,param2,param3,param4,data)
    --找到对应的桌子
    --判断桌子的主人是否与用户相匹配
    --如果相匹配，那么就通过参数设置当前的桌子的信息
    skynet.send(userHandle,"lua","write",NetCommandConfig:FindCommand(self.systemID,"Net_LeaveHall_ret"),0) 
end
function TableService:Server_RequestTableInfo(userHandle,msgName,tableId,param2,param3,param4,data)
    --找到对应的桌子
    --判断桌子的主人是否与用户相匹配
    --如果相匹配，那么就通过参数设置当前的桌子的信息
    skynet.send(userHandle,"lua","write",NetCommandConfig:FindCommand(self.systemID,"Net_LeaveHall_ret"),0) 
end
function TableService:Server_TableParamInfo(userHandle,msgName,tableId,param2,param3,param4,data)
    --找到对应的桌子
    --判断桌子的主人是否与用户相匹配
    --如果相匹配，那么就通过参数设置当前的桌子的信息
    skynet.send(userHandle,"lua","write",NetCommandConfig:FindCommand(self.systemID,"Net_LeaveHall_ret"),0) 
end
function TableService:Server_Abandon(userHandle,msgName,tableId,param2,param3,param4,data)
    --找到对应的桌子
    --判断桌子的主人是否与用户相匹配
    --如果相匹配，那么就通过参数设置当前的桌子的信息
    skynet.send(userHandle,"lua","write",NetCommandConfig:FindCommand(self.systemID,"Net_LeaveHall_ret"),0) 
end
function TableService:Server_Trustee(userHandle,msgName,tableId,param2,param3,param4,data)
    --找到对应的桌子
    --判断桌子的主人是否与用户相匹配
    --如果相匹配，那么就通过参数设置当前的桌子的信息
    skynet.send(userHandle,"lua","write",NetCommandConfig:FindCommand(self.systemID,"Net_LeaveHall_ret"),0) 
end
function TableService:Server_WinWin(userHandle,msgName,tableId,param2,param3,param4,data)
    --找到对应的桌子
    --判断桌子的主人是否与用户相匹配
    --如果相匹配，那么就通过参数设置当前的桌子的信息
    skynet.send(userHandle,"lua","write",NetCommandConfig:FindCommand(self.systemID,"Net_LeaveHall_ret"),0) 
end
function TableService:GetServer()
    local server = {}   
    server.Net_PlayerReady = handler(self,TableService.Server_PlayerReady)
    server.Net_PlayerCancelReady = handler(self,TableService.Server_CancelReady) 
    server.Net_PlayerSitDown = handler(self,TableService.Server_PlayerSitDown)
    server.Net_PlayerStand = handler(self,TableService.Server_PlayerStand)
    server.Net_SetTableParam = handler(self,TableService.Server_SetTableParam)
    server.Net_TableParamInfo = handler(self,TableService.Server_TableParamInfo)
    server.Net_RequestTableInfo = handler(self,TableService.Server_RequestTableInfo)
 
    server.Net_Abandon = handler(self,TableService.Server_Abandon)    --托管
    server.Net_Trustee = handler(self,TableService.Server_Trustee)--认输
    server.Net_WinWin = handler(self,TableService.Server_WinWin) --求和


	return server
end 

return TableService