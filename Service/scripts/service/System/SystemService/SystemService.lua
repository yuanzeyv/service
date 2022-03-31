
local BaseService = require "BaseService.BaseService" 
local SystemService = class("SystemService",BaseService) 
require "Tool.Json"  
require "Tool.Class" 
require "skynet.manager"
local skynet = require "skynet"
require("Config.SystemIDConfig")
local SystemServiceList = require("Config.SystemServiceList")   
function SystemService:RegisterCommand(commandTable)
end
function SystemService:Server_LoginSystem(sendObj,systemId,param2,param3,param4,str) 
    local userHandle = sendObj:GetUser()--获取到用户的handle
    sendObj:SetCMD("Net_LoginSystem_RET")--设置返回消息
    sendObj:SetParam1(G_ErrorConf.ExecuteSuccess)--登入系统成功 
    sendObj:SetParam2(systemId)--设置返回消息 
    if not self._SystemList[systemId] then 
        sendObj:SetParam1(G_ErrorConf.SystemNotExist)--设置返回消息 
        return
    end  
    local loginRet = skynet.call(self._SystemList[systemId],"lua","login_system",userHandle) --向系统中登入 用户 
    sendObj:SetParam1(loginRet)--设置返回消息  
end

function SystemService:Server_LeaveSystem(sendObj,systemId,param2,param3,param4,str)
    local userHandle = sendObj:GetUser()--获取到用户的handle
    sendObj:SetCMD("Net_LoginOutSystem_ret")--设置返回消息
    sendObj:SetParam1(G_ErrorConf.ExecuteSuccess)--登入系统成功 
    sendObj:SetParam2(systemId)--设置返回消息  
    if not self._SystemList[systemId] then 
        sendObj:SetParam1(G_ErrorConf.SystemNotExist)--设置返回消息 
        return
    end  
    skynet.send(self._SystemList[systemId], "lua","unregister_agent",source)
    skynet.send(userHandle,"lua","unregister_system",systemId)
end  

function SystemService:Server_RequestSystem(sendObj,param1,param2,param3,param4,str)     
    local userHandle = sendObj:GetUser()--获取到用户的handle
    sendObj:SetCMD("Net_RequestSystem_RET")--设置返回消息
    local retTable = {}
    for v,k in pairs(self._SystemList) do
        local systemInfo = skynet.call(k, "lua","request_system_info")
        table.insert(retTable,systemInfo)
    end
    sendObj:SetJson(retTable)--返回一个字符串  
end
function SystemService:RegisterNetCommand(serverTable) 
	serverTable.Net_LoginSystem = handler(self,SystemService.Server_LoginSystem)
	serverTable.Net_LeaveSystem = handler(self,SystemService.Server_LeaveSystem)
	serverTable.Net_RequestSystem = handler(self,SystemService.Server_RequestSystem) 
end    

function SystemService:OpenAllSystem()
    for v,k in pairs(self._SystemServiceList:GetTable()) do 
        self._SystemList[v] = skynet.newservice(k,v)
    end
end 
--初始化数据
function SystemService:InitServerData(...)  
    self._SystemServiceList  = SystemServiceList.new()
    self._SystemList = {}    
end  
 
--初始化系统
function SystemService:InitSystem()   
    skynet.register(".SystemManager")
    self:OpenAllSystem()--初始化完毕后打开所有的系统
end   
local systemService = SystemService.new(G_SysIDConf:GetTable().SystemManager) 