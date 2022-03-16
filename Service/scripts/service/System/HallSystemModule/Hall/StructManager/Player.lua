require "Tool.Class" 
local Player = class("Player")  

Player.HALL_ACTION_STATUS =  {IDLE = 0 , BUS = 1} 
Player.TABLE_ACTION_STATUS = {LOOK = 0 , SIT = 1} 
Player.GAME_STATUS =  {UN_READY = 0 , READY = 1,PLAYEING = 2}    

function Player:ctor(userID )     
    self:InitData(userID) 
end

function Player:InitData(userID) 
    assert(userID,"userID not exist ") 
    self._userID = userID--当前的用户ID   

    self._hallAction = 0 --0是空闲 1是忙碌（进入房间）

    self._tableAction = 0 --0是观战，1是坐下 
    self._table = nil --当前用户是在哪个桌子下 

    self._gameStatus = 0 --0是未准备 1是准备 2是开始中    
end 

function Player:EnterHall() 
    self._hallAction = Player.HALL_ACTION_STATUS.IDLE 
end 
function Player:LeaveHall() 
    self._hallAction = Player.HALL_ACTION_STATUS.IDLE 
end  


function Player:EnterTable(tableID)  
    self._hallAction = Player.HALL_ACTION_STATUS.BUS 
    self._table = tableID
    self._tableAction = Player.TABLE_ACTION_STATUS.LOOK
    self._gameStatus = Player.GAME_STATUS.UN_READY
end  

function Player:LeaveTable()
    self._hallAction = Player.HALL_ACTION_STATUS.IDLE 
    self._table = nil
end

function Player:CancelReady() 
    assert(self._hallAction ==  Player.HALL_ACTION_STATUS.BUS and self._tableAction == Player.TABLE_ACTION_STATUS.SIT,"player status error") 
    self._gameStatus = Player.GAME_STATUS.UN_READY
end 
function Player:Ready()
    assert(self._hallAction ==  Player.HALL_ACTION_STATUS.BUS and self._tableAction == Player.TABLE_ACTION_STATUS.SIT,"player status error")  
    self._gameStatus = Player.GAME_STATUS.READY
end 
function Player:StartGame() 
    assert(self._hallAction ==  Player.HALL_ACTION_STATUS.BUS and self._tableAction == Player.TABLE_ACTION_STATUS.SIT,"player status error")  
    self._gameStatus = Player.GAME_STATUS.PLAYEING 
end 

function Player:StandUp() 
    assert(self._hallAction ==  Player.HALL_ACTION_STATUS.BUS and self._tableAction == Player.TABLE_ACTION_STATUS.SIT,"player status error")   
    self._tableAction = Player.TABLE_ACTION_STATUS.LOOK
end 
function Player:SitDown() 
    assert(self._hallAction ==  Player.HALL_ACTION_STATUS.BUS and self._tableAction == Player.TABLE_ACTION_STATUS.LOOK,"player status error")   
    self._tableAction = Player.TABLE_ACTION_STATUS.SIT 
end  
 
function Player:SetTableStatus(action)
    local array = {[Player.HALL_ACTION_STATUS.LOOK]= self.StandUp,[Player.HALL_ACTION_STATUS.SIT] = self.sitDown }  
    assert(array[action],"action not exist")
    array[action](self)
end  
function Player:SetGameStatus(gameStatus)
    local array = {
    [Player.GAME_STATUS.UN_READY]= self.CancelReady,
    [Player.GAME_STATUS.READY] = self.Ready, 
    [Player.GAME_STATUS.PLAYEING] = self.StartGame }  
    assert(array[gameStatus],"action not exist")
    array[gameStatus](self)
end 

function Player:GetID()--当前的用户句柄
    return self._userID 
end   
function Player:GetProxyID()--当前的用户句柄
    return self._proxyID 
end   
function Player:GetHallStatus()
    return self._hallAction
end
function Player:GetTableStatus()
    return self._tableAction
end   
function Player:GetGameStatus()
    return self._gameStatus
end   
function Player:GetTable()
    return self._table
end 
 
--判断用户是否可以退出房间 或者 大厅
function Player:GetPlayerIsBus()   
    return self._table and self._tableAction == Player.HALL_ACTION_STATUS.SIT and self._gameStatus ~= Player.GAME_STATUS.UN_READY 
end 


return Player