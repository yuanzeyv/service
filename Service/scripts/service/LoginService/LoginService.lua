require "Tool.Class"
require "skynet.manager" 
local skynet = require "skynet"
local socket = require "skynet.socket"
local crypt = require "skynet.crypt"  
local LoginService = class("LoginService") 
function LoginService:ctor(...)  
	self:InitServerData(...) 
	self:InitServer()  
end

function LoginService:InitServerData(port,name,host,instance)  
	self._port  = assert(tonumber(port),"没有填写端口信息")
	assert(not instance or instance <= 0,"协助服务数目错误") 
	self._host = host or "0.0.0.0"	--当前的地址
	self._instanceNum = instance or 8 --当前的从设备和数量
	self._name = name or ".login"--当前系统名称
	 
    self._command = self:GetCMD() --当前的命令回调  

	self._userLogin = {}--当前用户登录的信息  

	self._slave = {}--从设备IP
	self._slave._chooseSlaveIndex = 0 --当前从设备选择
	self._slaveServerAddr = "LoginService/LoginSalveService" 
	--服务器列表
	self._serverList = {} 
	--错误码 
	self._errorCode = self:InitErrorCode()
end   
function LoginService:InitErrorCode()
	local retTable = {--返回码
	[200] = "Success" ,
	[401] = "unauthorized by auth_handler" ,
	[402] = "account not exist",
	[403] = "login_handler failed",
	[404] = "pass error",
	[405] = "server exist",
	[406] = "already in login (disallow multi login) ",
	[407] = "unknow error"} 
	return retTable
end

function LoginService:GetCode(id)   
	return (self._errorCode[id] and id) or 407
end 

function LoginService:GetCodeDesc(id)  
	if not tonumber(id) then
		return id
	else
		return self._errorCode[self:GetCode(id)]
	end  
end 

function LoginService:CreateSlaveServer()  
	for i=1,self._instanceNum do  
		table.insert(self._slave,skynet.newservice(self._slaveServerAddr))
	end 
end

function LoginService:GetNextSlave()
	local index = (self._slave._chooseSlaveIndex % self._instanceNum) + 1
	self._slave._chooseSlaveIndex = self._slave._chooseSlaveIndex+1
	return self._slave[index]
end  
 
function LoginService:Write(errorCode, fd,addText) 
	local sendText = string.format("%d %s",self:GetCode(errorCode),addText or self:GetCodeDesc(errorCode)) 
	assert(socket.write(fd, sendText),string.format("response %d failed: socket (fd = %d) closed", self:GetCode(errorCode), fd)) 
end   

function LoginService:Command_register_gate(source,server,address)   
    self._serverList[server] = address
	skynet.error("register server success name: " .. server .. " address: " .. address)
end

function LoginService:GetCMD()
    local CMD = {}
    CMD.register_gate = handler(self,self.Command_register_gate)
	return CMD
end  
	  
--登录回调要返回一个 subid 
function LoginService:ServerHandle_login(server, uid)
    local msgserver = assert(self._serverList[server],405)--获取到消息服务器 
    local subid = skynet.call(msgserver,"lua","login",uid)--向消息服务器发送登录消息
    return subid--返回subid
end

function LoginService:Accept(fd,addr)  
	local slave = self:GetNextSlave()--首先获取到从设备 
	local ok, serverOrCode, uid = skynet.call(slave, "lua","login_virify",fd, addr)--向从设备执行验证  -
	if not ok then--如果当前返回为假
		if ok ~= nil then--如果有返回码的话，打印错误信息
			self:Write(serverOrCode,fd)
		end
		error(self:GetCodeDesc(serverOrCode))--打印错误原因
	end 
	--程序不允许多用户同时登陆
	if self._userLogin[uid] then --如果当前用户正在执行登录操作
		self:Write(406,fd)  
		error(string.format("User %s is already login", uid))--打印当前用户正在执行登录操作
	end
	self._userLogin[uid] = true--设置当前用户正在登录
	local ok, subIDOrErr = pcall(self.ServerHandle_login,self, serverOrCode, uid)  --获取到当前的回调验证
	self._userLogin[uid] = nil --登录结束
	if ok then --如果执行函数成功 
		self:Write(200,fd,crypt.base64encode(subIDOrErr or "" ).."\n")  --base64(subid)
		skynet.error("login Success:"..uid) 
	else
		self:Write(subIDOrErr or 403,fd)--发送进入进入的错误
		error(self:GetCodeDesc(subIDOrErr or 403))--打印错误原因
	end
end  
function LoginService:InitLoginScoket()
	local fd = socket.listen(self._host , self._port)--开始监听端口
	socket.start(fd ,function(fd, addr)
		local ok, err = pcall(self.Accept,self,fd,addr)--开始执行监听函数
		if not ok then 
			skynet.error(string.format("invalid client(fd:%d) error:", fd) .. err) 
		end 
		socket.close_fd(fd)
	end) 
end  

function LoginService:InitEventDispatch()  
    skynet.dispatch("lua", function(session, source, command, ...)
        local f = assert(self._command[command])
        skynet.ret(skynet.pack(f(source, ...)))
    end)
end   

function LoginService:InitServer()
	skynet.start(function()  
		skynet.register(self._name)--注册当前服务器的名称
		self:CreateSlaveServer() 
		self:InitEventDispatch()
		self:InitLoginScoket()
	end)
end 
local LoginService = LoginService.new(...)
