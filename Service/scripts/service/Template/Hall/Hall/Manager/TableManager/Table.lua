local Map = require "Tool.Map" 
local Table = class("Table")  
Table.PLAYER_STATUS = {LOOK = 1, UNREADY = 2 ,READY = 3 ,PLAYING = 4,LOOK_PLAYING = 5,UNREADY_PLAYING = 6} 
local MachinePath = "Template.Hall.Hall.Manager.TableManager.TableMachine."
function Table:ctor(tableInfo,sysModule)    
    self.maxPlayerCount = assert(tableInfo.maxPlayerCount,"param miss")
    self.maxSitDownPlayer = assert(tableInfo.maxSitDownPlayer,"param miss")
    self._startGameNeedPlayer = assert(tableInfo.startGameNeedPlayer,"param miss") 
    self._service = assert(sysModule,"param miss") 
    --房间能坐下的所有人员 
    self._allPlayerArray = Map.new() 
    --每种状态对应的角色
    self._StatusArray = {}  
    self._StatusArray[self.PLAYER_STATUS.LOOK]    = Map.new() --观看模式 
    self._StatusArray[self.PLAYER_STATUS.UNREADY] = Map.new() --未准备模式
    self._StatusArray[self.PLAYER_STATUS.READY]   = Map.new() --准备模式
    self._StatusArray[self.PLAYER_STATUS.PLAYING] = Map.new() --游戏模式
    self._StatusArray[self.PLAYER_STATUS.LOOK_PLAYING] = Map.new() --场外观战模式（观看游戏）
    self._StatusArray[self.PLAYER_STATUS.UNREADY_PLAYING] = Map.new() --未准备的观战模式（场内观战）
    --每种状态对应的状态机
    self._StateMachines = {}  
    self._StateMachines[self.PLAYER_STATUS.LOOK   ]        =require(MachinePath.."TableLookMachine").new(self,self.PLAYER_STATUS.LOOK   )           --观看模式 
    self._StateMachines[self.PLAYER_STATUS.UNREADY]        =require(MachinePath.."TableUnreadyMachine").new(self,self.PLAYER_STATUS.UNREADY)        --未准备模式
    self._StateMachines[self.PLAYER_STATUS.READY  ]        =require(MachinePath.."TableReadyMachine").new(self,self.PLAYER_STATUS.READY  )          --准备模式
    self._StateMachines[self.PLAYER_STATUS.PLAYING]        =require(MachinePath.."TablePlayMachine").new(self,self.PLAYER_STATUS.PLAYING)        --游戏模式
    self._StateMachines[self.PLAYER_STATUS.LOOK_PLAYING   ]=require(MachinePath.."TableLookPlayMachine").new(self,self.PLAYER_STATUS.LOOK_PLAYING   )    --场外观战模式（观看游戏）
    self._StateMachines[self.PLAYER_STATUS.UNREADY_PLAYING]=require(MachinePath.."TableUnreadyPlayMachine").new(self,self.PLAYER_STATUS.UNREADY_PLAYING) --未准备的观战模式（场内观战）
    
    self._homeSteward = nil--当前的房主
    self._tableGameHandle = nil --桌子关联的游戏句柄
end
--当前是否可以被坐下
--return true 可以添加
--return false 不可以添加
function Table:CanSitDown()
    local unReadyCount = self._StatusArray[self.PLAYER_STATUS.UNREADY]:Count()
    local readyCount = self._StatusArray[self.PLAYER_STATUS.READY]:Count() 
    return (unReadyCount + readyCount) < self.maxSitDownPlayer
end  
--判断是否可以加入到观战队列
function Table:CanEnterTable()
    return self._allPlayerArray:Count() < self.maxPlayerCount 
end 
--获取到对应模式的状态机
function Table:GetStateMachine(state)
    return self._StateMachines[state]
end  
function Table:SetStateMachine(playerHandle ,state) 
    self._allPlayerArray:Add(playerHandle,self:GetStateMachine(state)) --状态机分配完毕
    return true
end  
--添加角色到桌子中 
function Table:PlayerEnter(playerHandle)
    local StatusMachine = self._allPlayerArray:Find(playerHandle)--寻找到当前使用的状态机
    if StatusMachine then --玩家已经拥有了状态机
        return ERROR_STATUS.JoinedTableEarlier 
    end  
    if not self:CanEnterTable() then--首先判断是否可以进入桌子
        return ERROR_STATUS.TableCrowd
    end  
    local AllocMachine = self:GetStateMachine(self.PLAYER_STATUS.LOOK) --默认分配一个看状态机
    if self:CanSitDown() then  
        AllocMachine = self:GetStateMachine(self.PLAYER_STATUS.UNREADY)--如果玩家坐下了，分配一个未准备状态机
    end
    self._allPlayerArray:Add(playerHandle,AllocMachine) --状态机分配完毕
    return ERROR_STATUS.ExecuteSuccess
