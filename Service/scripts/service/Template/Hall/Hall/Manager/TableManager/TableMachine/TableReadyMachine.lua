local TableMachine = require("Template.Hall.Hall.Manager.TableManager.TableMachine.TableMachine") 
--桌子下玩家的状态机
local TableReadyMachine = class("TableReadyMachine",TableMachine)  
--角色将退出桌子
function TableReadyMachine:PlayerLeave(playerHandle)   
    self:DeleteMachine(playerHandle)--退出当前状态机
    return ERROR_STATUS.ExecuteSuccess --返回离开成功
end
--角色进入观战模式
function TableReadyMachine:PlayerEnterLookModule(playerHandle)
    return ERROR_STATUS.StatusSame
end
--角色进入未准备模式
function TableReadyMachine:PlayerEnterUnReadyModule(playerHandle) 
    self:SetStateMachine(playerHandle,self._table.PLAYER_STATUS.UNREADY)--加入未准备模式
    return ERROR_STATUS.ExecuteError
end
--角色进入准备模式
function TableReadyMachine:PlayerEnterReadyModule(playerHandle)
    return ERROR_STATUS.PlayerNeedSitDown --玩家需要先坐下
end
--玩家开始游戏（仅房主可以操作）
function TableReadyMachine:StartMiniGame(playerHandle)
    if self._table:GetTableMaster() ~= playerHandle then 
        return ERROR_STATUS.NeedOwnerMasterIdentity --观看模式下 不可能有人是房主
    end  
    return ERROR_STATUS.ExecuteSuccess
end    
--玩家加入一场游戏
function TableReadyMachine:PlayerEnterGame(playerHandle) 
    self:SetStateMachine(playerHandle,self._table.PLAYER_STATUS.LOOK_PLAYING)--在准备模式下 可以直接进入游戏中去
    return ERROR_STATUS.ExecuteSuccess
end 
--加入游戏观战模式
function TableReadyMachine:EnterPlayerLookModule(playerHandle) 
    return ERROR_STATUS.ExecuteError --返回离开成功
end   
--玩家离开一场游戏
function TableReadyMachine:PlayerLeaveGame(playerHandle)
    return ERROR_STATUS.ExecuteError
end    
return TableReadyMachine
