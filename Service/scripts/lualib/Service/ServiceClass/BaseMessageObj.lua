require "Tool.Json"
local BaseModule = class("BaseModule")    
function BaseModule:ctor(manager,...) 
    self._manager = assert(manager,"对象未传入")
    self:InitMessageData(...)
end 
function BaseModule:InitMessageData(userHandle)--传入要发送到何处
    self._userHandle = userHandle 
    self._param1 = 0
    self._param2 = 0
    self._param3 = 0
    self._param4 = 0
    self._string = ""
    self._CMD = nil
end   
function BaseModule:SetCMD(msgID)
    self._CMD = assert(msgID,string.format("系统(%s:%d):【%s】网络消息未找到",self._manager.__cname,self._manager:GetID(),msgID)) 
end 
function BaseModule:SetErrCode(value) 
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
    self:SetErrCode(param1 or 0)  
    self:SetParam2(param2 or 0) 
    self:SetParam3(param3 or 0) 
    self:SetParam4(param4 or 0) 
    self:SetString(string or "") 
end    
function BaseModule:Send(errCode)
    if not self._CMD then  return  end  
    if not self._userHandle then  return  end   
    if errCode then 
        self:SetErrCode(errCode)
    end 
    skynet.send(self._userHandle,"lua","write",self._CMD,self._param1,self._param2,self._param3,self._param4,self._string)  
end   
function BaseModule:GetUser()    
    return self._userHandle
end   
function BaseModule:SetUser(userHandle)    
    self._userHandle = userHandle
end   
return BaseModule