require "Tool.Class"  
local skynet = require "skynet"
local socket = require "skynet.socket"
local crypt = require "skynet.crypt"  
local LoginDataBaseOper = require "LoginService.LoginDataBaseOper" 
local LoginSalveService = class("LoginSalveService")   
local socket_error = {}  
function LoginSalveService:ctor(...) 
	self:InitServerData(...) 
	self:InitServer()  
end

function LoginSalveService:InitServerData(...)
	self._databaseObj = LoginDataBaseOper.new()  
	self._command = self:GetCMD()
end   
 
function LoginSalveService:ServerHandle_auth(token)
    -- the token is base64(user)@base64(server):base64(password) 
    local user, server, password = token:match("([^@]+)@([^:]+):(.+)") --将账号密码解析出来
    user = crypt.base64decode(user)--解析用户
    server = crypt.base64decode(server)--解析服务
    password = crypt.base64decode(password)--解析密码
    --skynet.error(string.format("%s@%s:%s", user, server, password)) --输出登录的用户信息 
	--打开登录数据库，查询其中的账号密码
	--成功返回用户数据信息 ，失败返回 错误信息 
    self._databaseObj:VirifyAccount(user,password) 
    return server, user
end 

function LoginSalveService:Auth(fd, addr) 
	socket.limit(fd, 8192)--首先消息缓冲区大小
	local readBuffer = socket.readline(fd) 
	assert(readBuffer,407) --如果没有读取到消息的话
	local userInfoEncode = crypt.base64decode(readBuffer)--将客户端传送来的消息解析为字符串
	local server, uid = self:ServerHandle_auth(userInfoEncode)--调用验证函数
	return server, uid
end

function LoginSalveService:Command_Login_Virify(source,fd,addr)   
	skynet.error(string.format("connect from %s (fd = %d)", addr, fd)) --打印连接
	socket.start(fd)--开始监听socket
	local ok,serverOrErrorCode,uid = pcall(self.Auth,self, fd, addr)--成功server是服务名称 失败为错误日志
	socket.abandon(fd)    
	if ok then
		return ok,serverOrErrorCode,uid 
	else 
		--即使返回值为其他 也是可以的
		return false,serverOrErrorCode
	end
end 
function LoginSalveService:GetCMD()
    local CMD = {}
    CMD.login_virify = handler(self,self.Command_Login_Virify) 
	return CMD
end  

function LoginSalveService:InitServer()
	skynet.start(function()   
		self:InitEventDispatch()--初始化事件派发 
	end)
end 
	   
function LoginSalveService:InitEventDispatch()   
    skynet.dispatch("lua", function(session, source, command, ...) 
        local f = assert(self._command[command])
        skynet.ret(skynet.pack(f(source, ...)))
    end) 
end   
local LoginSalveService = LoginSalveService.new(...)
