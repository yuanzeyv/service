ErrorType = require "PragramConfig/ErrorType"
skynet = require "skynet" 
require "skynet.manager"
require "Tool.Class"  
require "Tool.Tool"  
local Service = class("Service")    
function Service:GetHandle()--获取到服务的句柄
    return self._serviceHandle
end  
--初始化事件派发函数
function Service:__InitEventDispatch()  
    skynet.dispatch("lua", function(session, source,command ,...)   
        local func = assert(self:FindCommandHandle(command),self.__cname .. ":没有找到对应的命令(" .. command .. ")")  
        skynet.ret(skynet.pack(func(source,...))) 
    end) 
end 
function Service:ctor(...)  
    self:__InitServerData(...) --初始化服务初始数据
    self:InitServerData(...)  
    self:__InitServer()  --开始执行正确的赋值语句
    self:InitServer() 
    self:__StartServer() --开始执行服务
end
function Service:__InitServerData(...) 
    self._serviceHandle = skynet.self() --获取到自己的句柄
    self._commandList = {} 
end
function Service:__InitServer() 
    self:RegisterCommand(self._commandList)  
end 
--初始化系统
function Service:__InitSystem()   
end   

function Service:__StartServer()
	skynet.start(function () 
        self:__InitEventDispatch()  
        self:__InitSystem()
        self:InitSystem() --初始化每个系统
	end)
end 

function Service:FindCommandHandle(command)
   return  self._commandList[command] 
end     

function Service:RegisterCommand(commandTable)
    --初始化数据
end  
function Service:InitServerData(...)      
end 
function Service:InitServer()      
end  
--初始化系统
function Service:InitSystem()   
end   

return Service  