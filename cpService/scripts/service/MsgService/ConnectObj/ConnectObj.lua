local ConnectObj = class("ConnectObj")   
--执行网络消息
function ConnectObj:Execute(netObj,fd, msg, sz) 
end     

function ConnectObj:ctor(...)
    self:InitData(...)
end 
function ConnectObj:InitData(fd,addr,statusMatching)  
    self._fd = fd --监听的套接字
    self._addr         = addr --登录的网络地址   
    self._statusMatching = statusMatching
end
function ConnectObj:ChangeStatus(status)
    self._statusMatching:ChangeStatus(self._fd,status) 
end 
return ConnectObj 