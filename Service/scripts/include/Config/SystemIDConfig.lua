--防止重复包含
if SystemIDConfig then
    return SystemIDConfig
end 
require "Tool.Class"
SystemIDConfig =  class("SystemIDConfig")  
function SystemIDConfig:ctor() 
    self._table = self:InitTable()
end  
function SystemIDConfig:InitTable()
    local table = {} 
    table.SystemManager = 0
    table.PokerSystem = 1
    return table
end 
function SystemIDConfig:GetTable() 
   return self._table
end   
function SystemIDConfig.Instance() 
    if not SystemIDConfig._instance then
       SystemIDConfig._instance = SystemIDConfig.new()
    end 
    return SystemIDConfig._instance
end  
return SystemIDConfig