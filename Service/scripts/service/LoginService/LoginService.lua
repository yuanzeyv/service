local socket = require "skynet.socket"
local crypt = require "skynet.crypt"  
require "skynet.manager" 
local LoginDataBaseOper = require "LoginService.LoginDataBaseOper"  
local ServiceModle = require "ServiceModle.ServiceModle" 
local LoginService = class("LoginService",ServiceModle)   
  
function LoginService:Command_register_gate(source,server,address)   
    self._serverList[server] = address
	skynet.error("register server success name: " .. server .. " address: " .. address)
end

function LoginService:RegisterCommand(commandTable) 
	commandTable.register_gate =  handler(self,self.Command_register_gate)  
end  
 

function LoginService:InitServerData(port,name,host,instance)   
	self._port  = assert(tonumber(port),"没有填写端口信息")
	assert(not instance or instance <= 0,"协助服务数目错误") 
	self._host = host or "0.0.0.0"	--当前的地址
	self._instanceNum = instance or 8 --当前的从设备和数量
	self._name = name or ".login"--当前系统名称 

	self._userLogin = {}--当前用户登录的信息  

	self._slave = {}--从设备IP
	self._slave._chooseSlaveIndex = 0 --当前从设备选择
	self._slaveServerAddr = "LoginService/LoginSalveService"   
    self._serverList = {}
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
	print(errorCode)
	local sendText = string.format("%d %s",errorCode,addText) 
	assert(socket.write(fd, sendText),G_ErrorConf.SocketDisConnect) --如果发送失败的话
end    

--登录回调要返回一个 subid 
function LoginService:ServerHandle_login(server, uid)
    local msgserver = assert(self._serverList[server],G_ErrorConf.ServerNotExist)--获取到消息服务器 
    local subid = skynet.call(msgserver,"lua","login",uid)--向消息服务器发送登录消息
    return subid--返回subid
end
 
function LoginService:Accept(fd,addr)  
	local slave = self:GetNextSlave()
	local ok, server, uid = skynet.call(slave, "lua","login_virify",fd, addr)
	local code = server  
	if not ok then--如果当前返回为假
		self:Write(code,fd)--向客户端发送错误码
		error( code )--打印错误原因
	end   
	local errorStatus = G_ErrorConf.ExecuteSuccess
	--程序不允许多用户同时登陆
	if self._userLogin[uid] then --如果当前用户正在执行登录操作
		errorStatus = table.UserAlreadyLogin
		self:Write(errorStatus,fd)  
		error(errorStatus .. uid ) --  .. uid string.format("User %s is already login", uid))--打印当前用户正在执行登录操作
	end 
	self._userLogin[uid] = true--设置当前用户正在登录
	local ok, subID = pcall(self.ServerHandle_login,self, server, uid)  --获取到当前的回调验证
	self._userLogin[uid] = nil --登录结束 
	if ok then --如果执行函数成功 
		self:Write(errorStatus,fd,crypt.base64encode(subID or "" ).."\n")  --base64(subid)
		skynet.error("login Success:"..uid) 
	else   
		errorStatus = subID
		self:Write(errorStatus,fd)--发送进入的错误
		error(errorStatus)--打印错误原因
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
 
--初始化系统
function LoginService:InitSystem()   
	skynet.register(self._name)--注册当前服务器的名称
	self:CreateSlaveServer()  
	self:InitLoginScoket()
end     
local LoginService = LoginService.new(...)
