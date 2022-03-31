local TablePlayerModel = require("HallSystemModule.StructManager.TableManager.TablePlayerModel") 
--桌子下玩家的状态机
local TablePlayerLookPlayingModel = class("TablePlayerLookPlayingModel",TablePlayerModel)
--角色将退出桌子
function TablePlayerLookPlayingModel:PlayerLeave(playerHandle)    
    return ERROR_STATUS.ExecuteSuccess --玩家当前是观战模式，可以直接退出游戏
end
--角色进入观战模式
function TablePlayerLookPlayingModel:PlayerEnterLookModule(playerHandle)
    return ERROR_STATUS.ExecuteError --玩家在游戏中 无法进入到站起模式
end
--角色进入未准备模式
function TablePlayerLookPlayingModel:PlayerEnterUnReadyModule(playerHandle) 
    return ERROR_STATUS.ExecuteError --玩家在游戏中 无法进入到未准备模式
end
--角色进入准备模式
function TablePlayerLookPlayingModel:PlayerEnterReadyModule(playerHandle)
    return ERROR_STATUS.ExecuteError --玩家在游戏中 无法进入到准备模式
end
--玩家开始游戏（仅房主可以操作）
function TablePlayerLookPlayingModel:StartMiniGame(playerHandle)
    return ERROR_STATUS.NeedOwnerMasterIdentity --观看模式下 不可能有人是房主
end    
--加入游戏观战模式
function TablePlayerLookPlayingModel:EnterPlayerLookModule(playerHandle) 
    return ERROR_STATUS.StatusSame 
end  
--玩家加入一场游戏
function TablePlayerLookPlayingModel:PlayerEnterGame(playerHandle) 
    self:SetStateMachine(playerHandle,self._table.PLAYER_STATUS.PLAYING)--经过同意后，会直接进入游戏模式
    return ERROR_STATUS.ExecuteSuccess
end    
--结束游戏调用
function TablePlayerLookPlayingModel:PlayerLeaveGame(playerHandle) 
    self:SetStateMachine(playerHandle,self._table.PLAYER_STATUS.LOOK)--经过同意后，会直接进入游戏模式
    return ERROR_STATUS.ExecuteSuccess
end    
return TablePlayerLookPlayingModel
