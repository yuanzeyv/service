local TablePlayerModel = require("HallSystemModule.StructManager.TableManager.TablePlayerModel") 
local TablePlayerLookModel = class("TablePlayerLookModel",TablePlayerModel)
--角色将退出桌子
function TablePlayerLookModel:PlayerLeave(playerHandle)   
    self:DeleteMachine(playerHandle)--退出当前状态机
    return ERROR_STATUS.ExecuteSuccess --返回离开成功
end
--角色进入观战模式
function TablePlayerLookModel:PlayerEnterLookModule(playerHandle)
    return ERROR_STATUS.StatusSame
end
--角色进入未准备模式
function TablePlayerLookModel:PlayerEnterUnReadyModule(playerHandle) 
    self:SetStateMachine(playerHandle,self._table.PLAYER_STATUS.UNREADY)--加入未准备模式
    return ERROR_STATUS.ExecuteError
end
--角色进入准备模式
function TablePlayerLookModel:PlayerEnterReadyModule(playerHandle)
    return ERROR_STATUS.PlayerNeedSitDown --玩家需要先坐下
end
--玩家开始游戏（仅房主可以操作）
function TablePlayerLookModel:StartMiniGame(playerHandle)
    return ERROR_STATUS.NeedOwnerMasterIdentity --观看模式下 不可能有人是房主
end    
--加入游戏观战模式
function TablePlayerLookModel:EnterPlayerLookModule(playerHandle)
    self:SetStateMachine(playerHandle,self._table.PLAYER_STATUS.LOOK_PLAYING)--加入未准备模式
    return ERROR_STATUS.ExecuteSuccess --返回离开成功
end  
--玩家加入一场游戏
function TablePlayerLookModel:PlayerEnterGame(playerHandle) 
    self:SetStateMachine(playerHandle,self._table.PLAYER_STATUS.PLAYING)--经过同意后，会直接进入游戏模式
    return ERROR_STATUS.NeedOwnerMasterIdentity
end    
--玩家离开一场游戏
function TablePlayerLookModel:PlayerLeaveGame(playerHandle)
    return ERROR_STATUS.ExecuteError
end    
return TablePlayerLookModel
