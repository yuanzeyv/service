local socket = require "skynet.socket"
local crypt = require "skynet.crypt"  
local LoginDataBaseOper = require "LoginService.LoginDataBaseOper"  
local ServiceModle = require "ServiceModle.ServiceModle" 
local LoginSalveService = class("LoginSalveService",ServiceModle)   
function LoginSalveService:Command_Login_Virify(source,fd,addr)   
	skynet.error(string.format("connect from %s (fd = %d)", addr, fd) .. source,fd,addr) --打印连接
	socket.start(fd)--开始监听socket
	local ok,serverOrErrorCode,uid = pcall(self.Auth,self, fd, addr)--成功server是服务名称 失败为错误日志
	socket.abandon(fd)   
	return ok,serverOrErrorCode,uid 
end 
function LoginSalveService:RegisterCommand(commandTable)
	commandTable.login_virify =  handler(self,self.Command_Login_Virify)  
end  

function LoginSalveService:ServerHandle_auth(token)
    -- the token is base64(user)@base64(server):base64(password) 
    local user, server, password = token:match("([^@]*)@([^:]*):(.*)") --将账号密码解析出来 
	assert(#user > 0 ,G_ErrorConf.AccountEmpty) --用户账号为空
	assert(#server > 0 ,G_ErrorConf.ServerNotSelect)--用户服务为空
	assert(#password > 0 ,G_ErrorConf.PasswordEmpty) --用户密码为空 
    user = crypt.base64decode(user)--解析用户
    server = crypt.base64decode(server)--解析服务
    password = crypt.base64decode(password)--解析密码  
	--打开登录数据库，查询其中的账号密码 
	local status = self._databaseObj:VirifyAccount(user,password)
    assert(status == G_ErrorConf.ExecuteSuccess,status)
    return server, user
end  

function LoginSalveService:Auth(fd, addr) 
	socket.limit(fd, 8192)--首先消息缓冲区大小
	local readBuffer = socket.readline(fd)--读取一行数据
	assert(readBuffer,G_ErrorConf.SocketDisConnect) --网络连接中断的情况
	local userInfoEncode = crypt.base64decode(readBuffer)--将客户端传送来的消息解析为字符串  
	local server, uid = self:ServerHandle_auth(userInfoEncode)--调用验证函数
	return server, uid
end

function LoginSalveService:__InitNetEventDispatch() --不监听网络消息
end   

function LoginSalveService:InitServerData(...)
	self._databaseObj = LoginDataBaseOper.new(...)  
end    
local LoginSalveService = LoginSalveService.new(...)
