if Tool then
   return Tool
end 
local ToolClass = class("ToolClass")    
local crypt = require "skynet.crypt" 
function ToolClass:ctor(...) 
end  

function ToolClass:Xpcall(handle,...)
  return xpcall(handle, function(err)           
      self._skynet.error(tostring(err))
    self._skynet.error(debug.traceback())
  end,...)
end 

function ToolClass:Base64Decode(msg)
  local isOk , str =  pcall(crypt.base64decode,msg)  
  return str
end 

function ToolClass:NotifyPack(cmd,msg)
  return {cmd = cmd,data = msg}
end 
 

--获取到消息表
function ToolClass:GetNotifyLink(cmd,isNet)
  local notifyClass = nil
  if isNet then 
    notifyClass = NetNotifyMsgClass.Instance()
  else
    notifyClass = NotifyMsgClass.Instance()
  end 
  return notifyClass:GetServiceNameByMsg(cmd)
end 

function ToolClass:RecursionTable(array,handle) 
  if type(array) ~="table" then 
    return
  end
  for k,v in pairs(array) do 
    if type(v) == "table" then 
        self:RecursionTable(array[k],handle)
    else
      handle(array,k)
    end 
  end   
end 

function ToolClass:TableNumberAmendment(table)
  self:RecursionTable(table,function(table,key) 
    local value = table[key]
    if type(value) == "number" and value - math.floor(value) == 0 then 
      table[key] = math.floor(value)
    end
  end )
end 
--打乱一个数组 
function ToolClass:Disorganize(table,count) 
  assert(tonumber(count),"param error")
  if count > 0 then
      self:Disorganize(table,count - 1)
  end 
  for i = 1 , #table do  
      local randIndex = math.random(1,#table)  
      table[randIndex],table[i] = table[i],table[randIndex] 
  end          
end   

function ToolClass:TableSize(table) 
  local count = 0
  for v,k in pairs(table ) do 
    count = count + 1 
  end         
  return count
end   
function ToolClass:TransFromTable(table)
  local ret = {}  
  for v,k in pairs(table) do  
      ret[k] = v
  end
  return ret
end 


function ToolClass:Split(str, sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  str:gsub(pattern, function (c) fields[#fields + 1] = c end)
  return fields
end  


Tool = ToolClass.new() 