local skynet = require "skynet"
require "Tool.Class" 
local PlayerService = class("PlayerService")     
local PlayerManager = require "HallSystemModule.Hall.StructManager.PlayerManager"
function PlayerService:ctor(manager, tableData)   
    self:InitData(manager, tableData)
end
function PlayerService:InitData(manager, tableData)   
    self._manager = manager  
    self._tableData = tableData   
    self._commandList = self:GetCMD()  
    self._serviceList = self:GetServer() 
    self._playerMan = PlayerManager.new(tableData)  
end 

function  PlayerService:Init()
end  
function PlayerService:GetCMD()
    local CMD = {} 
    return CMD
end  


function PlayerService:FindCommand(cmd)
    return self._commandList[cmd]
end  

function PlayerService:Server_EnterTable(userHandle,msgName,tableId,isLook,param3,param4,str)  
    local player=  assert( self._playerMan:GetPlayer(userHandle),"player not enter hall") --角色没有进入到大厅
    assert(not player:GetTable(),"The player has entered the table") --玩家进入了桌子
    self._tableManager:PlayerEnterTable(tableId,player,isLook)--将用户加入到桌子里面 
    --返回桌子的信息
    skynet.send(userHandle,"lua","write",NetCommandConfig:FindCommand(self.systemID,"Net_LeaveHall_ret"),1)  
end 
function PlayerService:Server_LeaveTable(userHandle,msgName,param1,param2,param3,param4,str)  
    local player=  assert( self._playerMan:GetPlayer(userHandle),"player not enter hall") --角色没有进入到大厅
    local tableData = assert(player:GetTable(),"player does not enter table") --角色没有进入到大厅
    self._tableManager:PlayerLeaveTable(tableData,player)
    --返回是否成功
    skynet.send(userHandle,"lua","write",NetCommandConfig:FindCommand(self.systemID,"Net_LeaveHall_ret"),1)
end 

function PlayerService:FindService(cmd)
    return self._serviceList[cmd]
end 
   
function PlayerService:GetServer()
    local server = {}  
    server.Net_EnterTable = handler(self,PlayerService.Server_EnterTable)--进入桌子
    server.Net_LeaveTable = handler(self,PlayerService.Server_LeaveTable)--离开桌子 
	return server
end 

return PlayerService