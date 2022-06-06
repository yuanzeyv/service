local Map = require "Tool.Map" 
local Player = require"Template.Hall.Hall.Manager.PlayerManager.Player" --大厅里面有桌子 
local PlayerManager = class("PlayerManager")    
function PlayerManager:ctor(table)    
    self:InitServiceData(table)
end
function PlayerManager:GetMaxPlayerCount()
    return self._maxCapacity
end  
function PlayerManager:GetNowPlayerCount()
    return self._playerArray:Count()
end  

function PlayerManager:InitServiceData(tableData)
    assert(tableData,"param miss")
    self._playerArray = Map.new()--大厅总人数  
    self._maxCapacity = tableData.maxCapacity or 800 --最大容纳800人
end

--获取到一个玩家
function PlayerManager:GetPlayer(userHandle)  
    return self._playerArray:Find(userHandle)
end 
  
--添加一个角色
function PlayerManager:PlayerEnterHall(userHandle)
    if self:GetPlayer(userHandle) then 
        return ErrorType.LoginHallEarlie
    end  
    if self._playerArray:Count() >= self._maxCapacity then 
        return ErrorType.HallPersonFull
    end
    local player = Player.new(userHandle)--新建一个玩家
    self._playerArray:Add(userHandle,player) --玩家加入到管理列表 
    return ErrorType.ExecuteSuccess
end
   
--删除一个角色
function PlayerManager:PlayerLeaveHall(userHandle)
    local player=self:GetPlayer(userHandle) 
    if not player then return ErrorType.PlayerNotEnterHall end  
    self._playerArray:Delete(userHandle) --删除当前的玩家
    return ErrorType.ExecuteSuccess 
end
return PlayerManager 