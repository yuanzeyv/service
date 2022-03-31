local TablePlayerModel = require("HallSystemModule.StructManager.TableManager.TablePlayerModel") 
local TablePlayerUnreadyPlayingModel = require("TablePlayerUnreadyPlayingModel",TablePlayerModel)
 
--角色将退出桌子
function TablePlayerUnreadyPlayingModel:PlayerLeave(playerHandle)   
    self:DeleteMachine(playerHandle)--退出当前状态机
    return ERROR_STATUS.ExecuteSuccess --返回离开成功
end
--角色进入观战模式
function TablePlayerUnreadyPlayingModel:PlayerEnterLookModule(playerHandle)
    return ERROR_STATUS.ExecuteError
end
--角色进入未准备模式
function TablePlayerUnreadyPlayingModel:PlayerEnterUnReadyModule(playerHandle)  
    return ERROR_STATUS.ExecuteError
end
--角色进入准备模式
function TablePlayerUnreadyPlayingModel:PlayerEnterReadyModule(playerHandle)
    return ERROR_STATUS.ExecuteError
end
--玩家开始游戏（仅房主可以操作）
function TablePlayerUnreadyPlayingModel:StartMiniGame(playerHandle)
    return ERROR_STATUS.ExecuteError
end    
--玩家加入一场游戏
function TablePlayerUnreadyPlayingModel:PlayerEnterGame(playerHandle) 
    self:SetStateMachine(playerHandle,self._table.PLAYER_STATUS.PLAYING)--加入未准备模式
    return ERROR_STATUS.NeedOwnerMasterIdentity
end    
--玩家离开一场游戏
function TablePlayerUnreadyPlayingModel:PlayerLeaveGame(playerHandle)
    self:SetStateMachine(playerHandle,self._table.PLAYER_STATUS.UNREADY)--加入未准备模式
    return ERROR_STATUS.NeedOwnerMasterIdentity
end    
return TablePlayerUnreadyPlayingModel
