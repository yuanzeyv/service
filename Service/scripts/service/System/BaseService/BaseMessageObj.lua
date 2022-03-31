require "Tool.Json"
local NetCommandConfig = require("Config.NetCommandConfig").Instance() 
local BaseModule = class("BaseModule")    
function BaseModule:ctor(manager,...) 
    self._manager = assert(manager,"对象未传入")
    self:InitMessageData(...)
end 
function BaseModule:InitMessageData(userHandle,cmd)
    self._userHandle = assert(userHandle,"没有传入发送对象")
    self._disposeCMD = assert(cmd,"未传入被处理的消息")
    self._param1 = 0
    self._param2 = 0
    self._param3 = 0
    self._param4 = 0
    self._string = ""
    self._CMD = nil
end  
function BaseModule:GetDisposeCMD()
    return self._disposeCMD
end 
function BaseModule:SetCMD(cmdName)
    self._CMD = assert(NetCommandConfig:FindCommand(self._manager:GetSystemID(),cmdName),string.format("系统(%s:%d):【%s】网络消息未找到",self._manager.__cname,self._manager:GetSystemID(),cmdName)) 
end 
function BaseModule:SetParam1(value) 
    self._param1 = assert(tonumber(value),"参数类型传入错误")
end  
function BaseModule:SetParam2(value)
    self._param2 = assert(tonumber(value),"参数类型传入错误")
end  
function BaseModule:SetParam3(value)
    self._param3 = assert(tonumber(value),"参数类型传入错误")
end  
function BaseModule:SetParam4(value)
    self._param4 = assert(tonumber(value),"参数类型传入错误")
end  
function BaseModule:SetString(value)
    self._string = assert(tostring(value),"参数类型传入错误")
end   

function BaseModule:SetJson(table) 
    self:SetString(Json.Instance():Encode(table))
end 
function BaseModule:SetParam(param1,param2,param3,param4,string)
    self:SetParam1(param1 or 0)  
    self:SetParam2(param2 or 0) 
    self:SetParam3(param3 or 0) 
    self:SetParam4(param4 or 0) 
    self:SetString(string or "") 
end    
function BaseModule:Send()
    if not self._CMD then  return  end   
    skynet.error(string.format("Message => msgID:%4d  param1:%5d   param2:%5d   param3:%5d   param4:%5d   str:%s",self._CMD,self._param1,self._param2,self._param3,self._param4,self._string == "" and "空数据" or self._string )) 
    skynet.send(self._userHandle,"lua","write",self._CMD,self._param1,self._param2,self._param3,self._param4,self._string)  
end   
function BaseModule:GetUser()    
    return self._userHandle
end   
return BaseModule