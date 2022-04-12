--桌子下玩家的状态机
local TableMachine = class("TableMachine")
function TableMachine:ctor(tableObj,state)--我不会做多余的对象，以下每个函数都是安全的
    self._table = tableObj
    self._nowState = state
end
--设置当前角色的状态机
function TableMachine:SetStateMachine(playerHandle,state)  
    self._StatusArray[self._nowState]:Delete(playerHandle)--删除在look中的数据信息
    self._StatusArray[state]:Add(playerHandle)--未准备加入  
    return self._table:SetStateMachine(playerHandle,state)--重新设置当前的状态机
end 
function TableMachine:DeleteMachine(playerHandle)   
    self._allPlayerArray[playerHandle]:Delete(playerHandle)--玩家退出 
    self._StatusArray[self._nowState]:Delete(playerHandle)--删除在look中的数据信息 
end 
function TableMachine:CalcMaster()
    self._table:ResetTableMaster()
end 
--角色将退出桌子
function TableMachine:PlayerLeave(playerHandle)
    return ERROR_STATUS.ExecuteError
end
--角色进入观战模式
function TableMachine:PlayerEnterLookModule(playerHandle)
    return ERROR_STATUS.ExecuteError
end
--角色进入未准备模式
function TableMachine:PlayerEnterUnReadyModule(playerHandle)
    return ERROR_STATUS.ExecuteError
end
--角色进入准备模式
function TableMachine:PlayerEnterReadyModule(playerHandle)
    return ERROR_STATUS.ExecuteError
end
--玩家开始游戏（仅房主可以操作）
function TableMachine:StartMiniGame(playerHandle)
    return ERROR_STATUS.ExecuteError
end    
--玩家加入一场游戏
function TableMachine:PlayerEnterGame(playerHandle)
    return ERROR_STATUS.ExecuteError
end    
--玩家离开一场游戏
function TableMachine:PlayerLeaveGame(playerHandle)
    return ERROR_STATUS.ExecuteError
end    
return TableMachine
