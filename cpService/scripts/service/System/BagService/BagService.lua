local BaseService = require "Template.Service.BaseService"     
local BagService = class("BagService",BaseService)  
function BagService:Command_EnterSystem(source,userHandle)   
    return ErrorType.ExecuteSuccess --直接显示登入成功
end 

function BagService:Command_LeaveSystem(userHandle,uid)   
    return ErrorType.ExecuteSuccess 
end  

function BagService:Command_RequestSystem(source,userHandle)  
    return ErrorType.ExecuteSuccess  
end  

function BagService:Command_RequestSimpleSystemMsg(source,userHandle)  
    local SystemInfo = {}  
    SystemInfo.id = self:GetSystemID()
    SystemInfo.name = self:GetSystemName()
    return SystemInfo   
end

function BagService:GetSystemName()
    return "背包系统"
end 

function BagService:RegisterCommand(commandTable)     
	commandTable.enter_system   = handler(self,BagService.Command_EnterSystem) 
	commandTable.leave_system   = handler(self,BagService.Command_LeaveSystem)
	commandTable.request_system = handler(self,BagService.Command_RequestSystem)  
	commandTable.request_simple_system_msg = handler(self,BagService.Command_RequestSimpleSystemMsg) 
end  

function BagService:RegisterNetCommand(serverTable) 
end   
local BagService = BagService.new(G_SysIDConf:GetTable().PlayerSystem) --这是角色系统