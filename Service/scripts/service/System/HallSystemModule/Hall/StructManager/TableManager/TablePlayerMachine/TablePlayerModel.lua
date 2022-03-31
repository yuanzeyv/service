--桌子下玩家的状态机
local TablePlayerModel = class("TablePlayerModel")
function TablePlayerModel:ctor(tableObj,state)--我不会做多余的对象，以下每个函数都是安全的
    self._table = tableObj
    self._nowState = state
end
--设置当前角色的状态机
function TablePlayerModel:SetStateMachine(playerHandle,state)  
    self._StatusArray[self._nowState]:Delete(playerHandle)--删除在look中的数据信息
    self._StatusArray[state]:Add(playerHandle)--未准备加入  
    return self._table:SetStateMachine(playerHandle,state)--重新设置当前的状态机
end 
function TablePlayerModel:DeleteMachine(playerHandle)   
    self._allPlayerArray[playerHandle]:Delete(playerHandle)--玩家退出 
    self._StatusArray[self._nowState]:Delete(playerHandle)--删除在look中的数据信息 
end 
--角色将退出桌子
function TablePlayerModel:PlayerLeave(playerHandle)
    return ERROR_STATUS.ExecuteError
end
--角色进入观战模式
function TablePlayerModel:PlayerEnterLookModule(playerHandle)
    return ERROR_STATUS.ExecuteError
end
--角色进入未准备模式
function TablePlayerModel:PlayerEnterUnReadyModule(playerHandle)
    return ERROR_STATUS.ExecuteError
end
--角色进入准备模式
function TablePlayerModel:PlayerEnterReadyModule(playerHandle)
    return ERROR_STATUS.ExecuteError
end
--玩家开始游戏（仅房主可以操作）
function TablePlayerModel:StartMiniGame(playerHandle)
    return ERROR_STATUS.ExecuteError
end    
--玩家加入一场游戏
function TablePlayerModel:PlayerEnterGame(playerHandle)
    return ERROR_STATUS.ExecuteError
end    
--玩家离开一场游戏
function TablePlayerModel:PlayerLeaveGame(playerHandle)
    return ERROR_STATUS.ExecuteError
end   
--加入游戏观战模式
function TablePlayerModel:EnterPlayerLookModule(playerHandle)
    return ERROR_STATUS.ExecuteError
end   
return TablePlayerModel
