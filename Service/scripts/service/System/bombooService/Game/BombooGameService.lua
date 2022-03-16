
local skynet = require "skynet"
require "skynet.manager"
require "Tool.Class" 
local GameRule = require "bombooService.Game.GameRule"
local BombooGameService = class("BombooGameService")     
function BombooGameService:Command_InitGame(data)
    self._GameData:InitData()
    self:OneSecondTimer()
end 
function BombooGameService:Command_CapCard(player,index)   
    self._GameData._NowStatusMachine:CapHandle(player,index)
end 
function BombooGameService:Command_Abandon(data)
end 
function BombooGameService:Command_WinWin(data)
end 
function BombooGameService:Command_Trustee(data)
end 
function BombooGameService:GetCMD()
    local CMD = {}  
    CMD.initGame = handler(self,self.Command_InitGame)--用于初始化当前游戏数据  
    CMD.capCard = handler(self,self.Command_CapCard)  --打牌
    CMD.abandon = handler(self,self.Command_Abandon)  --认输
    CMD.winWin = handler(self,self.Command_WinWin)  --求和 
	return CMD 
end 

function BombooGameService:InitServerData() 
    self._GameData = GameRule.new()  
    self._command = self:GetCMD()
end

function BombooGameService:ctor()
    self:InitServerData()
    self:InitServer()
end   

function BombooGameService:OneSecondTimer()    
    if self._stop then
        return 
    end
    skynet.timeout(100,handler(self,self.OneSecondTimer))
end   
function BombooGameService:InitEventDispatch()  
    skynet.dispatch("lua", function(session, source, command, ...)
        local f = assert(self._command[command]) 
        skynet.ret(skynet.pack(f(...)))
    end)    
end
 
function BombooGameService:InitServer()
	skynet.start(function ()   
        self:InitEventDispatch() 
	end)
end 

local BombooGameService = BombooGameService.new(...)