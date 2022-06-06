local MoreModuleBaseService = require "Template.Service.MoreModuleBaseService" 
local HallSystemService = class("HallSystemService",MoreModuleBaseService)    
function HallSystemService:GetHallPlugin()
    return self:GetPlugin(self.SystemIndex.HALL)
end  
 
function HallSystemService:GetSystemName()
    return self._systemName  
end      
 
function HallSystemService:NotNetDispose(source,msgName,userHandle,param1,param2,param3,param4,str)   
    assert(self:IsEnterSystem(userHandle),ErrorType.NotLoginSystem) 
    local hallPlugin   = self:GetHallPlugin()  --获取到大厅插件 
    local hallInfo = assert(hallPlugin:GetPlayerEnterHall(userHandle),ErrorType.NotLoginHall) 
    skynet.send(hallInfo.HallHandle,"client",msgName,userHandle,param1,param2,param3,param4,str)--开始转发
end  
 
--父类的start函数钩子
function HallSystemService:InitSystemList(systemList) 
    systemList[self.SystemIndex.HALL] =   self._hallData.obj.new(self,self._hallData)  
end  

--需要重写 用于获取系统信息
function HallSystemService:Command_RequestSimpleSystemMsg(source) 
    local SystemInfo = {}  
    SystemInfo.id = self:GetSystemID()
    SystemInfo.name = self:GetSystemName()
    return SystemInfo  
end 

--角色登录系统
function HallSystemService:Command_EnterSystem(source,playHandle) 
    if self:IsEnterSystem(playHandle) then --如果当前角色已经进入了系统的hua
        return ErrorType.RepetSystem --返回玩家重复登入
    end 
    local registerRet = skynet.call(playHandle,"lua","register_system",self:GetSystemID(),skynet.self()) 
    if registerRet ~= ErrorType.ExecuteSuccess then  
        return registerRet
    end   
    self:EnterSystem(playHandle)--角色记录当前系统 
    return ErrorType.ExecuteSuccess 
end
     
--角色离开系统
function HallSystemService:Command_LeaveSystem(source,playHandle) 
    if not self:IsEnterSystem(playHandle)  then --获取到当前用户是否登入了系统
        return ErrorType.NotLoginSystem
    end
    local hallPlugin   = self:GetHallPlugin()  --获取到大厅插件 
    local hallIndex = hallPlugin:GetPlayerEnterHall(playHandle)--玩家登入的大厅索引
    if hallIndex then
        return ErrorType.LoginHallEarlie
    end     
    local registerRet = skynet.call(playHandle,"lua","unregister_system",self._manager:GetSystemID(),skynet.self()) 
    if registerRet ~= ErrorType.ExecuteSuccess then  
        return registerRet
    end  
    self:LeaveSystem(playHandle) 
    return ErrorType.ExecuteSuccess 
end
   
function HallSystemService:Command_RequestSystem(source,userHandle)
    --系统会将 角色需要的所有系统消息
end  

function HallSystemService:RegisterCommand(commandTable)   
	commandTable.enter_system   = handler(self,HallSystemService.Command_EnterSystem)
	commandTable.leave_system   = handler(self,HallSystemService.Command_LeaveSystem)
	commandTable.request_system = handler(self,HallSystemService.Command_RequestSystem) 
	commandTable.request_simple_system_msg = handler(self,HallSystemService.Command_RequestSimpleSystemMsg)   
end  

function HallSystemService:EnterSystem(playHandle) 
    self._systemPlayers[playHandle] = true --登入系统后,为玩家赋值一个表
end

function HallSystemService:LeaveSystem(playHandle)  
    self._systemPlayers[playHandle] = nil       --然后再次离开系统
end

function HallSystemService:IsEnterSystem(playHandle)  
   return self._systemPlayers[playHandle]      --有数据则代表进入了大厅
end   

function HallSystemService:InitServerData(tableData)   
    self._hallData = assert(tableData.hallData,"param name miss") --需要一个大厅的类对象
    self._systemData = assert(tableData.systemData,"param name miss")--需要一个系统的类对象
    self._systemName = tableData.systemName or "系统未命名"   --需要一个系统名称 
    self.SystemIndex = {HALL = 1}    
    self._systemPlayers = {}--只负责保存角色登录信息 
end 
return HallSystemService