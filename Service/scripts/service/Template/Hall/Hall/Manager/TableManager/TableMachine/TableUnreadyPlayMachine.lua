local TableMachine = require("Template.Hall.Hall.Manager.TableManager.TableMachine.TableMachine") 
local TableUnreadyPlayMachine = class("TableUnreadyPlayMachine",TableMachine)
 
--角色将退出桌子
function TableUnreadyPlayMachine:PlayerLeave(playerHandle)   
    self:DeleteMachine(playerHandle)--退出当前状态机
    return ERROR_STATUS.ExecuteSuccess --返回离开成功
end
--角色进入观战模式
function TableUnreadyPlayMachine:PlayerEnterLookModule(playerHandle)
    return ERROR_STATUS.ExecuteError
end
--角色进入未准备模式
function TableUnreadyPlayMachine:PlayerEnterUnReadyModule(playerHandle)  
    return ERROR_STATUS.ExecuteError
end
--角色进入准备模式
function TableUnreadyPlayMachine:PlayerEnterReadyModule(playerHandle)
    return ERROR_STATUS.ExecuteError
end
--玩家开始游戏（仅房主可以操作）
function TableUnreadyPlayMachine:StartMiniGame(playerHandle)
    return ERROR_STATUS.ExecuteError
end    
--玩家加入一场游戏
function TableUnreadyPlayMachine:PlayerEnterGame(playerHandle) 
    self:SetStateMachine(playerHandle,self._table.PLAYER_STATUS.PLAYING)--加入未准备模式
    return ERROR_STATUS.NeedOwnerMasterIdentity
end    
--玩家离开一场游戏
function TableUnreadyPlayMachine:PlayerLeaveGame(playerHandle)
    self:SetStateMachine(playerHandle,self._table.PLAYER_STATUS.UNREADY)--加入未准备模式
    return ERROR_STATUS.NeedOwnerMasterIdentity
end    
return TableUnreadyPlayMachine
