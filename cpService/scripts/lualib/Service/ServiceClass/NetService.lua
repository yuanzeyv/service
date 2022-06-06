local BaseMessageObj = require "BaseMessageObj"
local ConfigObj =  require "ConfigObj"
local ServiceDB = require "ServiceDB" 
SystemConfig = require "PragramConfig/SystemConfig"

local NetService = class("NetService",ServiceDB)        
function NetService:GetID()--必须在InitSystem中 或者 服务创建完成后，才可以使用
    return self._SystemConfig.SysID
end   

function NetService:GetName()--必须在InitSystem中 或者 服务创建完成后，才可以使用
    return self._SystemName
end    

function NetService:__InitServerData(systemName,...)    
    ServiceDB.__InitServerData(self,...)--调用父类的初始化函数
    self._configObj = nil --配置服务对象
    self._SystemName = assert(systemName,"systemName is Empty") 
    self._SystemConfig = nil
    self._netMessageTable = {} 
    self._serviceHandleList = {} --网络消息列表
end 

function NetService:__InitServer() 
    ServiceDB.__InitServer(self) 
    self:RegisterNetCommand(self._serviceHandleList) 
end    

--初始化系统
function NetService:__InitSystem() 
    ServiceDB.__InitServer(self)   
    self._configObj = ConfigObj.new()--配置服务对象 
    self._SystemConfig = assert(SystemConfig[self._SystemName],"not exist system config")--获取到相关系统数据  
    self:InitNetMessageTable(self._netMessageTable)
end   

function NetService:FindNetHandle(msgID)
    local netConfig = self._netMessageTable[msgID] 
    if not netConfig then 
        return nil
    end
    return  self._serviceHandleList[netConfig.msg] 
end 

--寻找网络表中合适的数据
function NetService:InitNetMessageTable(messageTable) 
    local netTable = self:RetrievalTable("con_NetCommand")--获取到网络表信息
    for v,k in pairs(netTable) do
        if k.sys == self._SystemConfig.SysID or self._SystemConfig.ListenAllMsg then 
            messageTable[v] = k
        end  
    end  
end 

function NetService:RegisterNetCommand(serverTable)
end  

function NetService:NotNetDispose(source,msgName,userHandle,param1,param2,param3,param4,str)
    print(self.__cname .. "无法处理当前网络消息:"..msgName)
end  

--初始化事件派发函数
function NetService:__InitEventDispatch()  
    ServiceDB.__InitEventDispatch(self)  
    self:__InitNetEventDispatch() --顺便再初始化一下网络
end 

function NetService:__InitNetEventDispatch() 
    self:ConnectRedis() --网络服务一定会连接上redis，以达到表数据整个内存就一份的目的  
    skynet.register_protocol{
        name = "client",
        id = skynet.PTYPE_CLIENT,
        pack = skynet.pack,
        unpack = skynet.unpack,
        dispatch = function(_,source,msgID,userHandle,param1,param2,param3,param4,str)  
            --首先判断消息是否属于当前系统
            local handle = self:FindNetHandle(msgID) 
            if handle then --未找到的话
                local sendObj = BaseMessageObj.new(self,userHandle,msgName,source)  
                sendObj:Send( handle(sendObj,userHandle,param1,param2,param3,param4,str) )
            else 
                self:NotNetDispose(source,msgName,userHandle,param1,param2,param3,param4,str) 
            end    
        end
    }
end 
--数据表的代理函数
function NetService:RetrievalTable(tableName)
    return self._configObj:RetrievalTable(tableName) 
end 
 
function NetService:RetrievalFiled(tableName,filedName)
    return self._configObj:RetrievalFiled(tableName,filedName) 
end
return NetService     