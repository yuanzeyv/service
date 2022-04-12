--用户在登入一个系统的时候，会将信息传送给Agnet任务
--Agent服务会保存用户的所有信息
--之后当用户进入了系统后，会伴随着将用户的所有信息传入到系统中去
--之后用户会在譬如大厅等系统中，来自行传递当前的用户信息
local BaseService = require "Template.Service.BaseService" 
local SystemService = class("SystemService",BaseService)  
local SystemServiceList = require("SystemService.SystemServiceList")   

function SystemService:Command_AuthSuccess(userHandle,systemTable,uid)--登录验证成功的消息   
    --循环遍历所有的系统信息
    for v,k in pairs(self._SystemServiceList:GetTable()) do 
        table[G_SysIDConf:GetTable().PlayerSystem] = {path = "PlayerInfoService/PlayerInfoService",autoLogin = true,requestData = true}
        --判断是否登入过，没有的话 就自动登入一下
        if k.autoLogin and not systemTable[v] then  
            skynet.call(self._SystemList[v],"lua","enter_system",userHandle,uid) --向系统中登入 用户  
        end  
        --登录成功后是否想客户端发送登录请求
        local _ = ( systemTable[v] or k.autoLogin )  and skynet.call(self._SystemList[v],"lua","request_system",userHandle) --同步等待所有消息执行完毕后 
    end
    --想客户端发送一个初始化完成的消息，算是结束 
    local sendObj = BaseMessageObj.new(self,userHandle) 
    sendObj:SetCMD("Net_SystemInitSuccess") 
    sendObj:SetJson({s = "999",b = 888})
    sendObj:Send()
end 
 
function SystemService:RegisterCommand(commandTable)   
	commandTable.auth_success = handler(self,SystemService.Command_AuthSuccess) 
end
function SystemService:Server_LoginSystem(sendObj,userHandle,systemId,param2,param3,param4,str)  
    sendObj:SetCMD("Net_LoginSystem")--设置返回消息 
    sendObj:SetParam2(systemId)--设置返回消息 
    if not self._SystemList[systemId] then 
        return G_ErrorConf.SystemNotExist --设置返回消息  
    end  
    return skynet.call(self._SystemList[systemId],"lua","enter_system",userHandle) --向系统中登入 用户  
end

function SystemService:Server_LeaveSystem(sendObj,userHandle,systemId,param2,param3,param4,str) 
    sendObj:SetCMD("Net_LoginOutSystem")--设置返回消息 
    sendObj:SetParam2(systemId)--设置返回消息  
    if not self._SystemList[systemId] then 
        return G_ErrorConf.SystemNotExist --设置返回消息 
    end  
    return skynet.call(self._SystemList[systemId], "lua","leave_system",source)  
end  

function SystemService:Server_RequestSystem(sendObj,userHandle,param1,param2,param3,param4,str)      
    sendObj:SetCMD("Net_RequestSystem")--设置返回消息
    local retTable = {}
    for v,k in pairs(self._SystemList) do
        local systemInfo = skynet.call(k, "lua","request_system")
        table.insert(retTable,systemInfo)
    end
    sendObj:SetJson(retTable)--返回一个字符串  
    return G_ErrorConf.ExecuteSuccess
end
function SystemService:RegisterNetCommand(serverTable) 
	serverTable.Net_LoginSystem = handler(self,SystemService.Server_LoginSystem)
	serverTable.Net_LeaveSystem = handler(self,SystemService.Server_LeaveSystem)
	serverTable.Net_RequestSystem = handler(self,SystemService.Server_RequestSystem) 
end    

function SystemService:OpenAllSystem()
    for v,k in pairs(self._SystemServiceList:GetTable()) do  
        self._SystemList[v] = skynet.newservice(k.path,v)
    end
end  
--初始化数据
function SystemService:InitServerData(...)   
    self._SystemServiceList  = SystemServiceList.new()
    self._SystemList = {}     
end  
 
--初始化系统
function SystemService:InitSystem()   
    skynet.register(".SystemManager")
    self:OpenAllSystem()--初始化完毕后打开所有的系统
end   
local systemService = SystemService.new(G_SysIDConf:GetTable().SystemManager) 