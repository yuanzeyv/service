local BaseModule = require "BaseService.BaseModule" 
local PlayerModule = class("PlayerModule",BaseModule)     
local PlayerManager = require "HallSystemModule.Hall.StructManager.PlayerManager"

function PlayerModule:InitModuleData(tableData) 
    self._tableData = tableData --获取到自己的数据 
    self._playerMan = PlayerManager.new(tableData) --人员管理类 
end   

function PlayerModule:RegisterCommand(commandTable)  
end 


function PlayerModule:RegisterNetCommand(serverTable)
end 
         
function PlayerModule:PlayerEnterHall(playerHandle)
   return self._playerMan:PlayerEnterHall(playerHandle)
end     
    
function PlayerModule:PlayerLeaveHall(playerHandle)
    return self._playerMan:PlayerLeaveHall(playerHandle)
end    

function PlayerModule:GetManager(playerHandle)
    return self._playerMan
end    

function PlayerModule:Init()
end     
return PlayerModule