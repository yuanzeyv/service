local BaseModule = require "Template.Service.BaseModule" 
local HallModule = class("HallModule",BaseModule)     
function HallModule:InitModuleData(tableData) 
    self._hallPath = assert(tableData.hallPath,"hall path not find ")
    self._hallCount = tableData.hallCount or 3 --创建大厅的个数 
    self._tableData = tableData --表数据
    self._hallArray = {} --大厅列表  
end   

function HallModule:RegisterCommand(commandTable)
end 

function HallModule:Server_EnterHall(sendObj,userHandle,hallIndex,param2,param3,param4,str)   
    sendObj:SetCMD("Net_EnterHall") 
    local sysManager = self._manager:GetSystemPlugin()
    if not sysManager:GetPlayer(playHandle)  then --获取到当前用户是否登入了系统
        return G_ErrorConf.NotLoginSystem
    end  
    local hallIndex = sysManager:GetPlayerHallHandle(userHandle)--玩家登入的大厅索引
    if not hallIndex then
        return G_ErrorConf.NotLoginHall
    end    
    local hallInfo = self:GetHall(hallIndex)
    if not hallInfo then --没有找到与索引对应的大厅
        return G_ErrorConf.HallNotExist 
    end   
    if not self:IsEnterHall(hallIndex,userHandle)  then--本模块是当前角色是否进入了大厅
        return G_ErrorConf.DataChaos--数据混乱
    end        
    local enterStatus = skynet.call(hallInfo.HallModule,"lua","playerEnterHall",userHandle)--向大厅发送登入的消息
    if enterStatus ~=  G_ErrorConf.ExecuteSuccess  then--当前没有执行成功的haunt
        return enterStatus
    end 
    local hallInfo = skynet.call(hallInfo.HallModule,"lua","requestHallInfo")--向大厅发送登入的消息
    self:EnterHall(hallHandle,playHandle) --玩家加入大厅  
    sysManager:EnterHall(hallHandle,playHandle)
    sendObj:SetJson(hallInfo)--设置大厅信息返回
    return G_ErrorConf.ExecuteSuccess
end

function HallModule:Server_LeaveHall(sendObj,userHandle,param1,param2,param3,param4,str) 
    sendObj:SetCMD("Net_LeaveHall")  
    local sysManager = self._manager:GetSystemPlugin()--首先获取到 大厅插件
    if not sysManager:GetPlayer(playHandle)  then --获取到当前用户是否登入了系统 并且加入了大厅
        return G_ErrorConf.NotLoginSystem
    end  
    local hallIndex = sysManager:GetPlayerHallHandle(userHandle)--玩家登入的大厅索引
    if not hallIndex then
        return G_ErrorConf.NotLoginHall
    end    
    local hallInfo = self:GetHall(hallIndex)
    if not hallInfo then --没有找到与索引对应的大厅
        return G_ErrorConf.HallNotExist 
    end   
    if not self:IsEnterHall(hallIndex,userHandle)  then--本模块是当前角色是否进入了大厅
        return G_ErrorConf.DataChaos--数据混乱
    end      
    local leaveStatus = skynet.call(hallInfo.HallModule,"lua","playerLeaveHall",userHandle)--离开时会发送消息
    if leaveStatus ~= G_ErrorConf.table.ExecuteSuccess then--没离开成功
        return leaveStatus --返回失败原因
    end 
    self:LeaveHall(hallHandle,playHandle)
    sysManager:LeaveHall(hallHandle,playHandle)
    return G_ErrorConf.ExecuteSuccess  
end
--请求大厅信息
function HallModule:Server_RequestHallList(sendObj,param1,param2,param3,param4,str)   
    sendObj:SetCMD("Net_Request_HallList")
    local hallInfo = {} 
    for v,k in pairs(self._hallArray) do --循环比那里当前大厅数据
        local hallDes = skynet.call(k.HallModule,"lua","requestHallInfo")--取到大厅的描述
        hallInfo[v] = hallDes--加入大大厅队列中
    end
    sendObj:SetJson(hallInfo)
end 

function HallModule:RegisterNetCommand(serverTable)
    serverTable.Net_EnterHall = handler(self,HallModule.Server_EnterHall)--进入桌子
    serverTable.Net_LeaveHall = handler(self,HallModule.Server_LeaveHall)--离开桌子 
    serverTable.Net_Request_HallList = handler(self,HallModule.Server_RequestHallList)--请求大厅信息 
end  

function  HallModule:CreateHallService()  
    for i= 1,self._hallCount do--创建几个大厅 
        self._hallArray[i] = {}
        self._hallArray[i].playerList = {} 
        self._hallArray[i].onlineCount = 0 
        self._hallArray[i].HallModule = skynet.newservice(self._hallPath,self:GetSystemID(),i) 
    end
end 
  
--查询是否存在大厅
function HallModule:GetHall(hallIndex)
    return self._hallArray[hallIndex]
end 
--获取到大厅的列表
function HallModule:GetHallList() 
    return self._hallArray
end 
   
--查询是否存在大厅
function HallModule:GetHallHandle(hallIndex)
    local hallTable = self:GetHall(hallIndex)
    if not hallTable then 
        return false
    end  
    return self._hallArray[hallIndex].HallModule
end 
  
--判断角色是否进入了大厅
function HallModule:IsEnterHall(hallIndex ,playHandle)  
    local hallTable = self:GetHall(hallIndex)
    if not hallTable then 
        return false
    end  
    return hallTable.playerList[playHandle] 
end  

function HallModule:EnterHall(hallIndex,playHandle) 
    local hallTable = self:GetHall(hallIndex)
    if not hallTable then 
        return false
    end   
    hallTable.onlineCount = hallTable.onlineCount + 1
    hallTable.playerList[playHandle] = true
    return true 
end

function HallModule:LeaveHall(hallIndex,playHandle)
    local hallTable = self:GetHall(hallIndex)
    if not hallTable then 
        return false
    end    
    hallTable.onlineCount = hallTable.onlineCount - 1
    hallTable.playerList[playHandle] = nil
    return true 
end 
function  HallModule:Init() 
    self:CreateHallService() 
end
return HallModule 