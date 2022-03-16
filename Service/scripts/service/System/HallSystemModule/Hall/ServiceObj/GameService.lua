local skynet = require "skynet"
require "Tool.Class" 
local GameService = class("GameService")    
function GameService:ctor(manager, tableData)   
    self:InitData(manager, tableData)
end

function GameService:InitData(manager, tableData)   
    self._manager = manager  
    self._tableData = tableData 
    self._commandList = self:GetCMD() 
    self._serviceList = self:GetServer() 
end 

function  GameService:Init()
end 
 
function GameService:GetCMD()
    local CMD = {}  
	return CMD
end 

function GameService:FindCommand(cmd)
    return self._commandList[cmd]
end 
function GameService:FindService(cmd)
    return self._serviceList[cmd]
end  

function GameService:GetServer()
    local server = {} 
	return server
end 


return GameService