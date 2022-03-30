local BaseModule = require "BaseService.BaseModule" 
local HallModule = class("HallModule",BaseModule)       
function HallModule:InitModuleData(tableData)
    self._tableData = tableData --获取到自己的数据
end    

function HallModule:Command_playerEnterHall(userHandle)  
    local playerPlugin = self._manager:GetPlayerPlugin()--获取到玩家的插件 
    return  playerPlugin:PlayerEnterHall(userHandle)--玩家进入大厅 
end

function HallModule:Command_playerLeaveHall(userHandle)  
    local playerPlugin = self._manager:GetPlayerPlugin()--获取到玩家的插件
    return playerPlugin:PlayerLeaveHall(userHandle)  
end

function HallModule:Command_RequestHallInfo(userHandle) 
    return {hallName = "我的大厅",hallID = self._manager:GetHallID()}
end

function HallModule:RegisterCommand(commandTable)
    commandTable.playerEnterHall = handler(self,HallModule.Command_playerEnterHall)--玩家加入大厅    
    commandTable.playerLeaveHall = handler(self,HallModule.Command_playerLeaveHall)--玩家离开大厅
    commandTable.requestHallInfo = handler(self,HallModule.Command_RequestHallInfo)--玩家离开    
end 

function HallModule:RegisterNetCommand(serverTable)
end 
 
function  HallModule:Init()  
end
return HallModule