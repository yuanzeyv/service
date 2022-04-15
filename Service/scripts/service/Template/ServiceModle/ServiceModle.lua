skynet = require "skynet"
require "skynet.manager"
require "Tool.Class"  
require("Config.Net_ErrorConfig")
require("Config.NetCommandConfig") 
local ServiceModle = class("ServiceModle")     
function ServiceModle:__InitEventDispatch()  
    skynet.dispatch("lua", function(session, source,command ,...) 
        local func = assert(self:FindCommandHandle(command),self.__cname .. ":没有找到对应的命令(" .. command .. ")") 
        skynet.ret(skynet.pack(func(source,...))) 
    end) 
end
function ServiceModle:__InitNetEventDispatch()   
    skynet.register_protocol{
        name = "client",
        id = skynet.PTYPE_CLIENT,
        pack = skynet.pack,
        unpack = skynet.unpack,
    }
end
function ServiceModle:ctor(...)  
    self:__InitData(...)
    self:__InitServer()
end
function ServiceModle:__InitData(...)   
    self:InitServerData(...)
    self._commandList = self:__GetCMD() 
    self._serviceList = self:__GetServer() 
end
function ServiceModle:__InitServer() 
	skynet.start(function () 
        self:__InitEventDispatch() 
        self:__InitNetEventDispatch()--初始化网络命令
        self:InitSystem() --初始化每个系统
	end)
end 
--初始化数据
function ServiceModle:InitServerData(...)      
end 
--初始化系统
function ServiceModle:InitSystem()   
end   
function ServiceModle:FindCommandHandle(command)
   return  self._commandList[command] 
end   
function ServiceModle:FindNetHandle(serviceName)
    return  self._serviceList[serviceName] 
end    
function ServiceModle:NotNetDispose(source,msgName,userHandle,param1,param2,param3,param4,str)
    print(self.__cname .. "没有找到对应的网络命令:"..msgName)
end  

function ServiceModle:RegisterCommand(commandTable)
end 
function ServiceModle:RegisterNetCommand(serverTable)
end 
function ServiceModle:__GetCMD()
    local CMD = {}  
    self:RegisterCommand(CMD)
	return CMD
end 
function ServiceModle:__GetServer()
    local server = {} 
    self:RegisterNetCommand(server)
	return server
end  
return ServiceModle  