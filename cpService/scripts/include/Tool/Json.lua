local _instance = nil 
if _instance then
   return  
end
_instance = true
require "Tool.Class"
require "Tool.Tool"
Json = class("Json")   
local CJson = require "cjson"  

function Json:Decode(str)  
    local ret,table =  Tool:Xpcall(CJson.decode,str)
    if not ret then 
        return nil
    end  
    Tool:TableNumberAmendment(table) 
    return table
end 
function Json:Encode(table)
    local ret,str = Tool:Xpcall(CJson.encode, table)
    if not ret then 
        return nil
    end 
    return str 
end  
local isntance = nil
--获取到当前服务的单列
function Json.Instance() 
  if not isntance then 
    isntance = Json.new()
    Json.new = nil
  end 
  return isntance;
end   
