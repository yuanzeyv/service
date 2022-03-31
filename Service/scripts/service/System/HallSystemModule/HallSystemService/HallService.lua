local BaseModule = require "BaseService.BaseModule" 
local HallService = class("HallService",BaseModule)     
function HallService:InitModuleData(tableData)
    self._hallPath = assert(tableData.hallPath,"hall path not find ")
    self._hallCount = tableData.hallCount or 3 --创建大厅的个数 
    self._tableData = tableData --表数据
    self._hallArray = {} --大厅列表  
end   

function HallService:RegisterCommand(commandTable)
end 

function HallService:Server_EnterHall(sendObj,hallIndex,param2,param3,param4,str)   
    sendObj:SetCMD("Net_EnterHall")
    local userHandle = sendObj:GetUser()--获取到当前的用户
    if self:IsEnterHall(userHandle) then--如果当前用户已经进入了大厅的话
        sendObj:SetParam1(G_ErrorConf.LoginHallEarlie)--很早就进入了大厅
        return 
    end   
    local hallHandle = self:HallIsExist(hallIndex) --如果当前大厅不存在的话
    if not hallHandle then 
        sendObj:SetParam1(G_ErrorConf.HallNotExist) --返回当前大厅不存在
        return 
    end   
    local enterStatus = skynet.call(hallHandle.hallService,"lua","playerEnterHall",userHandle)--向大厅发送登入的消息
    local hallInfo = skynet.call(hallHandle.hallService,"lua","requestHallInfo")--向大厅发送登入的消息
    self:EnterHall(userHandle,hallIndex) --玩家加入大厅   
    sendObj:SetJson(hallInfo)--设置大厅信息返回
end

function HallService:Server_LeaveHall(sendObj,param1,param2,param3,param4,str) 
    sendObj:SetCMD("Net_LeaveHall")
    local userHandle = sendObj:GetUser()--获取到当前的用户
    local hallIndex = self:IsEnterHall(userHandle)  --获取到大厅角色信息
    if not playerInfo then--如果当前用户已经进入了大厅的话
        sendObj:SetParam1(G_ErrorConf.NotLoginHall)--很早就进入了大厅
        return 
    end    
    local hallHandle = self:HallIsExist(hallIndex) --如果当前大厅不存在的话
    if not hallHandle then 
        sendObj:SetParam1(G_ErrorConf.HallNotExist) --返回当前大厅不存在
        return 
    end    
    local leaveStatus = skynet.call(hallId,"lua","playerLeaveHall",playHandle)--离开时会发送消息
    if leaveStatus ~= G_ErrorConf.table.ExecuteSuccess then 
        sendObj:SetParam1(G_ErrorConf.leaveStatus) --离开大厅失败的情况
        return 
    end 
    self:LeaveHall(playHandle,hallHandle) 
end
--请求大厅信息
function HallService:Server_RequestHallList(sendObj,param1,param2,param3,param4,str)   
    sendObj:SetCMD("Net_Request_HallList")
    local hallInfo = {} 
    for v,k in pairs(self._hallArray) do --循环比那里当前大厅数据
        local hallDes = skynet.call(k.hallService,"lua","requestHallInfo")--取到大厅的描述
        hallInfo[v] = hallDes--加入大大厅队列中
    end
    sendObj:SetJson(hallInfo)
end 

function HallService:RegisterNetCommand(serverTable)
    serverTable.Net_EnterHall = handler(self,HallService.Server_EnterHall)--进入桌子
    serverTable.Net_LeaveHall = handler(self,HallService.Server_LeaveHall)--离开桌子 
    serverTable.Net_Request_HallList = handler(self,HallService.Server_RequestHallList)--请求大厅信息 
end  

function  HallService:CreateHallService() 
    for i= 1,self._hallCount do--创建几个大厅 
        self._hallArray[i] = {}
        self._hallArray[i].playerList = {} 
        self._hallArray[i].onlineCount = 0 
        self._hallArray[i].hallService = skynet.newservice(self._hallPath,self:GetSystemID(),i) 
    end
end 
  
--查询是否存在大厅
function HallService:HallIsExist(hallIndex)
    return self._hallArray[hallIndex]
end 
--获取到大厅的列表
function HallService:GetHallList() 
    return self._hallArray
end 
   
--查询是否存在大厅
function HallService:GetHallHandle(hallIndex)
    local hallTable = self:HallIsExist(hallIndex)
    if not hallTable then 
        return false
    end  
    return self._hallArray[hallIndex].hallService
end 
  
--判断角色是否进入了大厅
function HallService:IsEnterHall(playHandle)  
    for v,k in pairs(self._hallArray) do 
        if k.playerList[playHandle] then 
            return k.playerList[playHandle] 
        end   
    end 
    return false 
end  

function HallService:EnterHall(playHandle,hallIndex) 
    local hallTable = self:HallIsExist(hallIndex)
    if not hallTable or hallTable.playerList[playHandle] then 
        return false
    end   
    hallTable.onlineCount = hallTable.onlineCount + 1
    hallTable.playerList[playHandle] = hallIndex
    return true 
end

function HallService:LeaveHall(playHandle,hallIndex)
    local hallTable = self:HallIsExist(hallIndex)
    if not hallTable then 
        return false
    end    
    hallTable.onlineCount = hallTable.onlineCount - 1
    hallTable.playerList[playHandle] = nil
    return true 
end 
function  HallService:Init() 
    self:CreateHallService() 
end
return HallService 