local skynet = require "skynet"
require "Tool.Json"
require "Tool.Class"  
local NetCommandConfig = require("Config.NetCommandConfig").Instance() 
local SystemService = class("SystemService")    
function SystemService:ctor(manager)   
    self:InitData(manager)
end
function SystemService:InitData(manager)   
    self._manager = manager   
    self._commandList = self:GetCMD() 
    self._serviceList = self:GetServer()  
end 

function  SystemService:Init()
end   
function SystemService:Command_Request_SystemInfo(source) 
    local SystemInfo = {}  
    SystemInfo.id = self._manager:GetSystemID()
    SystemInfo.name = "接竹竿" 
    return SystemInfo  
end 
function SystemService:GetCMD()
    local CMD = {}    
    CMD.request_system_info = handler(self,SystemService.Command_Request_SystemInfo)
    return CMD
end  

function SystemService:Net_Request_HallList(playHandle,msgName,param1,param2,param3,param4,str)   
    local hallInfo = {} 
    local hallList = self._manager:GetHallInfo()
    for v,k in pairs(hallList) do  
        local hallDes = skynet.call(k,"lua","requestHallInfo")
        hallInfo[v] =  hallDes 
    end     
    skynet.send(playHandle,"lua","write",NetCommandConfig:FindCommand(self._manager:GetSystemID(),"Net_Request_HallList_RET"),0,0,1,1,Json.Instance():Encode(hallInfo))
end 

function SystemService:FindCommand(cmd)
    return self._commandList[cmd]
end 
function SystemService:FindService(cmd)
    return self._serviceList[cmd]
end 
function SystemService:GetServer()
    local server = {}  
    server.Net_Request_HallList = handler(self,SystemService.Net_Request_HallList)--离开桌子 
    return server
end 
 
return SystemService