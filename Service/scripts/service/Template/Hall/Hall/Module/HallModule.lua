local BaseModule = require "Template.Service.BaseModule" 
local HallModule = class("HallModule",BaseModule)   
local PlayerManager = require "Template.Hall.Hall.Manager.PlayerManager.PlayerManager"       
function HallModule:InitModuleData(tableData)
    self._tableData = tableData --获取到自己的数据 
    self._playerMan = PlayerManager.new(tableData) --人员管理类 
end    

function HallModule:Command_playerEnterHall(userHandle)   
    return self._playerMan:PlayerEnterHall(userHandle) 
end

function HallModule:Command_playerLeaveHall(userHandle)   
    --只返回 成功 与失败   
    local player = self:PlayerIsEnterHall(userHandle)--获取到当前角色
    if not player then return G_ErrorConf.ExecuteSuccess end   
    local tableID = player:GetTable()--获取到当前的桌子
    if not tableID then--玩家没有进入桌子的话
        self._playerMan:PlayerLeaveHall(userHandle)--保证能够清除成功
        return G_ErrorConf.ExecuteSuccess 
    end 
    local tableMan = self._manager:GetTablePlugin()
    if tableMan:GetTable(tableID) then --如果当前的桌子不存在的话
        self._playerMan:PlayerLeaveHall(userHandle)--保证能够清除成功
        return G_ErrorConf.ExecuteSuccess
    end 
    --判断一个玩家是否是游戏状态
    if tableMan:LeaveTable(tableID,userHandle) ~= G_ErrorConf.ExecuteSuccess then  --如果当前退出失败的话
        return G_ErrorConf.ExecuteFailed--执行失败
    end 
    self._playerMan:PlayerLeaveHall(userHandle)--清除玩家信息
    return G_ErrorConf.ExecuteSuccess --退出成功 
end

function HallModule:Command_RequestHallInfo(userHandle) 
    return {hallName = "我的大厅",hallID = self._manager:GetHallID()}
end

function HallModule:RegisterCommand(commandTable)
    commandTable.playerEnterHall = handler(self,HallModule.Command_playerEnterHall)--玩家加入大厅    
    commandTable.playerLeaveHall = handler(self,HallModule.Command_playerLeaveHall)--玩家离开大厅
    commandTable.requestHallInfo = handler(self,HallModule.Command_RequestHallInfo)--玩家离开    
end

--请求大厅信息
function HallModule:Server_EnterTable(sendObj,userHandle,tableID,param2,param3,param4,str)
    --首先获取到角色是否进入到了大厅 
    sendObj:SetCMD("Net_EnterTable") 
    local player = self._playerMan:GetPlayer(userHandle)
    if not player then return G_ErrorConf.NotLoginHall end --没有进入大厅
    if player:GetTable() then
        return G_ErrorConf.PlayerEnterTableEarlie --很早就加入了桌子 
    end 
    local tableMan = self._manager:GetTablePlugin()  --获取到桌子的管理
    local ret = tableMan:EnterTable(tableID,userHandle)--玩家进入桌子
    if ret ~= G_ErrorConf.ExecuteSuccess then 
        return ret --未执行成功，返回错误 
    end 
    return self._playerMan:EnterTable(userHandle,tableID)  --让玩家进入这个桌子
end 
--请求大厅信息
function HallModule:Server_LeaveTable(sendObj,userHandle,param1,param2,param3,param4,str)   
    --首先获取到角色是否进入到了大厅 
    sendObj:SetCMD("Net_LeaveHall") 
    local player = self:PlayerIsEnterHall(userHandle)
    if not player then 
        return G_ErrorConf.NotLoginHall --角色没有登入大厅 
    end  
    local tableID = player:GetTable()
    if not tableID then--获取到当前的桌子
        return G_ErrorConf.PlayerNotEnterTable --玩家没有进入桌子 
    end 
    local tableMan = self._manager:GetTablePlugin()  --获取到桌子的管理
    return tableMan:LeaveTable(tableID,userHandle)--玩家进入桌子 
end 

function HallModule:RegisterNetCommand(serverTable)
    serverTable.Net_EnterTable = handler(self,HallModule.Server_EnterTable)--进入桌子
    serverTable.Net_LeaveTable = handler(self,HallModule.Server_LeaveTable)--角色将退出桌子  
end  

--获取到玩家是否已经登入到了大厅了
function HallModule:PlayerIsEnterHall(userHandle)
    return self._playerMan:GetPlayer(userHandle)
end  
function  HallModule:Init()  
end
return HallModule

