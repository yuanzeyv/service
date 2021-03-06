local TableMachine = require("Template.Hall.Hall.Manager.TableManager.TableMachine.TableMachine") 
--桌子下玩家的状态机
local TablePlayMachine = class("TablePlayMachine",TableMachine) 
 
--角色将退出桌子
function TablePlayMachine:PlayerLeave(playerHandle)   
    self:DeleteMachine(playerHandle)--退出当前状态机
    return ERROR_STATUS.ExecuteSuccess --返回离开成功
end
--角色进入观战模式
function TablePlayMachine:PlayerEnterLookModule(playerHandle)
    return ERROR_STATUS.StatusSame
end
--角色进入未准备模式
function TablePlayMachine:PlayerEnterUnReadyModule(playerHandle) 
    self:SetStateMachine(playerHandle,self._table.PLAYER_STATUS.UNREADY)--加入未准备模式
    return ERROR_STATUS.ExecuteError
end
--角色进入准备模式
function TablePlayMachine:PlayerEnterReadyModule(playerHandle)
    return ERROR_STATUS.PlayerNeedSitDown --玩家需要先坐下
end
--玩家开始游戏（仅房主可以操作）
function TablePlayMachine:StartMiniGame(playerHandle)
    return ERROR_STATUS.PlayerHasStartGame --游戏早就开始了
end      
--加入游戏观战模式
function TablePlayMachine:EnterPlayerLookModule(playerHandle) 
    return ERROR_STATUS.ExecuteError --返回离开成功
end
--玩家加入一场游戏
function TablePlayMachine:PlayerEnterGame(playerHandle) 
    return ERROR_STATUS.PlayerHasStartGame --游戏早就开始了
end    
--玩家离开一场游戏
function TablePlayMachine:PlayerLeaveGame(playerHandle)
    self:SetStateMachine(playerHandle,self._table.PLAYER_STATUS.UNREADY)--经过同意后，会直接进入游戏模式
    return ERROR_STATUS.ExecuteSuccess
end    
return TablePlayMachine
