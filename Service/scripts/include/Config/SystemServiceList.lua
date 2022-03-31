require "Tool.Class"
require "Config.SystemIDConfig" 
SystemServiceList =  class("SystemServiceList")   
function SystemServiceList:ctor()   
    self._Table = self:InitTable()
end   
function SystemServiceList:InitTable()
    local table = {}    
    table[G_SysIDConf:GetTable().PokerSystem] = "bombooService/bombooService"
    return table
end 

function SystemServiceList:GetTable()
    return self._Table
end
return SystemServiceList