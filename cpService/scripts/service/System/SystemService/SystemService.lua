local NetService = require "NetService"
local SystemService = class("SystemService",NetService)  
local BaseMessageObj = require "BaseMessageObj"  
function SystemService:Command_AuthSuccess(source,userHandle,systemTable,uid)
    for v,k in pairs(self._SystemServiceList) do --循环遍历所有的系统信息  
        if  not systemTable[v] and k.autoLogin then --如果当前没有登入自动登入的系统 
            local isSuccess = skynet.call(self._SystemList[v],"lua","enter_system",userHandle) 
        end  
        if ( systemTable[v] or k.autoLogin ) and k.requestData then--登录成功后是否想客户端发送登录请求 
            skynet.call(self._SystemList[v],"lua","request_system",userHandle) --同步等待所有消息执行完毕后 
        end 
    end
    local sendObj = BaseMessageObj.new(self,userHandle)     --想客户端发送一个初始化完成的消息，算是结束 
    sendObj:SetCMD(4)  
    sendObj:Send()
end  

function SystemService:RegisterCommand(commandTable)   
	commandTable.auth_success = handler(self,SystemService.Command_AuthSuccess)--当一个用户验证成功之后，程序便会对这个用户进行全部系统登入 
end 

function SystemService:Server_LoginSystem(sendObj,userHandle,systemId,param2,param3,param4,str)   
    sendObj:SetCMD(1)
    sendObj:SetParam2(systemId)
    if not self._SystemList[systemId] then 
        return ErrorType.SystemNotExist 
    end  
    return skynet.call(self._SystemList[systemId],"lua","enter_system",userHandle) 
end

function SystemService:Server_LeaveSystem(sendObj,userHandle,systemId,param2,param3,param4,str) 
    sendObj:SetCMD(2)--设置返回消息 
    sendObj:SetParam2(systemId)--设置返回消息  
    if not self._SystemList[systemId] then 
        return ErrorType.SystemNotExist 
    end--设置返回消息  
    return skynet.call(self._SystemList[systemId], "lua","leave_system",userHandle)  
end  

function SystemService:Server_RequestSystem(sendObj,userHandle,param1,param2,param3,param4,str)     
    sendObj:SetCMD(3)--设置返回消息
    local retTable = {}
    for v,k in pairs(self._SystemList) do
        local systemInfo = skynet.call(k, "lua","request_simple_system_msg") 
        table.insert(retTable,systemInfo)
    end
    sendObj:SetJson(retTable)--返回一个字符串  
    return ErrorType.ExecuteSuccess
end
function SystemService:RegisterNetCommand(serverTable) 
	serverTable.Net_LoginSystem = handler(self,SystemService.Server_LoginSystem)
	serverTable.Net_LeaveSystem = handler(self,SystemService.Server_LeaveSystem)
	serverTable.Net_RequestSystem = handler(self,SystemService.Server_RequestSystem) 
end    

function SystemService:OpenAllSystem() 
    for v,k in pairs(self._SystemServiceList) do   
        self._SystemList[v] = skynet.newservice(k.path,v)
    end 
end  
--初始化数据
function SystemService:InitServerData(...)   
    self._SystemServiceList = {}
    self._SystemList = {}     
end  
  

--初始化系统
function SystemService:InitSystem()   
    skynet.register(".SystemManager")
    self._SystemServiceList = self:RetrievalTable("con_SystemSetting")
    self:OpenAllSystem()--初始化完毕后打开所有的系统
end    
local systemService = SystemService.new("SystemManager") 