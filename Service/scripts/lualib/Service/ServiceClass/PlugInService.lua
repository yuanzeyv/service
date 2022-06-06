local NetService = require "NetService"  
local PlugInService = class("PlugInService",NetService)   
PlugInService.SystemIndex = {}        
function PlugInService:GetPlugin( enum )
    return self._PlugInList[enum]
end   
 
function PlugInService:FindCommandHandle(command)  
    local func = NetService.FindCommandHandle(self,command) --寻找函数的
    if func then 
        return func
    end 
    for v,k in pairs(self._PlugInList) do  --系统列表
        func = k:FindCommand(command) --寻找命令
        if func then 
            return func
        end
    end      
end 
--父类的找寻网络消息的函数  
function PlugInService:FindNetHandle(msgName)  
    local handle = NetService.FindNetHandle(self,msgName) --寻找函数的
    if handle then 
        return handle
    end 
    for v,k in pairs(self._PlugInList) do 
        handle = k:FindService(msgName) 
        if handle then 
            return handle 
        end  
    end 
end       

function PlugInService:InitPlugInList( systemList )   
end 


function PlugInService:InitSystem()  
    self:InitPlugInList(self._PlugInList )  --初始化系统列表
    for v,k in pairs(self._PlugInList) do 
        k:Init()
    end    
end   
function PlugInService:__InitData(systemID,...)  
    NetService.__InitData(self,systemID,...)    
    self._PlugInList =  {}  --当前系统的列表 
end 
return PlugInService  