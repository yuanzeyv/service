local MsgExecuteFinal = class("MsgExecuteFinal")
function MsgExecuteFinal:ctor(loginServerHandle)  
    self:InitServerData(loginServerHandle)
end  

function MsgExecuteFinal:InitServerData(msgMediator)
    self._msgMediatorObj =  assert(msgMediator,"处理中介对向传入不正确") --接收传入的登录服务 
    self._agentHandles = {}  --当前已经登入的用户 服务句柄列表
    self._agentInfos = {}  --当前已经登入的用户 服务句柄列表
    self._subid = 0 --当前的subid 
end

function MsgExecuteFinal:AllocAgentUid()--生成subid
    self._subid  = self._subid  + 1
    return self._subid
end

function MsgExecuteFinal:AdditionAgent(uid,subid,username)
    local agent =skynet.newservice("AgentService")--创建一个 角色服务
    skynet.call(agent,"lua","login",uid,subid,username)--将角色携带的信息发送过去
    self._agentHandles[username] = {}
    self._agentHandles[username].handle = agent
    self._agentHandles[username].uid = uid 

    self._agentInfos[uid] = {}
    self._agentInfos[uid].username = username
    self._agentInfos[uid].subid = subid
end

function MsgExecuteFinal:LoginHandler(uid) --传入用户账号
    skynet.error(string.format("用户:%s 正在登入网关服务器", uid))--输出用户登入
    local userInfo = self._agentInfos[uid]
    if userInfo then--如果这个角色之前就登录过 
        local userTable = self._agentHandles[userInfo.username] 
        skynet.call( userTable.handle ,"lua","logout") --会把人t掉，但又不是立即t掉，反正之后不会再监听这个人了
        return userInfo.subid --返回先前拥有的subId
    end  
    local subId = self:AllocAgentUid()--生成一个新的subid
    local username = self._msgMediatorObj:GetUserName(uid,subId)--获取到用户名
    self:AdditionAgent(uid,subId,username)
    self._msgMediatorObj:Login(username)
    return subId
end 

function MsgExecuteFinal:ExtrudeOffline(username) --传入用户账号
    local userTable = assert(self._agentHandles[username],"not found user table") 
    skynet.call(userTable.handle,"lua","logout") --发送离线信息
end 

function MsgExecuteFinal:LogoutHandler(username)--掉线
    skynet.error("logout_handler invoke",username) 
    local userTable = assert(self._agentHandles[username],"not found user table")
    self._agentHandles[username] = nil
    self._agentInfos[uid] = nil  
end

--验证成功的情况下，向当前的用户发送初始化命令 
function MsgExecuteFinal:AuthSuccess(username)--执行验证成功的功能，验证成功后 会向角色发送消息
    local userTable = assert(self._agentHandles[username],"not found user table")
    skynet.error("Auth Success",username)    
    skynet.send(userTable.handle,"lua","auth_success",uid,subid)  
end 

function MsgExecuteFinal:KickHandler( username )--踢人  
    skynet.error("开始准备将用户踢出去",username)    
    local userTable = assert(self._agentHandles[username],"user not found") 
    skynet.call(userTable.handle,"lua","logout",1)--向角色发送登出服务，让角色断网  
end

function MsgExecuteFinal:DisconnectHandler(username)--断开连接时  
    local userTable = assert(self._agentHandles[username],"user not found") 
    --skynet.call(userTable.handle,"lua","setNetStatus",false)  --设置网络连接状态
end 

function MsgExecuteFinal:AnalysisMsg(msg)--解析一条消息  
    local ret,msgtable = pcall(function (msg) return table.pack(string.unpack("<I4 I4 I4 I4 I4 s4",msg)) end,msg)  
    assert(ret,nil)  
    return msgtable
end 

function MsgExecuteFinal:RequestHandler(username, msg)--处理消息时调用  
    local msgTable = self:AnalysisMsg(msg) 
    assert(msgTable,"message fromat error")        
    return skynet.send(self._agentHandles[username].handle,"client",table.unpack(msgTable)) 
end   

function MsgExecuteFinal:OpenGateWayHandle(name)--开始注册时调用
    skynet.error("register_handler invoked name", name) 
end  
function MsgExecuteFinal:CloseGateWayHandle(name)--关闭时调用
    --关闭时调用
end  

function MsgExecuteFinal:WriteHandler(username,msg) --写数据时调用
    local a = self:AnalysisMsg(msg)
    if not self._agentHandles[username] then return end  
    self._msgMediatorObj:Write(username,msg) 
end 
function MsgExecuteFinal:ErrorHandler(username,msg) --出错时调用
    --可以考虑修改一下角色的无网络状态
end  
return MsgExecuteFinal