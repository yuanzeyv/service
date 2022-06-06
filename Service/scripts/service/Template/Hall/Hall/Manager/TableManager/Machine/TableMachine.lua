--桌子下玩家的状态机
local TableMachine = class("TableMachine")
function TableMachine:ctor(tableObj,state)
    self._tableObj = tableObj
    self._nowState = state
end
--设置当前角色的状态机
function TableMachine:SetStateMachine(state)   
    return self._tableObj:SetTableStateMachine(state)--重新设置当前的状态机
end  
--角色进入观战模式 
function TableMachine:EnterLookModule(playerHandle)
    playerInfo = self._tableObj:FindPlayer(playerHandle)--首先获取到当前玩家信息
    if not playerInfo then --玩家没有进入桌子
        return ErrorType.PlayerNotEnterTable
    end   
    local playerRetStatus = playerInfo:EnterLookModule()--如果玩家可以进入准备模式的话
    if plyerRetStatus ~= ErrorType.ExecuteSuccess then 
        return playerRetStatus
    end  
    self._tableObj:DeletePlayer(playerHandle)--桌子中确认删除玩家离开信息
    playerInfo:SetStatus(playerInfo.PLAYER_STATUS.LOOK)  
    self._tableObj:AddPlayer(playerHandle,playerInfo)--桌子中确认删除玩家离开信息 
    self._tableObj:BroadcastPlayerStatus({playerHandle})
    return ErrorType.ExecuteSuccess 
end 
--角色进入未准备模式 
function TableMachine:EnterUnReadyModule(playerHandle)
    playerInfo = self._tableObj:FindPlayer(playerHandle)--首先获取到当前玩家信息
    if not playerInfo then --玩家没有进入桌子
        return ErrorType.PlayerNotEnterTable
    end   
    local playerRetStatus = playerInfo:EnterUnReadyModule()--如果玩家可以进入准备模式的话
    if plyerRetStatus ~= ErrorType.ExecuteSuccess then 
        return playerRetStatus
    end  
    self._tableObj:DeletePlayer(playerHandle)--桌子中确认删除玩家离开信息
    playerInfo:SetStatus(playerInfo.PLAYER_STATUS.UNREADY)  
    self._tableObj:AddPlayer(playerHandle,playerInfo)--桌子中确认删除玩家离开信息 
    --向其他玩家发送角色离开的消息
    self._tableObj:BroadcastPlayerStatus({playerHandle})
    return ErrorType.ExecuteSuccess 
end 
--角色进入准备模式
function TableMachine:EnterReadyModule(playerHandle)
    return ErrorType.ExecuteFailed
end
--玩家开始游戏（仅房主可以操作）
function TableMachine:StartGame(playerHandle)
    return ErrorType.ExecuteFailed
end    
--玩家加入一场游戏
function TableMachine:EnterGame(playerHandle)
    return ErrorType.ExecuteFailed
end    
--玩家离开一场游戏
function TableMachine:LeaveGame(playerHandle)
    return ErrorType.ExecuteFailed
end    
--玩家离开一场游戏
function TableMachine:EnterTable(playerHandle) 
    playerInfo = self._tableObj:FindPlayer(playerHandle)--首先获取到当前玩家信息
    if playerInfo then --如果玩家已经进入过桌子
        return ErrorType.PlayerNotEnterTable
    end    
    local player = self._tableObj:CreatePlayer(playerHandle) --创建一个玩家
    if self._tableObj:CanSitDown() then  --判断当前是否可以桌下,设置为未准备
        player:SetStatus(player.PLAYER_STATUS.UNREADY) 
    end  
    self._tableObj:AddPlayer(playerHandle,player)--桌子中确认删除玩家离开信息  
    self._tableObj:BroadcastPlayerStatus({playerHandle},playerHandle)  --向所有非自己的玩家发送一条状态变更消息
    return ErrorType.ExecuteSuccess
end    
--玩家离开一场游戏
function TableMachine:LeaveTable(playerHandle)
    playerInfo = self._tableObj:FindPlayer(playerHandle)--首先获取到当前玩家信息
    if not playerInfo then --玩家没有进入桌子
        return ErrorType.ExecuteSuccess
    end   
    local playerRetStatus = playerInfo:LevelTable()
    if plyerRetStatus ~= ErrorType.ExecuteSuccess then 
        return playerRetStatus
    end  
    self._tableObj:DeletePlayer(playerHandle)--桌子中确认删除玩家离开信息
    --向其他玩家发送角色离开的消息
    self._tableObj:BroadcastPlayerStatus({playerHandle})--向大厅所有人广播角色离开的消息
    return ErrorType.ExecuteSuccess
end    
return TableMachine  