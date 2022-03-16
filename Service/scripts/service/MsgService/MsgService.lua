require "Tool.Class"
local MsgMediator = require "MsgService.MsgMediator" 
local skynet = require "skynet"  
local MsgService = class("MsgService")
function MsgService:ctor(loginServerHandle)  
    self:InitServerData(loginServerHandle)
end 

function MsgService:InitServerData(loginServerHandle)
    assert(loginServerHandle,"传入的登录服ID不正确")
    self._loginservice = nil
    self._servername = nil

    self._agents = {} 
    self._subid = 0
    self._loginservice = loginServerHandle 
    self._MsgMediator = MsgMediator.new(self:GetServer())
end

function MsgService:AllocAgentUid()
    self._subid  = self._subid  + 1
    return self._subid
end

function MsgService:AdditionAgent(uid,subid,username)
    local agent =skynet.newservice("AgentService")
    skynet.call(agent,"lua","login",uid,subid,username )
    self._agents[username] = agent
end

function MsgService:Server_loginHandler(uid) 
    skynet.error("login_handler invoke", uid)
    local subId = self:AllocAgentUid()
    local username = self._MsgMediator:GetUserName(uid,subId, self._servername)
    self:AdditionAgent(uid,subId,username)
    self._MsgMediator:Login(username)
    return subId
end 

function MsgService:Server_logoutHandler (uid, subid)
    skynet.error("logout_handler invoke", uid, subid)
    local username = self._MsgMediator:GetUserName(uid, subid, self._servername)
    skynet.call(self._agents[username],"lua","logout",uid,subid)
    self._agents[username] = nil
    self._MsgMediator:Logout(username) 
end

function MsgService:Server_kickHandler(uid, subid)
    skynet.error("kick_handler invoke", uid, subid) 
    local username = self._MsgMediator:GetUserName(uid, subid, self._servername)
    if not self._agents[username] then return end 
    self._MsgMediator:Logout(username) 
    skynet.call(self._loginservice,"lua","logout",uid,subid)
    self._agents[username] = nil
end
function MsgService:Server_disconnectHandler(username)
    skynet.error(username, "disconnect")  
end

function MsgService:AnalysisMsg(msg)  
    local ret,msgtable = pcall(function (msg) return table.pack(string.unpack("<I4 I4 I4 I4 I4 s4",msg)) end,msg)  
    assert(ret,nil)  
    return msgtable
end 

function MsgService:Server_requestHandler(username, msg)   
    local msgTable = self:AnalysisMsg(msg) 
    assert(msgTable,"message fromat error")     
    return skynet.send(self._agents[username],"client",table.unpack(msgTable)) 
end   

function MsgService:Server_registerHandler(name)
    skynet.error("register_handler invoked name", name)
    self._servername = name 
    skynet.call(self._loginservice, "lua", "register_gate", self._servername, skynet.self())--调用loginService的注册消息，同样注册一下
end  

function MsgService:Server_writeHandler(username,msg) 
    local a = self:AnalysisMsg(msg)
    if not self._agents[username] then return end  
    self._MsgMediator:Write(username,msg) 
end 

function MsgService:GetServer()
    local server = {}
    server.login_handler = handler(self,self.Server_loginHandler)
    server.logout_handler =  handler(self,self.Server_logoutHandler) 
    server.kick_handler =  handler(self,self.Server_kickHandler)--外部发消息来调用，用来关闭连接 
    server.disconnect_handler = handler(self,self.Server_disconnectHandler)--当客户端断开了连接，这个回调函数会被调用 
    server.request_handler = handler(self,self.Server_requestHandler)--当接收到客户端的请求，这个回调函数会被调用,你需要提供应答。
    server.write_handler = handler(self,self.Server_writeHandler)--用户服务发送数据时的信息
    server.register_handler =  handler(self,self.Server_registerHandler)--监听成功会调用该函数，name为当前服务别名
    return server
end
local msgService = MsgService.new(...)