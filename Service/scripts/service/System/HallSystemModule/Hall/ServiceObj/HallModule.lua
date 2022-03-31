local BaseModule = require "BaseService.BaseModule" 
local HallModule = class("HallModule",BaseModule)    
local PlayerManager = require "HallSystemModule.Hall.StructManager.PlayerManager.PlayerManager"       
function HallModule:InitModuleData(tableData)
    self._tableData = tableData --获取到自己的数据 
    self._playerMan = PlayerManager.new(tableData) --人员管理类 
end    

function HallModule:Command_playerEnterHall(userHandle)   
    return self._playerMan:PlayerEnterHall(userHandle) 
end

function HallModule:Command_playerLeaveHall(userHandle)  
    return self._playerMan:PlayerLeaveHall(userHandle)
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
function HallModule:Server_EnterTable(sendObj,param1,param2,param3,param4,str)    
    sendObj:SetCMD("Server_EnterTable")--将转发进入桌子的消息
    local userHandle = sendObj:GetUser()--获取到用户的handle 
    --首先判断当前的用户是否进入了大厅
    self._playerMan:GetPlayer(userHandle)
    local hallInfo = {} 
    for v,k in pairs(self._hallArray) do --循环比那里当前大厅数据
        local hallDes = skynet.call(k.hallService,"lua","requestHallInfo")--取到大厅的描述
        hallInfo[v] =  hallDes--加入大大厅队列中
    end 
    sendObj:SetJson(Json.Instance():Encode(hallInfo))     
end 
--请求大厅信息
function HallModule:Server_LeaveTable(sendObj,param1,param2,param3,param4,str)   
    sendObj:SetCMD("Net_LeaveTable")
    local hallInfo = {} 
    for v,k in pairs(self._hallArray) do --循环比那里当前大厅数据
        local hallDes = skynet.call(k.hallService,"lua","requestHallInfo")--取到大厅的描述
        hallInfo[v] =  hallDes--加入大大厅队列中
    end 
    sendObj:SetString(Json.Instance():Encode(hallInfo))     
end 

function HallModule:RegisterNetCommand(serverTable)
    serverTable.Net_EnterTable = handler(self,HallModule.Server_EnterTable)--进入桌子
    serverTable.Net_LeaveTable = handler(self,HallModule.Server_LeaveTable)--角色将退出桌子  
end 
 
--获取到玩家是否已经登入到了大厅了
function HallModule:PlayerIsEnterHall()

end  

function  HallModule:Init()  
end
return HallModule

