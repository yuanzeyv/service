
--角色进入未准备模式
--return 0  函数执行正常
--return -1 玩家已经加入了桌子 
--return -2 大厅玩家已经满员了
--return -3 玩家没有加入到大厅
--return -4 玩家没有加入到桌子
require "Tool.Class" 
local Map = require "Tool.Map" 
local Player = require"HallSystemModule.Hall.StructManager.Player" --大厅里面有桌子 
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
    --assert(self._playerArray.count >= self._maxCapacity,"已经到达了大厅所能容纳的最大人员数目了")
    if self._playerArray:Count() >= self._maxCapacity then 
        return -2
    end  
    local player = Player.new(userHandle)
    self._playerArray:Add(userHandle,player) --玩家加入到管理列表
    player:EnterHall() --玩家进入大厅
    return 0
end  

--删除一个角色
function PlayerManager:PlayerLeaveHall(userHandle)
    local player=self:GetPlayer(userHandle)
    if not player then return -3 end  
    self._playerArray:Delete(userHandle) 
    return player:LeaveHall() 
end  
--玩家进入桌子
function PlayerManager:EnterTable(userHandle,tableID) 
    local player=self:GetPlayer(userHandle)
    if not player then 
        return -3
    end  
    return player:EnterTable(tableID)
end 
--玩家离开桌子    
function PlayerManager:LeaveTable(userHandle)
    local player=self:GetPlayer(userHandle)
    if not player then  return -3 end  
    return player:LeaveTable(tableID) 
end  
--获取到某一个玩家是否进入桌子
function PlayerManager:GetPlayerTable(userHandle)
    local player=self:GetPlayer(userHandle)
    if not player then return nil  end   
    return player:GetTable()
end  
return PlayerManager 