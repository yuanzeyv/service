require "Tool.Class" 
local Player = require"HallSystemModule.Hall.StructManager.Player" --大厅里面有桌子 
local PlayerManager = class("PlayerManager")   

function PlayerManager:ctor(table)    
    self:InitServiceData(table)
end

function PlayerManager:InitServiceData(table)
    assert(table,"param miss")
    self._playerArray = {count = 0}--大厅总人数  
    self._maxCapacity = table.maxCapacity or 800 
end

--获取到一个玩家
function PlayerManager:GetPlayer(userID)
    local playerCell = self._playerArray[userID]   
    return playerCell
end 
  
--添加一个角色
function PlayerManager:AddPlayer(userId)
    assert(self._playerArray.count >= self._maxCapacity,"the number of players has reached its limit")
    local player = Player.new(userId)
    self._playerArray.count = self._playerArray.count + 1 
    self._playerArray[userId] = player
    player:EnterHall() 
    return player
end  

--删除一个角色
function PlayerManager:DeletePlayer(userId)
    local player= assert(self:GetPlayer(userId) ,"player is not exist")
    self._playerArray[userId] = nil
    self._playerArray.count = self._playerArray.count - 1   
    player:LeaveHall()
    return true
end      
return PlayerManager 