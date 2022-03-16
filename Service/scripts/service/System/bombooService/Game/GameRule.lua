require"Tool.Tool"
local WinWinStatusMachine = require("bombooService.Game.GameMachine.WinWinStatusMachine")
local StartStatusMachine = require("bombooService.Game.GameMachine.StartStatusMachine")
local OverStatusMachine = require("bombooService.Game.GameMachine.OverStatusMachine")
local CheckStatusMachine = require("bombooService.Game.GameMachine.CheckStatusMachine")
local CardVirifyStatusMachine = require("bombooService.Game.GameMachine.CardVirifyStatusMachine")
local AttackStatusMachine = require("bombooService.Game.GameMachine.AttackStatusMachine")
local AbandonStatusMachine = require("bombooService.Game.GameMachine.AbandonStatusMachine")
local GameMachine = require("bombooService.Game.GameMachine.GameMachine") 
local GameRule = class("GameRule")
GameRule.PLAYER1 = 1 --全局变量
GameRule.PLAYER2 = 2  --全局变量

function GameRule:InitCards()
    for i= 1 ,54 do
        self._allCards[i] = i
    end
    Tool.Instance():Disorganize(self._allCards,2)
end

function GameRule:SetFirstPlayer()
    self._firstCapPlayer = math.random(1,2)
    self._capPlayer = self._firstCapPlayer
end

function GameRule:DispatchHandCards() 
    local residueCards = math.random(1,10)--初始化先手 
    for i = 1 , 22 + residueCards do 
        table.insert(self._playerList[self.PLAYER1].handCards,self._allCards[i]) 
        table.insert(self._playerList[self.PLAYER2].handCards,self._allCards[i + 22 + residueCards])  
    end
end

--真代表有同类，假代表无同类
function GameRule:CheckCardTable(player)
    local index = #self._tableCards - 1
    local lastIndex = #self._tableCards
    while index > 0 do
        if self._cardsInfo.comparePoint(self._tableCards[index],self._tableCards[lastIndex]) then  
            break
        end
        index = index - 1
    end 
    if index  <= 0 then 
        return false
    end  
    for i =index , #self._tableCards do  
        table.insert(self._playerList[player].awardCards,self._tableCards[i])
        self._tableCards[i] = nil  
    end 
    return true 
end  
--打出一张牌
function GameRule:CapCard(player,index)
    assert(player == self._capPlayer,"stage error") 
    local card = assert(self._playerList[player].handCards[index],"card not exist")--判断当前角色是否存在这张牌
    print("玩家" ,player,"打出了",card)
    table.remove( self._playerList[player].handCards,index)
    table.insert(self._tableCards,card)
end
--判断手牌是否为空
function GameRule:HandCardIsEmpty(player)
    return #self._playerList[player].handCards == 0
end 
function GameRule:AwarCardIsEmpty(player)
    return #self._playerList[player].awardCards == 0
end 
--置换手牌
function GameRule:SwapHandCards(player) 
    self._playerList[player].handCards,self._playerList[player].awardCards =  self._playerList[player].awardCards,self._playerList[player].handCards
end 

--对手牌进行打乱
function GameRule:OversetHandCards(player)
    
    Tool.Instance():Disorganize(self._playerList[player].handCards ,2)
end
--打乱底牌
function GameRule:OversetAwawrdCards(player)
    Tool.Instance():Disorganize(self._playerList[player].awardCards ,2)
end 

function GameRule:ctor() 
end 

--判断当前玩家是否是可操作玩家
function GameRule:IsOperationalUser(player)
    return player == self._capPlayer
end 
--获取到下一个可以操作的玩家ID
function GameRule:NextOperationalUser()
    return (self._capPlayer % 2)  + 1 
end 
function GameRule:NowOperationalUser()
    return self._capPlayer 
end 
--设置下一位出牌人
function GameRule:OperationalUserChange()
    self._capPlayer = self:NextOperationalUser()
end 

--获取到下一个可以操作的玩家ID
function GameRule:OperationalUserData(player)
    return (self._capPlayer % 2)  + 1 
end  

--获取到一个有限状态机
function GameRule:GetStatusMachine(status)
    return self._gameStatusMachine[status]
end
function GameRule:InitStatusMachine()  
    self._gameStatusMachine = {}
    self._gameStatusMachine[GameMachine.STATUS.START] = StartStatusMachine.new(self)
    self._gameStatusMachine[GameMachine.STATUS.ATTACK] = AttackStatusMachine.new(self)
    self._gameStatusMachine[GameMachine.STATUS.CHECK] = CheckStatusMachine.new(self)
    self._gameStatusMachine[GameMachine.STATUS.CARD_CHECK] = CardVirifyStatusMachine.new(self)
    self._gameStatusMachine[GameMachine.STATUS.ABANDON] = AbandonStatusMachine.new(self)
    self._gameStatusMachine[GameMachine.STATUS.WINWIN] = WinWinStatusMachine.new(self)
    self._gameStatusMachine[GameMachine.STATUS.OVER] = OverStatusMachine.new(self)   
end 


function GameRule:InitData()  
    math.randomseed(1) 
    self._cardsInfo = require "bombooService.Game.CardsConfig" 
    self._firstCapPlayer = 1 --第一个出牌的人
    self._capPlayer = self.PLAYER1 --接下来应该打牌的人  
    self._allCards = {} --牌库里面的牌
    self._playerList = {} 
    self._playerList[self.PLAYER1] = {handCards = {},awardCards = {},} --玩家1 绑定的信息
    self._playerList[self.PLAYER2] = {handCards = {},awardCards = {},} --玩家2绑定的信息 
    self._tableCards = {}  --牌桌上的牌  
    --初始化状态机
    self._gameStatusMachineList = nil
    self:InitStatusMachine() 
    self._NowStatusMachine = self:GetStatusMachine(GameMachine.STATUS.START)--游戏当前所指向的状态机
    self._NowStatusMachine:StartHandle()
end 
return GameRule