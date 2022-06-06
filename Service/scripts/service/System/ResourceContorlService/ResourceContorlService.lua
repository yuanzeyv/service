local BaseService = require "Template.Service.BaseService"     
local ResoucreControlService = class("ResoucreControlService",BaseService)  
function ResoucreControlService:Command_EnterSystem(source,userHandle)   
    return ErrorType.ExecuteSuccess --直接显示登入成功
end 

function ResoucreControlService:Command_LeaveSystem(userHandle,uid)   
    return ErrorType.ExecuteSuccess 
end  

function ResoucreControlService:Command_RequestSystem(source,userHandle)  
    local sendObj = BaseMessageObj.new(self,userHandle) 
    sendObj:SetCMD("Net_Request_PlayerInfo")
    sendObj:SetErrCode(ErrorType.ExecuteSuccess) 
    sendObj:Send() 
    return ErrorType.ExecuteSuccess  
end  
function ResoucreControlService:Command_RequestSimpleSystemMsg(source,userHandle)  
    local SystemInfo = {}  
    SystemInfo.id = self:GetSystemID()
    SystemInfo.name = self:GetSystemName()
    return SystemInfo   
end

function ResoucreControlService:GetSystemName()
    return "图片管理系统"
end 

function ResoucreControlService:RegisterCommand(commandTable)     
	commandTable.enter_system   = handler(self,ResoucreControlService.Command_EnterSystem) 
	commandTable.leave_system   = handler(self,ResoucreControlService.Command_LeaveSystem)
	commandTable.request_system = handler(self,ResoucreControlService.Command_RequestSystem)  
	commandTable.request_simple_system_msg = handler(self,ResoucreControlService.Command_RequestSimpleSystemMsg) 
end 

--收到断网请求
function ResoucreControlService:Server_DownLoad_Resource(sendObj,userHandle,param1,param2,param3,param4,str)     
    self:NetBreak(userHandle) --断网之后
end  

function ResoucreControlService:RegisterNetCommand(serverTable)
    serverTable.Net_DownLoad_Resource = handler(self,ResoucreControlService.Server_DownLoad_Resource)--进入桌子  
end   
local ResoucreControlService = ResoucreControlService.new(G_SysIDConf:GetTable().PlayerSystem) --这是角色系统