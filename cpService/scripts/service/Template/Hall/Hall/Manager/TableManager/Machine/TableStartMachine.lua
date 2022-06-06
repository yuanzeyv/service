local TableMachine = require("Template.Hall.Hall.Manager.TableManager.Machine.TableMachine") 
local TableStartMachine = class("TableStartMachine",TableMachine)  
 --玩家开始游戏（仅房主可以操作）
function TableStartMachine:StartGame(playerHandle) 
    return ErrorType.StartGameEarlie --游戏已经开始
end    

function TableStartMachine:EnterReadyModule(playerHandle)
    return ErrorType.StartGameEarlie --游戏已经开始
end 
--玩家加入一场游戏
function TableStartMachine:EnterGame(playerHandle)
    playerInfo = self._tableObj:FindPlayer(playerHandle)--首先获取到当前玩家信息
    if not playerInfo then --玩家没有进入桌子
        return ErrorType.PlayerNotEnterTable
    end   
    local playerRetStatus = playerInfo:EnterGame()--如果玩家可以进入准备模式的话
    if plyerRetStatus ~= ErrorType.ExecuteSuccess then 
        return playerRetStatus
    end  
    --询问游戏是否可以加入
    self._tableObj:DeletePlayer(playerHandle)--桌子中确认删除玩家离开信息
    playerInfo:SetStatus(playerInfo.PLAYER_STATUS.PLAYING)  
    self._tableObj:AddPlayer(playerHandle,playerInfo)--桌子中确认删除玩家离开信息 
    self._tableObj:BroadcastPlayerStatus({playerHandle}) 
    return ErrorType.ExecuteSuccess
end    
--玩家离开一场游戏
function TableStartMachine:LeaveGame(playerHandle)
    playerInfo = self._tableObj:FindPlayer(playerHandle)--首先获取到当前玩家信息
    if not playerInfo then --玩家没有进入桌子
        return ErrorType.PlayerNotEnterTable
    end   
    local playerRetStatus = playerInfo:LeaveGame()--如果玩家可以进入准备模式的话
    if plyerRetStatus ~= ErrorType.ExecuteSuccess then 
        return playerRetStatus
    end  
    --询问游戏逻辑是否可以离开 
    self._tableObj:DeletePlayer(playerHandle)--桌子中确认删除玩家离开信息
    playerInfo:SetStatus(playerInfo.PLAYER_STATUS.UNREADY)  
    self._tableObj:AddPlayer(playerHandle,playerInfo)--桌子中确认删除玩家离开信息 
    self._tableObj:BroadcastPlayerStatus({playerHandle}) 
    --如果可以加入，向所有问价发送消息
    return ErrorType.ExecuteSuccess
end  
return TableStartMachine
