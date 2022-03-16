require "Tool.Class"
local Map = require "Tool.Map"
local Table = class("Table") 
Table.PLAYER_ACTION_STATUS = {SIT = 1 ,LOOK = 0}   
Table.PLAYER_STATUS = {UNREADY = 0 ,READY = 1 ,PLAYING = 2}   
function Table:ctor(tableInfo)    
    self.maxPlayerCount = assert(tableInfo.maxPlayerCount,"param miss")
    self.maxSitDownPlayer = assert(tableInfo.maxSitDownPlayer,"param miss")
    self._startGameNeedPlayer = assert(tableInfo.startGameNeedPlayer,"param miss") 
    --房间能坐下的所有人员 
    self._allPlayerArray = Map.new()
    self._playStatusTable = {} 
    self._playStatusTable[Table.PLAYER_ACTION_STATUS.SIT] = Map.new()
    self._playStatusTable[Table.PLAYER_ACTION_STATUS.LOOK] =  Map.new() --当前的观战玩家数组   
    self._tableGameHandle = nil --桌子关联的句柄
end
function Table:CanStartGame()
    if self:IsPlaying() then
        return false
    end
    local readyCount = 0
    for v,k in pairs(self._playStatusTable[Table.PLAYER_ACTION_STATUS.SIT]:GetTable()) do
        if k:GetGameStatus() == k.GAME_STATUS.READY then
            readyCount = readyCount + 1  
        end
    end
    return readyCount >= self._startGameNeedPlayer 
end  
--添加一个角色到球桌
function Table:AddPlayer(player) 
    local playerID = player:GetID()
    local playerInfo = self._allPlayerArray:Find(playerID) 
    assert(not playerInfo,"player early enter table")
    assert(self._allPlayerArray:Count() < self.maxPlayerCount,"table is Full" )  
    self._allPlayerArray:Add(playerID,player)
    self._lookPlayerArray:ADD(playerID,player)
    player:EnterTable(self)
end 
--删除一个角色到球桌
function Table:DeletePlayer(player)
    local playerID = player:GetID()
    local playerInfo = assert(self._allPlayerArray:Find(playerID) ,"not found has table of player") 
    assert(not playerInfo:GetPlayerIsBus(),"status not compare") --当前用户不是忙碌状态
    assert(self._playStatusTable[playerInfo:GetTableStatus()],"player status bus") 
    self._allPlayerArray:Delete(playerID)
    self._playStatusTable[playerInfo.playerAction]:Delete(playerInfo.handle) 
    player:LeaveTable()
end
--设置当前角色动作
function Table:SetPlayerAction(player,action)
    local playerID = player:GetID()
    local playerInfo = assert(self._allPlayerArray:Find(playerID) ,"not found has table of player") 
    local playerAction = playerInfo:GetTableStatus()
    assert(playerAction ~= action,"action is same")  
    assert(self._playStatusTable[playerAction],"player status error")
    assert(self._playStatusTable[action],"player status error")
    self._playStatusTable[playerAction]:Delete(playerInfo.handle)  
    self._playStatusTable[action]:Add(playerInfo.handle,playerInfo)   
    player:SetTableStatus(action)
end 
--设置当前角色游戏状态
function Table:SetPlayerGameStatus(player,gameStatus)
    local playerID = player:GetID()
    local playerInfo = assert(self._allPlayerArray:Find(playerID) ,"not found has table of player")    
    playerInfo:SetGameStatus(gameStatus)
end  



function Table:PlayerEnter(player,action)
    self:AddPlayer(player)
    self:SetPlayerAction(player,action)
end

function Table:PlayerLeave(player) 
    self:DeletePlayer(player)
end  

function Table:PlayerCancelReady(player)
    self:SetPlayerGameStatus(player,player.GAME_STATUS.UN_READY) 
end   
function Table:PlayerReady(player) 
    self:SetPlayerGameStatus(player,player.GAME_STATUS.READY) 
end  
function Table:PlayerStartGame(player)   
    self:SetPlayerGameStatus(player,player.GAME_STATUS.PLAYEING) 
end  

function Table:PlayerStandUp(player)
    self:SetPlayerAction(player,player.TABLE_ACTION_STATUS.LOOK) 
       
end  
function Table:PlayerSitDown(player)
    self:SetPlayerAction(player,player.TABLE_ACTION_STATUS.SIT) 
end   

function Table:SetTableGameHandle(handle)
    self._tableGameHandle = handle
end 
function Table:IsPlaying()
    return self._tableGameHandle ~= nil 
end 

return Table 