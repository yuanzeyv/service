--防止重复包含
if G_NetCommandConf then
    return
end  
require("Config.SystemIDConfig") 
require "Tool.Class"
NetCommandConfig =  class("NetCommandConfig")  
 
function NetCommandConfig:ctor() 
    self._idTable = G_SysIDConf:GetTable() 
    self._Table = {} 
    self._SystemTable = {} 
    self:InitTable()
end 

function NetCommandConfig:AddNetCommand(msgName,systemID,ID)
    self._Table[tonumber(ID)] = {systemID =systemID,cmdName = msgName }

    if not self._SystemTable[systemID] then
        self._SystemTable[systemID] = {}
    end
    self._SystemTable[systemID][msgName] = tonumber(ID) 
end   
function NetCommandConfig:FindCommand(systemID,msgName) 
    return  self._SystemTable[systemID][msgName]
end 

function NetCommandConfig:InitTable()  
    self:AddNetCommand("Net_LoginSystem"   ,self._idTable.SystemManager,1) --登入系统 
    self:AddNetCommand("Net_LoginOutSystem",self._idTable.SystemManager,2) --登出系统 
    self:AddNetCommand("Net_RequestSystem",self._idTable.SystemManager, 3) --请求系统消息
    self:AddNetCommand("Net_SystemInitSuccess",self._idTable.SystemManager, 4) --请求系统消息

    --第一个系统区域 100 - 200
    --的所有消息（这是一个房间的所有通用消息）
    self:AddNetCommand("Net_Request_HallList",self._idTable.PokerSystem,100) --请求大厅详细信息  
    self:AddNetCommand("Net_EnterHall",self._idTable.PokerSystem,101) --进入大厅
    self:AddNetCommand("Net_LeaveHall",self._idTable.PokerSystem,102) --离开大厅
    self:AddNetCommand("Net_EnterTable",self._idTable.PokerSystem,103) --进入桌子
    self:AddNetCommand("Net_LeaveTable",self._idTable.PokerSystem,104) --离开桌子
    self:AddNetCommand("Net_PlayerReady",self._idTable.PokerSystem,105) --玩家准备
    self:AddNetCommand("Net_PlayerUnready",self._idTable.PokerSystem,106) --玩家未准备 
    self:AddNetCommand("Net_PlayerStand",self._idTable.PokerSystem,107) --玩家观战
    self:AddNetCommand("Net_StartGame",self._idTable.PokerSystem,108) --房主开始游戏
    self:AddNetCommand("Net_EnterGame",self._idTable.PokerSystem,109) --玩家进入游戏
    self:AddNetCommand("Net_LeaveGame",self._idTable.PokerSystem,110) --玩家离开游戏
    self:AddNetCommand("Net_LookGame",self._idTable.PokerSystem,111) --离开大厅  
    self:AddNetCommand("Net_ChangeMaster",self._idTable.PokerSystem,112) --更换房主 


    --玩家系统的系统消息区域 200 - 250
    self:AddNetCommand("Net_Request_PlayerInfo",self._idTable.PlayerSystem,200) --向玩家返回玩家的详细数据信息
     
end 
--判断命令是否存在
function NetCommandConfig:FindByIndex(index) 
    return self._Table[index]
end 
G_NetCommandConf = NetCommandConfig.new() 