require "Tool.Class" 
local Map = require "Tool.Map" 
local Table = class("Table")  
Table.PLAYER_STATUS = {LOOK = 0, UNREADY = 1 ,READY = 2 ,PLAYING = 3}  
function Table:ctor(tableInfo)    
    self.maxPlayerCount = assert(tableInfo.maxPlayerCount,"param miss")
    self.maxSitDownPlayer = assert(tableInfo.maxSitDownPlayer,"param miss")
    self._startGameNeedPlayer = assert(tableInfo.startGameNeedPlayer,"param miss") 
    --房间能坐下的所有人员 
    self._allPlayerArray = Map.new() 
    --每种状态对应的角色
    self._StatusArray = {}  
    self._StatusArray[self.PLAYER_STATUS.LOOK] = Map.new() 
    self._StatusArray[self.PLAYER_STATUS.UNREADY] = Map.new() 
    self._StatusArray[self.PLAYER_STATUS.READY] = Map.new() 
    self._StatusArray[self.PLAYER_STATUS.PLAYING] = Map.new() 
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
--有一个判断是否可以开始游戏
function Table:GetGameHandle()
    return self._tableGameHandle
end  
--添加角色到桌子中 
function Table:PlayerEnter(playerHandle)
    local playerStatus = self._allPlayerArray:Find(playerHandle)
    if playerStatus then 
        return -1 
    end 
    if not self:CanSitDown() then 
        return -6
    end 
    self._allPlayerArray:Add(playerHandle,self.PLAYER_STATUS.UNREADY)
    self._StatusArray[self.PLAYER_STATUS.UNREADY]:Add(playerHandle,true)--角色加入到桌子
    return 0
end  
--角色将退出桌子
function Table:PlayerLeave(playerHandle)
    local playerStatus = self._allPlayerArray:Find(playerHandle)
    if not playerStatus then 
        return -1 
    end  
    local StatusList = {}
    StatusList[self.PLAYER_STATUS.READY] = -4 --玩家已经准备了 
    StatusList[self.PLAYER_STATUS.PLAYING] = -5 --玩家已经开始游戏了 
    if StatusList[playerStatus] then 
        return StatusList[playerStatus] 
    end    
    self._allPlayerArray:Delete(playerHandle)
    self._StatusArray[playerStatus]:Delete(playerHandle)--角色加入到桌子
    return 0
end
--角色进入观战模式
function Table:PlayerEnterLookModule(playerHandle)
    local playerStatus = self._allPlayerArray:Find(playerHandle)
    if not playerStatus then 
        return -1 
    end  
    local StatusList = {}
    StatusList[self.PLAYER_STATUS.LOOK] = -2 --玩家在观察模式
    StatusList[self.PLAYER_STATUS.READY] = -4 --玩家已经准备了 
    StatusList[self.PLAYER_STATUS.PLAYING] = -5 --玩家已经开始游戏了 
    if StatusList[playerStatus] then 
        return StatusList[playerStatus] 
    end     
    --未准备模式下 可以进入
    self._allPlayerArray:Add(playerHandle,self.PLAYER_STATUS.LOOK) 
    self._StatusArray[playerStatus]:Delete(playerHandle)--角色加入到桌子
    self._StatusArray[self.PLAYER_STATUS.LOOK ]:Add(playerHandle,true)--角色加入到桌子
    return 0
end
--角色进入未准备模式
function Table:PlayerEnterUnReadyModule(playerHandle)
    local playerStatus = self._allPlayerArray:Find(playerHandle)
    if not playerStatus then 
        return -1 
    end  
    StatusList[self.PLAYER_STATUS.UNREADY] = -3 --玩家已经准备了 
    StatusList[self.PLAYER_STATUS.PLAYING] = -5 --玩家已经开始游戏了 
    if StatusList[playerStatus] then 
        return StatusList[playerStatus] 
    end       
    self._allPlayerArray:Add(playerHandle,self.PLAYER_STATUS.UNREADY)  
    self._StatusArray[playerStatus]:Delete(playerHandle)--角色加入到桌子
    self._StatusArray[self.PLAYER_STATUS.UNREADY]:Add(playerHandle,true)--角色加入到桌子
end
--角色进入准备模式
function Table:PlayerEnterReadyModule(playerHandle)
    local playerStatus = self._allPlayerArray:Find(playerHandle)
    if not playerStatus then 
        return -1 
    end 
    local StatusList = {}
    StatusList[self.PLAYER_STATUS.LOOK] = -2 --玩家乜有坐下
    StatusList[self.PLAYER_STATUS.READY] = -4 --玩家已经准备了
    StatusList[self.PLAYER_STATUS.PLAYING] = -5 --玩家已经开始游戏了 
    if StatusList[playerStatus] then 
        return StatusList[playerStatus] 
    end   
    --未准备模式下 可以进入
    self._allPlayerArray:Add(playerHandle,self.PLAYER_STATUS.READY)  
    self._StatusArray[playerStatus]:Delete(playerHandle)--角色加入到桌子
    self._StatusArray[self.PLAYER_STATUS.READY]:Add(playerHandle,true)--角色加入到桌子
end
--游戏开始
function Table:PlayerEnterPlayModule(playerHandle)
    local playerStatus = self._allPlayerArray:Find(playerHandle)
    if not playerStatus then 
        return -1 
    end 
    local StatusList = {}
    StatusList[self.PLAYER_STATUS.LOOK] = -2 --玩家乜有坐下 
    StatusList[self.PLAYER_STATUS.UNREADY] = -3 --玩家已经准备了  
    StatusList[self.PLAYER_STATUS.PLAYING] = -5 --玩家已经开始游戏了 
    if StatusList[playerStatus] then 
        return StatusList[playerStatus] 
    end   
    --未准备模式下 可以进入
    self._allPlayerArray:Add(playerHandle,self.PLAYER_STATUS.PLAYING)  
    self._StatusArray[playerStatus]:Delete(playerHandle)--角色加入到桌子
    self._StatusArray[self.PLAYER_STATUS.PLAYING]:Add(playerHandle,true)--角色加入到桌子
end   
return Table 