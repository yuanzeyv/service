local ConnectObj = class("ConnectObj")    
function ConnectObj:ExecuteHandle(...)
    self._disposHandle(self._disposobj,...)
end 

function ConnectObj:SetDisposeObj(handle,obj)
    self._disposHandle = handle --执行的函数
    self._disposobj    = obj --执行的对象 
end 

---获取到连接的名称 
function ConnectObj:GetUserName()
    return self._username
end 
--设置用户信息
function ConnectObj:SetUserInfo(userInfo)
    self._userInfo = userInfo 
    self._username = userInfo.username
end  
function ConnectObj:InitServerData(fd,addr)  
    self._fd = fd --监听的套接字
    self._addr         = addr --登录的网络地址

    self._disposHandle = nil --执行的函数
    self._disposobj    = nil --执行的对象

    self._username     = nil --验证成功后，登录用户的姓名
    self._userInfo     = nil --验证成功后，登录用户的一些数据 
end 
return ConnectObj 