require "Tool.Class" 
local Player = class("Player")   
Player.HALL_ACTION_STATUS =  {IDLE = 0 , BUS = 1} --一个玩家只有两种状态 大厅里 桌子里
function Player:ctor(userID)    
    self:InitData(userID) 
end

function Player:InitData(userHandle) 
    self._userID = assert(userHandle,"userID not exist ") --传入的用户ID为空 
    self._hallAction = Player.HALL_ACTION_STATUS.IDLE --0是空闲 1是忙碌（进入房间） 
    self._table = nil --nil代表当前没有进入桌子  否则 为 桌子ID
end 

function Player:EnterHall() 
    self._hallAction = Player.HALL_ACTION_STATUS.IDLE 
    return G_ErrorConf.ExecuteSuccess
end 

function Player:LeaveHall()
    self._hallAction = Player.HALL_ACTION_STATUS.IDLE 
    return G_ErrorConf.ExecuteSuccess
end  

function Player:EnterTable(tableID)  
    if self._table  then 
        return self._table == tableID and G_ErrorConf.PlayerRepeatEnterTable 
        or G_ErrorConf.PlayerEnterTableEarlie  
    end  
    self._hallAction = Player.HALL_ACTION_STATUS.BUS 
    self._table = tableID 
    return G_ErrorConf.ExecuteSuccess
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