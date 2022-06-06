local Map = require "Tool.Map" 
local Player = class("Player")   
Player.PLAYER_STATUS = {LOOK = 1, UNREADY = 2 ,READY = 3 ,PLAYING = 4,LOOK_PLAYING = 5} 
function Player:ctor(userHandle)  
    self._isHomeMaster = false --是否是房主
    self._plyerStatus = self.PLAYER_STATUS.LOOK  
    self._userHandle = userHandle
end    
function Player:GetStatus()
    return self._plyerStatus
end 
function Player:SetStatus(status)
    self._plyerStatus = status
end  
function Player:EnterLookModule()
    --角色进入观战模式
    if self.PLAYER_STATUS.UNREADY ~= self._plyerStatusthen then 
        return ErrorType.ExecuteFailed   --玩家需要先离开游戏
    end 
    return ErrorType.ExecuteSuccess 
end
--角色进入未准备模式
function Player:EnterUnReadyModule()
    if not (self.PLAYER_STATUS.LOOK == self._plyerStatus or self.PLAYER_STATUS.READY == self._plyerStatus) then 
        return ErrorType.ExecuteFailed   --玩家需要先离开游戏
    end 
    return ErrorType.ExecuteSuccess 
end
--角色进入准备模式
function Player:EnterReadyModule()
    if not (self.PLAYER_STATUS.UNREADY == self._plyerStatus or self.PLAYER_STATUS.PLAYING == self._plyerStatus) then 
        return ErrorType.ExecuteFailed   --玩家需要先离开游戏
    end 
    return ErrorType.ExecuteSuccess   
end

--玩家开始游戏（仅房主可以操作）
function Player:StartGame() 
    if self.PLAYER_STATUS.READY ~= self._plyerStatus or not self._isHomeMaster then 
        return ErrorType.ExecuteFailed   --玩家需要先离开游戏
    end  
    return ErrorType.ExecuteSuccess  --玩家需要先离开游戏 
end    

--玩家加入一场游戏
function Player:EnterGame()
    if self.PLAYER_STATUS.READY ~= self._plyerStatus then 
        return ErrorType. ExecuteFailed 
    end    
    return ErrorType.ExecuteSuccess  --玩家需要先离开游戏
end    

--玩家离开一场游戏
function Player:LeaveGame()
    if not (self.PLAYER_STATUS.PLAYING == self._plyerStatus or self.PLAYER_STATUS.LOOK_PLAYING == self._plyerStatus) then 
        return ErrorType. ExecuteFailed 
    end   
    return ErrorType.ExecuteSuccess  --玩家需要先离开游戏 
end    
 
--玩家离开一场游戏
function Player:LevelTable()
    if self.PLAYER_STATUS.READY == self._plyerStatus then 
        return ErrorType.ExecuteFailed --玩家徐取消准备
    end 
    if self.PLAYER_STATUS.PLAYING == self._plyerStatus or  self.PLAYER_STATUS.LOOK_PLAYING == self._plyerStatus then 
        return ErrorType.ExecuteFailed --玩家需要先离开游戏
    end  
    return ErrorType.ExecuteSuccess
end    
--获取到属性
function Player:GetInfo()
    local ret = {}  
    ret.state = self._plyerStatus
    ret.id = self._userHandle 
    return ret
end  
return Player 