local skynet = require "skynet"
require "Tool.Class" 
local HallService = class("HallService")    
function HallService:ctor(manager, tableData)   
    self:InitData(manager, tableData)
end

function HallService:InitData(manager, tableData)   
    self._hallPath = assert(tableData.hallPath,"hall path not find ")
    self._hallCount = tableData.hallCount or 3
    self._manager = manager  
    self._tableData = tableData  
    self._hallArray = {} --大厅列表
    self._commandList = self:GetCMD() 
    self._serviceList = self:GetServer() 
end 

function  HallService:Init() 
    for i= 1,self._hallCount do--创建几个大厅
        self._hallArray[i] =  skynet.newservice(self._hallPath,i )
    end
end 
    
function HallService:GetCMD()
    local CMD = {}  
    return CMD
end

function HallService:Server_EnterHall(playHandle,msgName,hallIndex,param2,param3,param4,str)
    local hallId = assert(self._hallArray[hallIndex],"not find hall")--没有找到这个大厅
    assert(self._manager:GetPlayer(playHandle),"player not enter system")
    assert(not self._manager:GetPlayerHallHandle(playHandle),"player early enter hall")--玩家未加入系统 或者没有加入大厅
    local enterStatus = skynet.call(hallId,"lua","playerEnterHall",playHandle)
    if enterStatus then 
        self._manager:playerEnterHall(playHandle,hallIndex)  
    end
    skynet.send(playHandle,"lua","write",NetCommandConfig:FindCommand(self.systemID,"Net_EnterHall_ret"),enterStatus)
end

function HallService:Server_LeaveHall(playHandle,msgName,param1,param2,param3,param4,str)
    assert(self._manager:GetPlayer(playHandle),"player not enter system")
    local hallHandle = assert(self._manager:GetPlayerHallHandle(playHandle),"player early enter hall")--玩家未加入系统 或者没有加入大厅
    local enterStatus = skynet.call(hallHandle,"lua","playerEnterHall",playHandle)
    if enterStatus then 
        self._manager:playerEnterHall(playHandle,hallHandle)  
    end
    skynet.send(playHandle,"lua","write",NetCommandConfig:FindCommand(self.systemID,"Net_LeaveHall_ret"),enterStatus)
end

function HallService:FindCommand(cmd)
    return self._commandList[cmd]
end 
function HallService:FindService(cmd)
    return self._serviceList[cmd]
end 
function HallService:GetServer()
    local server = {} 
    server.Net_EnterTable = handler(self,HallService.Server_EnterTable)--进入桌子
    server.Net_LeaveTable = handler(self,HallService.Server_LeaveTable)--离开桌子 
    return server
end 


return HallService