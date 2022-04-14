if G_SysIDConf then return end--防止重复包含  
require "Tool.Class"
local SystemIDConfig =  class("SystemIDConfig")  
function SystemIDConfig:ctor() 
    self._table = self:InitTable()
end  
function SystemIDConfig:InitTable()
    local table = {} 
    table.SystemManager = 1 --系统管理系统
    table.PlayerSystem = 2  --角色管理系统
    table.TimeSystem = 4  --定时器管理系统

    table.PokerSystem = 3   --扑克系统
    return table
end 
function SystemIDConfig:GetTable()  
   return self._table
end     
G_SysIDConf = SystemIDConfig.new() 