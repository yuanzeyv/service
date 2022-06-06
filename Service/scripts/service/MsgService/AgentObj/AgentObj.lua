local AgentObj = class("AgentObj")   
function AgentObj:GetUID()
    return self.uid 
end
function AgentObj:GetSUBID()
    return self.subid 
end
function AgentObj:CompareSubID(sub)
    return self.subid == tonumber(sub)
end

function AgentObj:ctor(...)
    self:InitData(...)
end  

function AgentObj:GetSocket()
    return self.socket 
end
function AgentObj:SetSocket(socket)
    self.socket = socket
end  
function AgentObj:GetHandle(socket)
     return self.handle
end  
function AgentObj:InitData(uid,subid)  
    self.uid =  uid
    self.subid = subid
    self.socket = nil --监听的套接字  
    self.handle = skynet.newservice("AgentService")--创建一个 角色服务 --验证成功后，登录用户的姓名  
    skynet.call(self.handle,"lua","login",uid,subid,username)--将角色携带的信息发送过去
end  
return AgentObj  