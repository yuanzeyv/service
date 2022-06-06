local GameServiceBase = require("HallSystemModule.HallService.GameModule")
local GameService = class("GameService",GameServiceBase)       
function GameService:Server_TapCard(playHandle,msgName,tableId,param2,param3,param4,data)
    local hallHandle = assert(self._manager:GetPlayerHallHandle(playHandle),"player early enter hall")--玩家未加入系统 或者没有加入大厅   
    skynet.send(hallHandle,"lua","tapCard",playHandle,tableId,data) 
end
function GameService:Server_DispatchCards(playHandle,msgName,tableId,param2,param3,param4,data)
    local hallHandle = assert(self._manager:GetPlayerHallHandle(playHandle),"player early enter hall")--玩家未加入系统 或者没有加入大厅   
    skynet.send(hallHandle,"lua","tapCard",playHandle,tableId,data) 
end
function GameService:Server_FlushCard(playHandle,msgName,tableId,param2,param3,param4,data)
    local hallHandle = assert(self._manager:GetPlayerHallHandle(playHandle),"player early enter hall")--玩家未加入系统 或者没有加入大厅   
    skynet.send(hallHandle,"lua","tapCard",playHandle,tableId,data) 
end

function GameService:GetServer()
    local server = self.super:GetServer()
    server.Net_DispatchCards = handler(self,self.Server_DispatchCards)
    server.Net_TapCard = handler(self,self.Server_TapCard)
    server.Net_FlushCard = handler(self,self.Server_FlushCard)
	return server
end 
return GameService