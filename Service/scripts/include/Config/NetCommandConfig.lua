--防止重复包含
if G_NetCommandConf then
    return
end  
require("Config.SystemIDConfig") 
require "Tool.Class"
NetCommandConfig =  class("NetCommandConfig")  
 
function NetCommandConfig:ctor()  
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
    local sysTable = G_SysIDConf:GetTable() 
    self:AddNetCommand("Net_LoginSystem"   ,sysTable.SystemManager,1) --登入系统 
    self:AddNetCommand("Net_LoginOutSystem",sysTable.SystemManager,2) --登出系统 
    self:AddNetCommand("Net_RequestSystem",sysTable.SystemManager, 3) --请求系统消息
    self:AddNetCommand("Net_SystemInitSuccess",sysTable.SystemManager, 4) --请求系统消息 


    --第一个系统区域 100 - 200
    --的所有消息（这是一个房间的所有通用消息）
    self:AddNetCommand("Net_Request_HallList",sysTable.PokerSystem,100) --请求大厅详细信息  
    self:AddNetCommand("Net_EnterHall",sysTable.PokerSystem,101) --进入大厅
    self:AddNetCommand("Net_LeaveHall",sysTable.PokerSystem,102) --离开大厅
    self:AddNetCommand("Net_EnterTable",sysTable.PokerSystem,103) --进入桌子
    self:AddNetCommand("Net_LeaveTable",sysTable.PokerSystem,104) --离开桌子
    self:AddNetCommand("Net_PlayerReady",sysTable.PokerSystem,105) --玩家准备
    self:AddNetCommand("Net_PlayerUnready",sysTable.PokerSystem,106) --玩家未准备 
    self:AddNetCommand("Net_PlayerStand",sysTable.PokerSystem,107) --玩家观战
    self:AddNetCommand("Net_StartGame",sysTable.PokerSystem,108) --房主开始游戏
    self:AddNetCommand("Net_EnterGame",sysTable.PokerSystem,109) --玩家进入游戏
    self:AddNetCommand("Net_LeaveGame",sysTable.PokerSystem,110) --玩家离开游戏
    self:AddNetCommand("Net_LookGame",sysTable.PokerSystem,111) --离开大厅  
    self:AddNetCommand("Net_ChangeMaster",sysTable.PokerSystem,112) --更换房主 


    --玩家系统的系统消息区域 200 - 250
    self:AddNetCommand("Net_Request_PlayerInfo",sysTable.PlayerSystem,200) --向玩家返回玩家的详细数据信息  
    
    --时钟系统，时钟系统里面有玩家，玩家需要将自己注册到其中，时钟系统维护所有登入的玩家并检测玩家心跳 
    self:AddNetCommand("Net_Heartbeat",sysTable.TimeSystem,300) --向玩家返回玩家的详细数据信息  
    self:AddNetCommand("Net_Request_Heartbeat",sysTable.TimeSystem,301) --向玩家返回玩家的详细数据信息  
    self:AddNetCommand("Net_Player_Net_Break",sysTable.TimeSystem,302)  --玩家断线网络请求
end 
--判断命令是否存在
function NetCommandConfig:FindByIndex(index) 
    return self._Table[index]
end 
G_NetCommandConf = NetCommandConfig.new() 