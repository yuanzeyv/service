local BaseModule = require "Template.Service.BaseModule" 
local HallModule = class("HallModule",BaseModule)     
function HallModule:InitModuleData(tableData) 
    self._hallPath = assert(tableData.hallPath,"hall path not find ")
    self._hallCount = tableData.hallCount or 1 --创建大厅的个数  
    self._hallArray = {} --大厅列表   
    self._playerList = {} --大厅玩家信息
end    

function HallModule:GetPlayerEnterHall(userHandle)
    return self._playerList[userHandle]
end  

function HallModule:GetHallInfo(hallIndex)
    return self._hallArray[hallIndex]
end   

function HallModule:Server_EnterHall(sendObj,userHandle,hallIndex,param2,param3,param4,str)   
    sendObj:SetCMD("Net_EnterHall") 
    if not self._manager:IsEnterSystem(userHandle) then --获取到当前用户是否登入了系统 
        return ErrorType.NotLoginSystem 
    end  
    if self:GetPlayerEnterHall(userHandle) then--判断当前角色是否早就进入了大厅
        return ErrorType.LoginHallEarlie 
    end
    local hallInfo = self:GetHallInfo(hallIndex)--要进入的大厅是否存在 
    if not hallInfo then 
        return ErrorType.HallNotExist 
    end   
    local callStatus = skynet.call(hallInfo.HallHandle,"lua","playerEnterHall",userHandle)--玩家成功登入了大厅
    if callStatus ~=  ErrorType.ExecuteSuccess then
        return callStatus 
    end   
    return self:EnterHall(hallIndex,userHandle)  
end

function HallModule:Server_LeaveHall(sendObj,userHandle,param1,param2,param3,param4,str) 
    sendObj:SetCMD("Net_LeaveHall")    
    if not self._manager:IsEnterSystem(userHandle) then --获取到当前用户是否登入了系统 
        return ErrorType.NotLoginSystem 
    end   
    local playerEnterHall = self:GetPlayerEnterHall(userHandle)--获取到大厅的信息
    if not playerEnterHall then  
        return ErrorType.NotLoginHall
    end     
    local leaveStatus = skynet.call(hallInfo.HallHandle,"lua","playerLeaveHall",userHandle)--离开时会发送消息
    if leaveStatus ~= ErrorType.table.ExecuteSuccess then--没离开成功
        return leaveStatus --返回失败原因
    end  
    return self:LeaveHall(hallIndex,userHandle)   
end
--请求大厅信息
function HallModule:Server_RequestHallList(sendObj,param1,param2,param3,param4,str)   
    sendObj:SetCMD("Net_Request_HallList")
    local hallInfo = {} 
    for v,k in pairs(self._hallArray) do --循环比那里当前大厅数据
        local hallDes = skynet.call(k.HallHandle,"lua","requestHallInfo")--取到大厅的描述
        hallInfo[v] = hallDes--加入大大厅队列中
    end
    sendObj:SetJson(hallInfo)
end 

function HallModule:RegisterNetCommand(serverTable)
    serverTable.Net_EnterHall = handler(self,HallModule.Server_EnterHall)--进入桌子
    serverTable.Net_LeaveHall = handler(self,HallModule.Server_LeaveHall)--离开桌子 
    serverTable.Net_Request_HallList = handler(self,HallModule.Server_RequestHallList)--请求大厅信息 
end    

--查询是否存在大厅
function HallModule:GetHallHandle(hallIndex)
    local hallTable = self:GetHallInfo(hallIndex)
    if not hallTable then return false end  
    return self._hallArray[hallIndex].HallHandle
end    
function HallModule:EnterHall(hallIndex,playHandle)--进入大厅的调用 
    if self:GetPlayerEnterHall() then return ErrorType.LoginHallEarlie end --已经加入了大厅
    local hallTable = self:GetHallInfo(hallIndex)--首先获取到大厅是否存在
    if not hallTable then return ErrorType.HallNotExist  end   
    hallTable.onlineCount = hallTable.onlineCount + 1--对当前大厅人数进行累加
    hallTable.playerList[playHandle] = true --设置当前玩家未在线 
    self._playerList[playHandle] = hallTable
    return ErrorType.ExecuteSuccess  
end

function HallModule:LeaveHall(playHandle)
    local playerHall = self:GetPlayerEnterHall()--获取到当前角色是否加入了大厅 
    if not playerHall then return ErrorType.NotLoginHall end --已经加入了大厅
    playerHall.onlineCount = playerHall.onlineCount - 1
    playerHall.playerList[playHandle] = nil
    self._playerList[userHandle] = nil
    return ErrorType.ExecuteSuccess  
end 

function  HallModule:CreateHallService()  
    for i= 1,self._hallCount do--创建几个大厅 
        self._hallArray[i] = {}
        self._hallArray[i].playerList = {} 
        self._hallArray[i].onlineCount = 0 
        self._hallArray[i].HallHandle = skynet.newservice(self._hallPath,self:GetSystemID(),i) 
    end
end 
  
function  HallModule:Init()  
    self:CreateHallService() 
end
return HallModule 