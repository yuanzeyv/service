
local ConnectObj =  require "MsgService.ConnectObj.ConnectObj" 
local AuthObj = class("AuthObj",ConnectObj)    
local RequestObj =  require "MsgService.ConnectObj.RequestObj" 

--执行网络消息
function AuthObj:Execute(netObj,fd, msg, sz)  
    local status,uid = netObj:Auth(fd, msg, sz)
	skynet.error(fd .. " Auth Result:" .. status)--输出错误日志  
	if status ~= ErrorType.ExecuteSuccess then 
		return
	end    
    self:ChangeStatus(self._fd,RequestObj.new(self._fd,self._addr,self._statusMatching,uid))
end  
return AuthObj 
 