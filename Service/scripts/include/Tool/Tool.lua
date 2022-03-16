local _instance = nil 
if _instance then
   return  
end
_instance = true

Tool = class("Tool")   

function Tool:ctor(...)
    self._skynet = require "skynet"
end 

function Tool:Xpcall(handle,...)
  return xpcall(handle, function(err)           
      self._skynet.error(tostring(err))
    self._skynet.error(debug.traceback())
  end,...)
end 

function Tool:NotifyPack(cmd,msg)
  return {cmd = cmd,data = msg}
end 
 

--获取到消息表
function Tool:GetNotifyLink(cmd,isNet)
  local notifyClass = nil
  if isNet then 
    notifyClass = NetNotifyMsgClass.Instance()
  else
    notifyClass = NotifyMsgClass.Instance()
  end 
  return notifyClass:GetServiceNameByMsg(cmd)
end
 
--返回以一个字符 为分割，左边以及右边的串
function Tool:IncisionString(source,operChar) 
  --寻找到当前第一个指定字符下标的位置
  local index = string.find(source,"[" .. operChar .. "]")
  local leftStr = nil
  local rightStr = nil
  --如果当前存在index
  if index then  
    leftStr = string.sub( source,1,index - 1 )  
    rightStr = string.sub( source,1,index + 1 )  
  else 
    leftStr = source
  end  
  return leftStr,rightStr
end  

function Tool:RecursionTable(array,handle) 
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

function Tool:TableNumberAmendment(table)
  self:RecursionTable(table,function(table,key) 
    local value = table[key]
    if type(value) == "number" and value - math.floor(value) == 0 then 
      table[key] = math.floor(value)
    end
  end )
end 
--打乱一个数组 
function Tool:Disorganize(table,count) 
  assert(tonumber(count),"param error")
  if count > 0 then
      self:Disorganize(table,count - 1)
  end 
  for i = 1 , #table do  
      local randIndex = math.random(1,#table)  
      table[randIndex],table[i] = table[i],table[randIndex] 
  end          
end  

local isntance = nil
--获取到当前服务的单列
function Tool.Instance() 
  if not isntance then 
    isntance = Tool.new()
    Tool.new = nil
  end 
  return isntance;
end   

