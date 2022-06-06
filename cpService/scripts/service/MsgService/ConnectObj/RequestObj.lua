local ConnectObj =  require "MsgService.ConnectObj.ConnectObj" 
local RequestObj = class("RequestObj",ConnectObj)   
--执行网络消息
function RequestObj:Execute(netObj,fd, msg, sz) 
	local message = netpack.tostring(msg, sz) --解析消息   
	local ret , result = pcall(netObj.MsgDispose,netObj, self._userName, message) 
	if not ret then 
        skynet.error(result..":message dispos error fd:"..fd) 
    end  
end   

function RequestObj:InitData(fd,addr,statusMatching,uid) 
    ConnectObj.InitData(self,fd,addr,statusMatching)
    self.uid = uid
end 
return RequestObj  