
local Player = class("Player")
function Player:ctor(...)
    self:InitData(...)
end   
--初始化数据消息
function Player:InitData(userHandle)
    self._userHandle = userHandle--当前的用户handle
    self._canAuth = true--是否需要验证（用户是否是退出状态了）
    self._timingTime = skynet.time() --角色创建出来后就开始计时
    --一个小周期内容许收到的次数（判断是否失去了连接，如果小周期有误，向客户端发送重连请求）
    self._detectionUnit = 5 --五秒  客户端5秒钟一发  
    self._heartbeatCount = 0 
end

--当收到一个心跳的时候调用
function Player:Heartbeat()
    self._heartbeatCount = self._heartbeatCount + 1 --当前心跳数加一
    return self._heartbeatCount
end 

--定时器检测当前心跳 
function Player:HeartbeatAuth(nowTime)    
    if not self._canAuth or (nowTime - self._timingTime <  self._detectionUnit) then --每五秒钟进行一次校验
        return -1
    end  
    local count = self._heartbeatCount
    self._timingTime = skynet.time() --角色创建出来后就开始计时
    self._heartbeatCount = 0
    return count > 0 and 1 or 0 
end 
--设置当前是否需要验证
function Player:SetNeedAuth(isNeed)
    self._canAuth = isNeed
end 
--获取当前是否需要验证
function Player:GetNeedAuth()
    return self._canAuth 
end  

return Player  