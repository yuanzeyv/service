skynet = require "skynet"
require "Tool.Class" 
local BaseModule = class("BaseModule")    
function BaseModule:ctor(manager, ...)   
    self:__InitData(manager, ...) 
end
function BaseModule:__InitData(manager,...)   
    self._manager = manager   
    self:InitModuleData(...)
    self._commandList = self:__GetCMD() 
    self._serviceList = self:__GetServer() 
end

function BaseModule:InitModuleData(...) 
end  

function BaseModule:RegisterCommand(commandTable)
end 
function BaseModule:RegisterNetCommand(serverTable)
end 
function BaseModule:GetMan()
    return self._manager
end 
function BaseModule:__GetCMD()
    local CMD = {}  
    self:RegisterCommand(CMD)
	return CMD
end 
function BaseModule:__GetServer()
    local server = {} 
    self:RegisterNetCommand(server)
	return server
end  
function BaseModule:FindCommand(cmd)
    return self._commandList[cmd]
end 
function BaseModule:FindService(cmd)
    return self._serviceList[cmd]
end  
return BaseModule