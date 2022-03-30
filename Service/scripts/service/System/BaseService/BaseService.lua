local BaseMessageObj = require "BaseService.BaseMessageObj" 
local ServiceModle = require "ServiceModle.ServiceModle"  
local BaseService = class("BaseService",ServiceModle)       
function BaseService:__InitData(systemID,...)
    BaseService.super.__InitData(self,...)   
    self._systemID = assert(systemID,"system is null " .. self.__cname)   
end
--获取到系统ID
function BaseService:GetSystemID()
    return self._systemID  
end    
function ServiceModle:__InitNetEventDispatch()   
    skynet.register_protocol{
        name = "client",
        id = skynet.PTYPE_CLIENT,
        pack = skynet.pack,
        unpack = skynet.unpack,
        dispatch = function(_,source,msgName,userHandle,param1,param2,param3,param4,str)  
            local handle = self:FindNetHandle(msgName) 
            if not handle then --未找到的话
                self:NotNetDispose(source,msgName,userHandle,param1,param2,param3,param4,str)
                return  
            end  
            print(msgName,handle,self.__cname)
            local sendObj = BaseMessageObj.new(self,userHandle,msgName)
            handle(sendObj,param1,param2,param3,param4,str)--网络消息没有call方法，不支持ret
            sendObj:Send()
        end
    }
end 
return BaseService  