require "Tool.Class" 
local Map = require "Tool.Map" 
local Player = require"Template.Hall.Hall.Manager.PlayerManager.Player" --大厅里面有桌子 
local PlayerManager = class("PlayerManager")    
function PlayerManager:ctor(table)    
    self:InitServiceData(table)
end

function PlayerManager:InitServiceData(tableData)
    assert(tableData,"param miss")
    self._playerArray = Map.new()--大厅总人数  
    self._maxCapacity = tableData.maxCapacity or 800 --最大容纳800人
end

--获取到一个玩家
function PlayerManager:GetPlayer(userHandle)
    local playerCell = self._playerArray[userID]   
    return playerCell
end 
  
--添加一个角色
function PlayerManager:PlayerEnterHall(userHandle)
    if self._playerArray:Count() >= self._maxCapacity then 
        return G_ErrorConf.HallPersonFull
    end  
    local player = Player.new(userHandle)--新建一个玩家
    self._playerArray:Add(userHandle,player) --玩家加入到管理列表
    player:EnterHall() --玩家进入大厅
    return G_ErrorConf.ExecuteSuccess
end  

--删除一个角色
function PlayerManager:PlayerLeaveHall(userHandle)
    local player=self:GetPlayer(userHandle)
    if not player then return G_ErrorConf.PlayerNotEnterHall end  
    self._playerArray:Delete(userHandle) --删除当前的玩家
    return player:LeaveHall() --玩家离开
end  
--玩家进入桌子
function PlayerManager:EnterTable(userHandle,tableID) 
    local player=self:GetPlayer(userHandle)
    if not player then return G_ErrorConf.PlayerNotEnterHall end  --如果根本没有找到当前的玩家
    return player:EnterTable(tableID)--进入桌子
end 
--玩家离开桌子    
function PlayerManager:LeaveTable(userHandle)
    local player=self:GetPlayer(userHandle)
    if not player then return G_ErrorConf.PlayerNotEnterHall end  --如果根本没有找到当前的玩家
    return player:LeaveTable() 
end  
--获取到某一个玩家是否进入桌子
function PlayerManager:GetPlayerTable(userHandle)
    local player=self:GetPlayer(userHandle)
    if not player then return nil end  --如果根本没有找到当前的玩家
    return player:GetTable()
end   
return PlayerManager 