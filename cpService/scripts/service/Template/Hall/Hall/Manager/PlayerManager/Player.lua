local Player = class("Player")    
function Player:ctor(userHandle)    
    self:InitData(userHandle) 
end 
function Player:InitData(userHandle) 
    self._userHandle = assert(userHandle,"userID not exist ") --传入的用户ID为空 
end    
function Player:GetUserHandle()--当前的用户句柄
    return self._userHandle 
end    
return Player