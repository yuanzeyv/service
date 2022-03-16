local _instance = nil 
if _instance then
   return  
end
_instance = true

local Map = class("Map")  
function Map:ctor()
    self._count = 0
    self._table = {}
end 

function Map:Add(key,value)
    if not self._table[key] then
        self._count = self._count + 1
    end
    self._table[key] = value or true 
end 
function Map:Delete(key)
    if not self._table[key] then
        return
    end
    self._table[key] = nil
    self._count = self._count + 1
end 
function Map:Count()
    return self._count
end 

function Map:Find(key)
    return self._table[key]
end 

function Map:Clear()
    self._table = {} 
end 

function Map:GetTable()
    return self._table
end  
return Map