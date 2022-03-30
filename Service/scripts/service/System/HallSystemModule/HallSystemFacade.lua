local BaseService = require "BaseService.BaseService" 
local HallSystemModule = class("HallSystemModule",BaseService)  
HallSystemModule.SystemIndex = {HALL = 1,SYSTEM = 2}     
--获取到大厅插件
function HallSystemModule:GetHallPlugin()
    return self._SystemList[self.SystemIndex.HALL]
end 
--获取到系统插件
function HallSystemModule:GetSystemPlugin()
    return self._SystemList[self.SystemIndex.SYSTEM]
end 

function HallSystemModule:GetSystemName()
    return self._systemName  
end   
     
--传递消息到大厅
function HallSystemModule:NotNetDispose(source,msgName,userHandle,param1,param2,param3,param4,str) 
    local systemPlugin = self:GetSystemPlugin()--获取到玩家插件
    local hallPlugin = self:GetHallPlugin()--获取到大厅插件
    assert(systemPlugin:IsEnterSystem(playHandle),"player not enter system")--判断当前玩家有没有加入到系统
    local hhallHandle = assert(hallPlugin:IsEnterHall(playHandle),"player not enter hall") --当前王佳是否加入到了这个大厅内
    skynet.send(hhallHandle,"client",msgName,userHandle,param1,param2,param3,param4,str)--参数一位用户句柄 其余的原封不动传入（因为发送给大厅，所以）
end

--父类的找寻 命令函数
function HallSystemModule:FindCommandHandle(command) 
    local func = nil --寻找函数的
    for v,k in pairs(self._SystemList) do  --系统列表
        func = k:FindCommand(command) --寻找命令
        if func then break end  --如果寻找到了的话，返回 
    end     
    return func
end 
--父类的找寻网络消息的函数  
function HallSystemModule:FindNetHandle(msgName)
    local handle = nil
    for v,k in pairs(self._SystemList) do 
        handle = k:FindService(msgName)
        
    print("Rnyrt asd " ,k.__cname)
        if  handle then break end  
    end    
    return handle
end      

--传参需要传入 大厅数目,每个大厅的桌子数目
function HallSystemModule:InitServerData(tableData)   
    self._hallData = assert(tableData.hallData,"param name miss") 
    self._systemData = assert(tableData.systemData,"param name miss") 
    self._systemName = tableData.systemName or "未设置名称"
    self._name = assert(tableData.serviceName,"param name miss")  
    self._SystemList =  {}  
    self:InitSystemList()   
end
 
--父类的start函数钩子
function HallSystemModule:InitSystemList() 
    self._SystemList[self.SystemIndex.HALL] =   self._hallData.obj.new(self,self._hallData)
    self._SystemList[self.SystemIndex.SYSTEM] = self._systemData.obj.new(self,self._systemData)
end 

function HallSystemModule:InitSystem() 
    skynet.register(self._name)
    for v,k in pairs(self._SystemList) do 
        k:Init()
    end   
end    
return HallSystemModule  