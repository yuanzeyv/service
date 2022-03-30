require "Tool.Class" 
local Player = class("Player")   
Player.HALL_ACTION_STATUS =  {IDLE = 0 , BUS = 1} 
function Player:ctor(userID)     
    self:InitData(userID) 
end

function Player:InitData(userHandle) 
    assert(userHandle,"userID not exist ") 
    self._userID = userHandle--当前的用户ID   
    self._hallAction = 0 --0是空闲 1是忙碌（进入房间） 
    self._table = nil --nil代表当前没有进入桌子  否则 为 桌子ID
end 

function Player:EnterHall() 
    self._hallAction = Player.HALL_ACTION_STATUS.IDLE 
    return 0
end 

function Player:LeaveHall()
    self._hallAction = Player.HALL_ACTION_STATUS.IDLE 
    return 0
end  

function Player:EnterTable(tableID)  
    if self._hallAction then 
        return -1 --玩家已经加入了桌子
    end  
    self._hallAction = Player.HALL_ACTION_STATUS.BUS 
    self._table = tableID 
    return 0
end  

function Player:LeaveTable() 
    self._hallAction = Player.HALL_ACTION_STATUS.IDLE 
    self._table = nil
end 

function Player:GetID()--当前的用户句柄
    return self._userID 
end   
 
function Player:GetTable()
    return self._table
end    
return Player