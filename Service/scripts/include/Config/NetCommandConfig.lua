--防止重复包含
if NetCommandConfig then
    return NetCommandConfig
end  
local SystemIDConfig = require("Config.SystemIDConfig") 
require "Tool.Class"
NetCommandConfig =  class("NetCommandConfig")  

function NetCommandConfig.Instance() 
    if not NetCommandConfig._instance then
       NetCommandConfig._instance = NetCommandConfig.new()
    end 
    return NetCommandConfig._instance
end  
function NetCommandConfig:ctor() 
    self._idTable = SystemIDConfig.Instance():GetTable() 
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
    
    self:AddNetCommand("Net_LoginSystem_RET"   ,self._idTable.SystemManager,4) --登入系统 
    self:AddNetCommand("Net_LoginOutSystem_RET"   ,self._idTable.SystemManager,5) --登入系统 
    self:AddNetCommand("Net_RequestSystem_RET",self._idTable.SystemManager, 6) --请求系统消息 

    --第一个系统区域 100 - 200
    --的所有消息（这是一个房间的所有通用消息）
    self:AddNetCommand("Net_Request_HallList",self._idTable.PokerSystem,100) --进入大厅
    self:AddNetCommand("Net_Request_HallList_RET",self._idTable.PokerSystem,101) --大厅列表的返回

    --self:AddNetCommand("Net_EnterHall",self._idTable.PokerSystem,100) --进入大厅
    --self:AddNetCommand("Net_LeaveHall",self._idTable.PokerSystem,101) --离开大厅
    --self:AddNetCommand("Net_RequestHallInfo",self._idTable.PokerSystem,101) --离开大厅

    self:AddNetCommand("Net_EnterHall_ret",self._idTable.PokerSystem,102) --进入大厅
    self:AddNetCommand("Net_LeaveHall_ret",self._idTable.PokerSystem,103) --离开大厅
    self:AddNetCommand("Net_RequestHallInfo_ret",self._idTable.PokerSystem,104) --离开大厅
    
    self:AddNetCommand("Net_PlayerReady"  ,self._idTable.PokerSystem,110)  --玩家准备
    self:AddNetCommand("Net_PlayerSitDown",self._idTable.PokerSystem,111) --玩家坐下 
    self:AddNetCommand("Net_PlayerStand"  ,self._idTable.PokerSystem,112)   --玩家站起 
                                                                            
    self:AddNetCommand("Net_SetTableParam",self._idTable.PokerSystem,120)  --设置桌子参数
    self:AddNetCommand("Net_EnterTable"   ,self._idTable.PokerSystem,121) --进入房间
    self:AddNetCommand("Net_LeaveHall"    ,self._idTable.PokerSystem,122) --离开房间
    self:AddNetCommand("Net_PlayerReady"  ,self._idTable.PokerSystem,123) --游戏状态变更
    self:AddNetCommand("Net_StartGame"    ,self._idTable.PokerSystem,124) --开始游戏  

    self:AddNetCommand("Net_Abandon",self._idTable.PokerSystem,150)--认输
    self:AddNetCommand("Net_WinWin",self._idTable.PokerSystem,151)--求和 
    self:AddNetCommand("Net_Trustee",self._idTable.PokerSystem,152)--托管

    --第一个系统的发送消息 200 - 300
    self:AddNetCommand("Net_SC_EnterHall",self._idTable.PokerSystem,200) --进入大厅
    self:AddNetCommand("Net_SC_LeaveHall",self._idTable.PokerSystem,201) --离开大厅


    
    --接竹竿系统区域 200 - 300
    --的所有消息（这是一个房间的所有通用消息）
    self:AddNetCommand("Net_EnterHall",self._idTable.SystemManager,200) --进入大厅
    self:AddNetCommand("Net_LeaveHall",self._idTable.SystemManager,201) --离开大厅
    
    self:AddNetCommand("Net_PlayerReady"  ,self._idTable.SystemManager,210)  --玩家准备
    self:AddNetCommand("Net_PlayerSitDown",self._idTable.SystemManager,211) --玩家坐下 
    self:AddNetCommand("Net_PlayerStand"  ,self._idTable.SystemManager,212)   --玩家站起 
                                                                            
    self:AddNetCommand("Net_SetTableParam",self._idTable.SystemManager,220)  --设置桌子参数
    self:AddNetCommand("Net_EnterTable"   ,self._idTable.SystemManager,221) --进入房间
    self:AddNetCommand("Net_LeaveHall"    ,self._idTable.SystemManager,222) --离开房间
    self:AddNetCommand("Net_PlayerReady"  ,self._idTable.SystemManager,223) --游戏状态变更
    self:AddNetCommand("Net_StartGame"    ,self._idTable.SystemManager,224) --开始游戏 
    
    self:AddNetCommand("Net_FirstPlayCard",self._idTable.SystemManager,240)--先手
    self:AddNetCommand("Net_TapCard",self._idTable.SystemManager,241)--出一张牌

    self:AddNetCommand("Net_Abandon",self._idTable.SystemManager,250)--认输
    self:AddNetCommand("Net_WinWin",self._idTable.SystemManager,251)--求和 
    self:AddNetCommand("Net_Trustee",self._idTable.SystemManager,252)--托管

    --第一个系统的发送消息 300 - 400
    self:AddNetCommand("Net_SC_EnterHall",self._idTable.SystemManager,300) --进入大厅
    self:AddNetCommand("Net_SC_LeaveHall",self._idTable.SystemManager,401) --离开大厅
     
end 
--判断命令是否存在
function NetCommandConfig:FindByIndex(index) 
    return self._Table[index]
end 
return NetCommandConfig