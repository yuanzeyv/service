--防止重复包含
if StringConfigObj then
    return StringConfigObj
end 
require "Tool.Class"
StringConfig =  class("StringConfig")  
function StringConfig:ctor() 
    self._table = self:InitTable()
end  
function StringConfig:InitTable()
    local table = {} 
    --1-99
    table[1] = "scoket disconnect" 
    --100 - 150 database
    table[100] = "database select error"
    table[101] = "database select empty"

    table[200] = "Login Success"
    table[401] = "Unauthorized"
    table[402] = "AccountAbnormal"
    table[403] = "Forbidden"
    table[404] = "PassAbnormal"
    table[405] = "ServerAbnormal"
    table[460] = "NotAcceptable" 
    return table
end 
function StringConfig:GetString(id) 
   return self._table[id] or "NOT FIND"
end
function StringConfig:ID(id) 
    return id
end

function StringConfig.Instance() 
    if not StringConfig._instance then
       StringConfig._instance = StringConfig.new()
    end 
    return StringConfig._instance
end  
StringConfigObj = StringConfig.new()
return StringConfigObj