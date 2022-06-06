require "Tool.Class" 
local Player = class("Player")    
function Player:ctor(uid)    
    self:InitData(uid) 
end

function Player:InitData(userInfo) 
    self._uid = userInfo.uid 
    self._uname  = userInfo.uname  
    self._table = nil 
end  

function Player:GetUID()--当前的用户句柄
    return self._uid
end   
function Player:GetUName()--当前的用户句柄
    return self._uname
end   
 

function Player:GetUserData()
    return self._table
end   
function Player:SetUserData(table) 
    self._table = table
end 
return Player