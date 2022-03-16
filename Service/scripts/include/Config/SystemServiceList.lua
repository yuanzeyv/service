if SystemServiceList then
    return SystemServiceList
end 
require "Tool.Class"
local SystemIDConfig = require "Config.SystemIDConfig".Instance() 
SystemServiceList =  class("SystemServiceList")   
function SystemServiceList.Instance() 
    if not SystemServiceList._instance then
       SystemServiceList._instance = SystemServiceList.new()
    end 
    return SystemServiceList._instance
end  
function SystemServiceList:ctor() 
    self._idTable = SystemIDConfig.Instance():GetTable() 
    self._Table = self:InitTable()
end   
function SystemServiceList:InitTable()
    local table = {}    
    table[SystemIDConfig:GetTable().PokerSystem] = "bombooService/bombooService"
    return table
end 

function SystemServiceList:GetTable()
    return self._Table
end
return SystemServiceList