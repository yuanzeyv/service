local MoreModuleBaseService = require "Template.Service.MoreModuleBaseService" 
local HallFacade = class("HallFacade",MoreModuleBaseService)    
local TableModule = require "Template.Hall.Hall.Module.TableModule"   
local PlayerManager = require"Template.Hall.Hall.Manager.PlayerManager.PlayerManager" --大厅里面有桌子 
function HallFacade:GetHallID() --大厅的ID 
    return self._id 
end     
function HallFacade:GetName() 
    return self._name
end
function HallFacade:GetHallDataInfo()
    local ret = {} 
    ret.nowPlayer = self._playerMan:GetNowPlayerCount() 
    ret.maxPlayer = self._playerMan:GetMaxPlayerCount() 
    ret.hallID = self:GetHallID()
    ret.hallName = self:GetName() 
    return ret
end 
function HallFacade:GetEnterPlayer(userHandle)
    return self._playerMan:GetPlayer(userHandle) ~= nil --开始登录
end 
function HallFacade:Command_playerEnterHall(source,userHandle) --玩家进入大厅的消息 
    return self._playerMan:PlayerEnterHall(userHandle)--开始登录
end

function HallFacade:Command_playerLeaveHall(source,userHandle)    
    local tableMan = self:GetPlugin(self.SystemIndex.TABLE)  
    local statusRet = tableMan:LeaveTable(userHandle)
    if  statusRet ~= ErrorType.ExecuteSuccess then --清除玩家信息 
        return statusRet
    end  
    return  self._playerMan:PlayerLeaveHall(userHandle) 
end

function HallFacade:Command_RequestHallInfo(source,userHandle)  
    return self:GetHallDataInfo()
end

function HallFacade:RegisterCommand(commandTable)
    commandTable.playerEnterHall = handler(self,HallFacade.Command_playerEnterHall)--玩家加入大厅    
    commandTable.playerLeaveHall = handler(self,HallFacade.Command_playerLeaveHall)--玩家离开大厅
    commandTable.requestHallInfo = handler(self,HallFacade.Command_RequestHallInfo)--玩家请求大厅信息    
end

function HallFacade:Server_Request_HallInfo(sendObj,userHandle,param1,param2,param3,param4,str)     
    sendObj:SetCMD("Net_Request_HallInfo")  
    local player = self._playerMan:GetPlayer(userHandle)--获取到当前用户 
    if not player then --没有进入大厅 
        return ErrorType.NotLoginHall 
    end 
    local tableMan = self:GetPlugin(self.SystemIndex.TABLE) 
    sendObj:SetJson(tableMan:GetTableListInfo()) 
end  
function HallFacade:RegisterNetCommand(serverTable)  
    serverTable.Net_Request_HallInfo = handler(self,HallFacade.Server_Request_HallInfo)--请求所有桌子的消息  
end   

function HallFacade:InitSystemList(systemList) 
    systemList[self.SystemIndex.TABLE] = TableModule.new(self,self._tableData) 
end   

function HallFacade:HallInfo_Timer() --每10秒钟，对大厅所有玩家刷新一次消息
    local sendObj = BaseMessageObj.new(self,userHandle)   
    sendObj:SetCMD("Net_Request_HallInfo")
    sendObj:SetErrCode(ErrorType.ExecuteSuccess)
    sendObj:SetJson(self:GetHallDataInfo())
    for v,k in pairs(self._playerMan._playerArray:GetTable()) do 
        sendObj:SetUser(k:GetUserHandle())
        sendObj:Send()
    end 
    skynet.timeout(1000,handler(self,self.HallInfo_Timer))--每10秒钟向所有玩家广播 大厅最新动态消息
end  

--传参需要传入 大厅数目,每个大厅的桌子数目
function HallFacade:InitServerData(id,tableData)   
    self._id = assert(id,"hall id not setting")  
    self._tableData = assert(tableData.tableData,"param name miss")  
    self._name = assert(tableData.name,"param name miss")  
    self.SystemIndex = {TABLE = 1}     
    self._playerMan = PlayerManager.new(tableData)--人员管理类  
end  
--初始化系统
function HallFacade:InitSystem()   
    MoreModuleBaseService.InitSystem(self)
    --self:HallInfo_Timer()
end   
return HallFacade   