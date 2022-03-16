local skynet = require "skynet"
require "Tool.Class" 
local HallService = class("HallService")    
function HallService:ctor(manager, tableData)    
    self:InitData(manager,tableData)
end

function HallService:InitData(manager, tableData)    
    self._manager = manager  
    self._tableData = tableData   
    self._serviceList = self:GetServer() 
    self._commandList = self:GetCMD()  
end 

function  HallService:Init()  
end

function HallService:Command_playerEnterHall(userHandle)
    self._manager.PlayerEnterHall(userHandle)
    return 1
end

function HallService:Command_playerLeaveHall(userHandle)
    self._manager.PlayerLeaveHall(userHandle)
    return 1 
end
function HallService:Command_RequestHallInfo(userHandle) 
    return {hallName = "我的大厅",hallID = self._manager:GetID()}
end
 
function HallService:GetCMD()
    local CMD = {}  
    CMD.playerEnterHall = handler(self,self.Command_playerEnterHall)--玩家进入大厅
    CMD.playerleaveHall = handler(self,self.Command_playerLeaveHall)--玩家离开    
    CMD.requestHallInfo = handler(self,self.Command_RequestHallInfo)--玩家离开    
    return CMD
end
                                                                                                                                                              
function HallService:FindCommand(cmd)
    return self._commandList[cmd]
end

function HallService:FindService(cmd)
    return self._serviceList[cmd]
end 
   
function HallService:GetServer()
    local server = {}  
	return server
end 


return HallService