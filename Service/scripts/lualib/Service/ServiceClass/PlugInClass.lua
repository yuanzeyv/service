local PlugInClass = class("PlugInClass")    
function PlugInClass:GetSystemID()
    return self._manager:GetSystemID()
end  

function PlugInClass:GetManager()
    return self._manager  
end   

function PlugInClass:Init()
end 

local BaseModule = class("BaseModule")    
function BaseModule:ctor(manager, ...)   
    self:__InitData(manager, ...) --底层的数据初始化
    self:__Init() --底层的数据初始化
    self:InitModuleData(...)
    self:InitModule()
end
function PlugInClass:GetMan()
    return self._manager
end  
function BaseModule:__InitData(manager,...)   
    self._manager = manager   
    self._commandList = {}
    self._serviceList = {}
end 
function BaseModule:__Init()   
    self:RegisterCommand(self._commandList) 
    self:RegisterNetCommand(self._serviceList) 
end 
function PlugInClass:InitModuleData(...) 
end  
function PlugInClass:InitModule(...) 
end   
function PlugInClass:RegisterCommand(commandTable)
end 
function PlugInClass:RegisterNetCommand(serverTable)
end  
function PlugInClass:FindCommand(cmd)
    return self._commandList[cmd]
end 
function PlugInClass:FindService(cmd)
    return self._serviceList[cmd]
end  
return PlugInClass   