require "Tool.Class" 
local Player = class("Player")    
function Player:ctor(uid)    
    self:InitData(uid) 
end

function Player:InitData(uid) 
    self._uid = uid 
    self._errCode = G_ErrorConf.DataBase_NotSelect 
    self._table = nil 
end  

function Player:GetUID()--当前的用户句柄
    return self._uid
end   

function Player:GetErrorCode()
    return self._errCode
end 

function Player:GetUserData()
    return self._table
end   
function Player:SetUserData(status ,table)
    self._errCode = status
    self._table = table
end 
return Player