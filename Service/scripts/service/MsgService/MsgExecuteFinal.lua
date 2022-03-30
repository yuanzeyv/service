require "Tool.Class" 
local skynet = require "skynet"  
local MsgExecuteFinal = class("MsgExecuteFinal")
function MsgExecuteFinal:ctor(loginServerHandle)  
    self:InitServerData(loginServerHandle)
end 

function MsgExecuteFinal:InitServerData(msgMediator)
    self._msgMediatorObj =  assert(msgMediator,"处理中介对向传入不正确") --接收传入的登录服务

    self._agentHandles = {}  --当前已经登入的用户 服务句柄列表
    self._subid = 0 --当前的subid 
end

function MsgExecuteFinal:AllocAgentUid()--生成subid
    self._subid  = self._subid  + 1
    return self._subid
end

function MsgExecuteFinal:AdditionAgent(uid,subid,username)
    local agent =skynet.newservice("AgentService")
    skynet.call(agent,"lua","login",uid,subid,username )
    self._agentHandles[username] = agent
end

function MsgExecuteFinal:LoginHandler(uid) --传入用户账号
    skynet.error("login_handler invoke", uid)--输出用户登入
    local subId = self:AllocAgentUid()--生成一个uid
    local username = self._msgMediatorObj:GetUserName(uid,subId)----获取到当前的用户名称
    self:AdditionAgent(uid,subId,username)
    self._msgMediatorObj:Login(username)
    return subId
end 

function MsgExecuteFinal:LogoutHandler (uid, subid)--掉线
    skynet.error("logout_handler invoke", uid, subid)
    local username = self._msgMediatorObj:GetUserName(uid, subid )
    skynet.call(self._agentHandles[username],"lua","logout",uid,subid)
    self._agentHandles[username] = nil
    self._msgMediatorObj:Logout(username) 
end

function MsgExecuteFinal:KickHandler(uid, subid)--踢人
    skynet.error("kick_handler invoke", uid, subid) 
    local username = self._msgMediatorObj:GetUserName(uid, subid )
    if not self._agentHandles[username] then return end 
    self._msgMediatorObj:Logout(username) 
    skynet.call(self._loginservice,"lua","logout",uid,subid)
    self._agentHandles[username] = nil
end

function MsgExecuteFinal:DisconnectHandler(username)--断开连接时 调用
    skynet.error(username, "disconnect")  
end

function MsgExecuteFinal:AnalysisMsg(msg)--解析一条消息  
    local ret,msgtable = pcall(function (msg) return table.pack(string.unpack("<I4 I4 I4 I4 I4 s4",msg)) end,msg)  
    assert(ret,nil)  
    return msgtable
end 

function MsgExecuteFinal:RequestHandler(username, msg)--处理消息时调用 
    local msgTable = self:AnalysisMsg(msg) 
    assert(msgTable,"message fromat error")        
    return skynet.send(self._agentHandles[username],"client",table.unpack(msgTable)) 
end   

function MsgExecuteFinal:RegisterHandler(name)--开始注册时调用
    skynet.error("register_handler invoked name", name) 
end  
function MsgExecuteFinal:UnregisterHandler(name)--关闭时调用
    --关闭时调用
end  

function MsgExecuteFinal:WriteHandler(username,msg) --写数据时调用
    local a = self:AnalysisMsg(msg)
    if not self._agentHandles[username] then return end  
    self._msgMediatorObj:Write(username,msg) 
end 
function MsgExecuteFinal:ErrorHandler(username,msg) --出错时调用
end  
return MsgExecuteFinal