local TableMachine = require("Template.Hall.Hall.Manager.TableManager.TableMachine.TableMachine") 
--桌子下玩家的状态机
local TableUnreadyMachine = class("TableUnreadyMachine",TableMachine)
--角色将退出桌子
function TableUnreadyMachine:PlayerLeave(playerHandle)   
    self:DeleteMachine(playerHandle)--退出当前状态机
    return ERROR_STATUS.ExecuteSuccess --返回离开成功
end
--角色进入观战模式
function TableUnreadyMachine:PlayerEnterLookModule(playerHandle)
    self:SetStateMachine(playerHandle,self._table.PLAYER_STATUS.LOOK)--加入未准备模式
    return ERROR_STATUS.ExecuteSuccess
end
--角色进入未准备模式
function TableUnreadyMachine:PlayerEnterUnReadyModule(playerHandle)  
    return ERROR_STATUS.StatusSame
end
--角色进入准备模式
function TableUnreadyMachine:PlayerEnterReadyModule(playerHandle)
    self:SetStateMachine(playerHandle,self._table.PLAYER_STATUS.Ready)--加入未准备模式
    return ERROR_STATUS.ExecuteSuccess --玩家需要先坐下
end
--玩家开始游戏（仅房主可以操作）
function TableUnreadyMachine:StartMiniGame(playerHandle)
    return ERROR_STATUS.NeedOwnerMasterIdentity --观看模式下 不可能有人是房主
end    
--玩家加入一场游戏
function TableUnreadyMachine:PlayerEnterGame(playerHandle)  
    return ERROR_STATUS.NotReadyState
end  
--加入游戏观战模式
function TableUnreadyMachine:EnterPlayerLookModule(playerHandle) 
    --在外面会判断游戏是否开始，如果开始的话会调用这个函数，其会直接修改角色状态为 
    self:SetStateMachine(playerHandle,self._table.PLAYER_STATUS.LOOK_PLAYING)--加入未准备模式
    return ERROR_STATUS.ExecuteError --返回离开成功
end  
--玩家离开一场游戏
function TableUnreadyMachine:PlayerLeaveGame(playerHandle)
    return ERROR_STATUS.ExecuteError
end    
return TableUnreadyMachine
