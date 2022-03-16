local SystemServiceList = require("Config.SystemServiceList").Instance()  
local NetCommandConfig = require("Config.NetCommandConfig").Instance() 
local SystemIDConfig = require("Config.SystemIDConfig").Instance()  
local skynet = require "skynet"
require "skynet.manager"
require "Tool.Class"
require "Tool.Json"
local SystemService = class("SystemService") 
function SystemService:GetCMD()
    local CMD = {}
	return CMD
end

function SystemService:Server_LoginSystem(source,msgName,systemId,param2,param3,param4,str) 
    assert(self._SystemList[systemId], "system not exist in the list" ) 
    local ret,systemID = skynet.call(self._SystemList[systemId],  "lua","login_system",source) --向系统中登入 用户 
    skynet.send(source,"lua","write",NetCommandConfig:FindCommand(self.systemID,"Net_LoginSystem_RET"),ret,systemID,1,1) 
    return ret
end

function SystemService:Server_LeaveSystem(source,msgName,systemId,param2,param3,param4,str)
    assert(self._SystemList[systemId], -1 )
    skynet.send(self._SystemList[systemId], "lua","unregister_agent",source)
    skynet.send(source,"lua","unregister_system",systemId)
    skynet.send(source,"lua","write",NetCommandConfig:FindCommand(self.systemID,"Net_LoginOutSystem_ret"),2,3,1,1)
end  

function SystemService:Server_RequestSystem(source,msgName,param1,param2,param3,param4,str)    
    local retTable = {}
    for v,k in pairs(self._SystemList) do
        local systemInfo = skynet.call(k, "lua","request_system_info")
        table.insert(retTable,systemInfo)
    end
    print(Json.Instance():Encode(retTable));
    skynet.send(source,"lua","write",NetCommandConfig:FindCommand(self.systemID,"Net_RequestSystem_RET"),0,999,1,1,Json.Instance():Encode(retTable))
end
 
function SystemService:GetServerList()
    local serverList = {} 
	serverList.Net_LoginSystem = handler(self,SystemService.Server_LoginSystem)
	serverList.Net_LeaveSystem = handler(self,SystemService.Server_LeaveSystem)
	serverList.Net_RequestSystem = handler(self,SystemService.Server_RequestSystem)
	return serverList
end  

function SystemService:InitEventDispatch()  
    skynet.dispatch("lua", function(session, source, command, ...)
        local f = assert(self._command[command])
        skynet.ret(skynet.pack(f(source, ...)))
    end)
    skynet.register_protocol {
        name = "client",
        id = skynet.PTYPE_CLIENT,
        unpack = skynet.unpack,
        dispatch =function(_,source,msgName,param1,param2,param3,param4,str) 
            local ret = nil 
            if self._serverList[msgName] then
                ret = self._serverList[msgName](source,msgName,param1,param2,param3,param4,str)
            end
            skynet.ret() 
        end
    }
end

function SystemService:InitServerData()
    local systemArray = assert(SystemServiceList:GetTable() ,"配置不全")
    self._command = self:GetCMD()
    self._SystemList = {} 
    
    self._ServiceInfoTable = systemArray
    self._serverList = self:GetServerList()
    self.systemID = SystemIDConfig:GetTable().SystemManager
end

function SystemService:ctor()   
    self:InitServerData()
    self:InitServer()
end

function SystemService:OpenAllSystem()
    for v,k in pairs(self._ServiceInfoTable) do  
        self._SystemList[v] = skynet.newservice(k,v)
    end
end

function SystemService:InitServer() 
	skynet.start(function ()  
        skynet.register(".SystemManager")
        self:InitEventDispatch()
        self:OpenAllSystem() 
	end) 
end  
local SystemService = SystemService.new()