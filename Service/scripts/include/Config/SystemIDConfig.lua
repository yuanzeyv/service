if G_SysIDConf then return end--防止重复包含  
require "Tool.Class"
local SystemIDConfig =  class("SystemIDConfig")  
function SystemIDConfig:ctor() 
    self._table = self:InitTable()
end  
function SystemIDConfig:InitTable()
    local table = {} 
    table.SystemManager = 1
    table.PokerSystem = 2  
    return table
end 
function SystemIDConfig:GetTable()  
   return self._table
end     
G_SysIDConf = SystemIDConfig.new() 