end 
--角色将退出桌子
function Table:PlayerLeave(playerHandle)
    local StatusMachine = self._allPlayerArray:Find(playerHandle)
    if not StatusMachine then--玩家并没有进入桌子 
        return ERROR_STATUS.NotEnterTable
    end  
    return StatusMachine:PlayerLeave(playerHandle)--调用状态机的玩家退出
end
--角色进入观战模式
function Table:PlayerEnterLookModule(playerHandle)
    local StatusMachine = self._allPlayerArray:Find(playerHandle)
    if not StatusMachine then--玩家并没有进入桌子 
        return ERROR_STATUS.NotEnterTable
    end  
    return StatusMachine:PlayerEnterLookModule(playerHandle)--调用进入观战模式的状态机
end
--角色进入未准备模式
function Table:PlayerEnterUnReadyModule(playerHandle)
    local StatusMachine = self._allPlayerArray:Find(playerHandle)
    if not StatusMachine then--玩家并没有进入桌子 
        return ERROR_STATUS.NotEnterTable
    end  
    return StatusMachine:PlayerEnterUnReadyModule(playerHandle)--调用进入未准备模式的状态机
end
--角色进入准备模式
function Table:PlayerEnterReadyModule(playerHandle)
    local StatusMachine = self._allPlayerArray:Find(playerHandle)
    if not StatusMachine then--玩家并没有进入桌子 
        return ERROR_STATUS.NotEnterTable
    end  
    return StatusMachine:PlayerEnterReadyModule(playerHandle)--调用进入准备模式的状态机
end
--玩家开始游戏（仅房主可以操作）
function Table:StartMiniGame(playerHandle)
    local StatusMachine = self._allPlayerArray:Find(playerHandle)
    if not StatusMachine then--玩家并没有进入桌子 
        return ERROR_STATUS.NotEnterTable
    end  
    return StatusMachine:StartMiniGame(playerHandle)--调用进入开始游戏的状态机
end    
--玩家加入一场游戏
function Table:PlayerEnterGame(playerHandle)
    local StatusMachine = self._allPlayerArray:Find(playerHandle)
    if not StatusMachine then--玩家并没有进入桌子 
        return ERROR_STATUS.NotEnterTable
    end  
    return StatusMachine:PlayerEnterGame(playerHandle)--调用进入开始游戏的状态机
end    
--玩家离开一场游戏
function Table:PlayerLeaveGame(playerHandle)
    local StatusMachine = self._allPlayerArray:Find(playerHandle)
    if not StatusMachine then--玩家并没有进入桌子 
        return ERROR_STATUS.NotEnterTable
    end  
    return StatusMachine:PlayerLeaveGame(playerHandle)--调用进入开始游戏的状态机
end    
--一个人的游戏句柄
function Table:GetGameHandle()
    return self._tableGameHandle
end   
--获取房间的主人
function Table:GetTableMaster()
    return self._homeSteward
end 
function Table:DeleteTableMaster()
    self._homeSteward = nil 
end 

--重新设置房间的主人（如果返回为True代表当前房主确实换人了）
function Table:ResetTableMaster()  
    --如果当前已经有房主了
    if self:GetTableMaster() then 
        return 
    end  
    --如果当前是游戏模式的话 将不予理会
    if self:GetGameHandle() then 
        return 
    end
    --按顺序遍历 3个列表,来重新设置当前房主 
    for key in self.PLAYER_STATUS.READY,self.PLAYER_STATUS.UNREADY do 
        local playerList = self._StatusArray[key]:GetTable()
        for v,k in pairs(playerList) do--只找第一个人
            self._homeSteward = v --设置当前的房主为 v 
            if key == self.PLAYER_STATUS.UNREADY then 
                self:SetStateMachine(playerHandle,self.PLAYER_STATUS.READY) 
                self._StatusArray[self.PLAYER_STATUS.UNREADY]:Delete(playerHandle)--将房主从未准备队列移除
                self._StatusArray[self.PLAYER_STATUS.READY]:Add(playerHandle,true)--角色加入到桌子--将房主加入到准备队列
            end  
            break
        end 
        if self:GetTableMaster() then 
            break
        end 
    end  
    --向所有人广播房主被更换 
    local sendObj = BaseMessageObj.new(self._service) 
    sendObj:SetCMD("Net_ChangeMaster")
    for v,k in pairs(self._allPlayerArray.Get()) do
        sendObj:SetUser(v)
        sendObj:SetParam2(self._homeSteward)
        sendObj:Send() 
    end  
end  
return Table 