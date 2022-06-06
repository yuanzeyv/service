local TableMachine = require("Template.Hall.Hall.Manager.TableManager.Machine.TableMachine") 
local TableStartMachine = class("TableStartMachine",TableMachine)  

--角色进入准备模式
function TableStartMachine:EnterReadyModule(playerHandle)
    playerInfo = self._tableObj:FindPlayer(playerHandle)--首先获取到当前玩家信息
    if not playerInfo then --玩家没有进入桌子
        return ErrorType.PlayerNotEnterTable
    end   
    local playerRetStatus = playerInfo:EnterReadyModule()--如果玩家可以进入准备模式的话
    if plyerRetStatus ~= ErrorType.ExecuteSuccess then 
        return playerRetStatus
    end  
    self._tableObj:DeletePlayer(playerHandle)--桌子中确认删除玩家离开信息
    playerInfo:SetStatus(playerInfo.PLAYER_STATUS.READY)  
    self._tableObj:AddPlayer(playerHandle,playerInfo)--桌子中确认删除玩家离开信息 
    self._tableObj:BroadcastPlayerStatus({playerHandle})
    return ErrorType.ExecuteSuccess 
end
--玩家开始游戏（仅房主可以操作）
function TableStartMachine:StartGame(playerHandle)
    playerInfo = self._tableObj:FindPlayer(playerHandle)--首先获取到当前玩家信息
    if not playerInfo then --玩家没有进入桌子
        return ErrorType.PlayerNotEnterTable
    end   
    if not playerInfo:IsMaster() then --玩家必须是房主才行
        return ErrorType.InsufficientPrivileges
    end   
    if not self._tableObj:CanStartGame() then     --开始判断是否可以开始游戏
        return ErrorType.TablePalyerNotEnough
    end  
    self:SetStateMachine(self._tableObj.TABLE_STATUS.START)--设置当前状态为开始游戏
    self._tableObj._tableGameHandle = 9999 --游戏服务 
    local readyList = self._tableObj:GetAllPlayerHandle(self._tableObj.PLAYER_STATUS.READY)
    for v,k in pairs(readyList) do 
        local playerInfo = self._tableObj:FindPlayer(k)
        self._tableObj:DeletePlayer(k)--桌子中确认删除玩家离开信息
        playerInfo:SetStatus(playerInfo.PLAYER_STATUS.PLAYING)  
    end 
    self._tableObj:BroadcastPlayerStatus(readyList)  
    return ErrorType.ExecuteSuccess
end    

--玩家加入一场游戏
function TableStartMachine:EnterGame(playerHandle)
    return ErrorType.NotStartGame
end    
--玩家离开一场游戏
function TableStartMachine:LeaveGame(playerHandle)
    return ErrorType.NotStartGame
end    

--角色进入准备模式
function TableStartMachine:EnterReadyModule(playerHandle)
    playerInfo = self._tableObj:FindPlayer(playerHandle)--首先获取到当前玩家信息
    if not playerInfo then --玩家没有进入桌子
        return ErrorType.PlayerNotEnterTable
    end   
    local playerRetStatus = playerInfo:EnterReadyModule()--如果玩家可以进入准备模式的话
    if plyerRetStatus ~= ErrorType.ExecuteSuccess then 
        return playerRetStatus
    end  
    self._tableObj:DeletePlayer(playerHandle)--桌子中确认删除玩家离开信息
    playerInfo:SetStatus(playerInfo.PLAYER_STATUS.READY)  
    self._tableObj:AddPlayer(playerHandle,playerInfo)--桌子中确认删除玩家离开信息 
    --向其他玩家发送角色离开的消息
    self._tableObj:BroadcastPlayerStatus({playerHandle})
    return ErrorType.ExecuteSuccess  
end 
return TableStartMachine
