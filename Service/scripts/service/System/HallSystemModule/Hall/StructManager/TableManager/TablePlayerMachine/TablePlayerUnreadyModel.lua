local TablePlayerModel = require("HallSystemModule.StructManager.TableManager.TablePlayerModel") 
--桌子下玩家的状态机
local TablePlayerUnreadyModel = class("TablePlayerUnreadyModel",TablePlayerModel)
--角色将退出桌子
function TablePlayerUnreadyModel:PlayerLeave(playerHandle)   
    self:DeleteMachine(playerHandle)--退出当前状态机
    return ERROR_STATUS.ExecuteSuccess --返回离开成功
end
--角色进入观战模式
function TablePlayerUnreadyModel:PlayerEnterLookModule(playerHandle)
    self:SetStateMachine(playerHandle,self._table.PLAYER_STATUS.LOOK)--加入未准备模式
    return ERROR_STATUS.ExecuteSuccess
end
--角色进入未准备模式
function TablePlayerUnreadyModel:PlayerEnterUnReadyModule(playerHandle)  
    return ERROR_STATUS.StatusSame
end
--角色进入准备模式
function TablePlayerUnreadyModel:PlayerEnterReadyModule(playerHandle)
    self:SetStateMachine(playerHandle,self._table.PLAYER_STATUS.Ready)--加入未准备模式
    return ERROR_STATUS.ExecuteSuccess --玩家需要先坐下
end
--玩家开始游戏（仅房主可以操作）
function TablePlayerUnreadyModel:StartMiniGame(playerHandle)
    return ERROR_STATUS.NeedOwnerMasterIdentity --观看模式下 不可能有人是房主
end    
--玩家加入一场游戏
function TablePlayerUnreadyModel:PlayerEnterGame(playerHandle)  
    return ERROR_STATUS.NotReadyState
end  
--加入游戏观战模式
function TablePlayerUnreadyModel:EnterPlayerLookModule(playerHandle) 
    --在外面会判断游戏是否开始，如果开始的话会调用这个函数，其会直接修改角色状态为 
    self:SetStateMachine(playerHandle,self._table.PLAYER_STATUS.LOOK_PLAYING)--加入未准备模式
    return ERROR_STATUS.ExecuteError --返回离开成功
end  
--玩家离开一场游戏
function TablePlayerUnreadyModel:PlayerLeaveGame(playerHandle)
    return ERROR_STATUS.ExecuteError
end    
return TablePlayerUnreadyModel
