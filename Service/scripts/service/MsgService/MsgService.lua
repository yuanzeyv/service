local netpack = require "skynet.netpack"
local socketdriver = require "skynet.socketdriver" 
local ServiceModle = require "ServiceModle.ServiceModle" 
local MsgMediator = require "MsgService.MsgMediator"    
local MsgService = class("MsgService",ServiceModle)   
local NetStatus = {DISCONNECT = nil,OPEN = 1,CONNECT = 2,READY_CLOSE = 3}
function MsgService:InitServerData(gatewayName)    
	self._gatewayName = assert(gatewayName,"not input server name")   
	self._loginCount = 0 --当前监听的数目
	self._mediatorObj =  MsgMediator.new(self)  --消息处理Mediator  
 
	self._socket = nil    --被监听的socket
	self._socketHandleList = self:GetSocketHandleList()  
	self._nodelay = false --大数据包   
	self._maxclient	= nil --最大被监听的数目 
	self._queue	= nil	  --消息执行队列
	self._connection = {} 
end     
--获取到当前服务器的名字
function MsgService:GateWayNameName()
	return self._gatewayName 
end 

function MsgService:Server_SocketDispatchMsg(fd, msg, sz) --消息派发
	if self._connection[fd] ~= NetStatus.CONNECT then--不等于连接状态的话
		skynet.error(string.format("Drop message from fd (%d) : %s", fd, netpack.tostring(msg,sz)))  
		return 
	end   
	self._mediatorObj:MessageDispose(fd, msg, sz)--处理消息
end

function MsgService:Server_SocketDispatchMore()
	local fd, msg, sz = netpack.pop(self._queue)
	if fd then
		skynet.fork(handler(self,self.Server_DispatchQueue)) --用几个进程轮询处理事件派发 
		self:Server_SocketDispatchMsg(fd, msg, sz) 
		for fd, msg, sz in netpack.pop, self._queue do --用最快的速度将所有消息打包完毕
			self:Server_SocketDispatchMsg(fd, msg, sz) 
		end
	end
end

function MsgService:Server_SocketOpen(fd, msg)  
	if self._loginCount >= self._maxclient then
		socketdriver.shutdown(fd)--连接到达最大，关闭当前套接字 
		return
	end
	self._loginCount = self._loginCount + 1 --连接数目+1
	local _ = self._nodelay and socketdriver.nodelay(fd) --设置当前不时延 
	self._connection[fd] = NetStatus.OPEN --设置当前网络为打开状态
	
	print("socket被打开".. fd )
	self._mediatorObj:SocketOpenHandle(fd, msg)--处理连接
end 
--这个函数本身不可能被重入
function MsgService:Server_SocketClose(fd)  --close  
	if fd ~= self._socket then  
		print("socket将关闭".. fd )
		assert(self._connection[fd],"socket对象不存在" .. fd) --当前连接状态必须是 准备关闭的时候才能进入
		self._loginCount = self._loginCount - 1--数目减一
		self._connection[fd] = NetStatus.DISCONNECT --彻底关闭
		self._mediatorObj:SocketCloseHandle(fd) --断开连接的回调
	else 
		self._socket = nil
	end
end 

function MsgService:Server_SocketError(fd, msg)--当程序收到错误的消息时。
	if fd == self._socket then--如果当前为主socket的话
		skynet.error("MsgService accept error:",msg) --仅仅发送一个打印
	else  
		self:CloseClient(fd) --关闭当前的套接字
		self._mediatorObj:SocketErrorHandle(fd, msg)--调用错误的函数
	end
end 

function MsgService:Server_ClientWarning(fd, size) 
	self._mediatorObj:SocketWarningHandle(fd, size) --处理错误消息
end

function MsgService:GetSocketHandleList()
    local serverList = {}   
	serverList.more = 	 handler(self,self.Server_SocketDispatchMore) 
	serverList.data = 	 handler(self,self.Server_SocketDispatchMsg)
	serverList.open = 	 handler(self,self.Server_SocketOpen)--完成 
	serverList.close =	 handler(self,self.Server_SocketClose)--
	serverList.error =	 handler(self,self.Server_SocketError)  
	serverList.warning = handler(self,self.Server_ClientWarning)
	return serverList 
end   
  
function MsgService:InitNetDispatch()  
	skynet.register_protocol {
		name = "socket",
		id = skynet.PTYPE_SOCKET,
		unpack = function ( msg, sz )
			return netpack.filter(self._queue, msg, sz)
		end,
		dispatch = function (_, _, q, type, ...)
			self._queue = q
			local fd = ...  
			local _ = type and self._socketHandleList[type](...)  
		end
	}   
	
end   

function MsgService:Openclient(fd) --打开一个客户端的网络连接
	if self._connection[fd] ~= NetStatus.OPEN then return end--已经记录的情况，但是未连接 
	socketdriver.start(fd) --开始接听
	self._connection[fd] = NetStatus.CONNECT
	print("开始连接了")
end

function MsgService:CloseClient(fd)--关闭一个客户端的网络连接 
	if  self._connection[fd] == NetStatus.DISCONNECT then --未连接的话 直接关闭
		return 
	end 
	self._connection[fd] = NetStatus. READY_CLOSE 
	--socketdriver.shutdown(fd)--连接到达最大，关闭当前套接字 
	socketdriver.close(fd) --直接关闭客户端 
end

function MsgService:WriteClient(fd,msg)
	if self._connection[fd] ~= NetStatus.CONNECT  then 
		return  
	end   
	socketdriver.send(fd, msg) 
end

--打开一个网络监听服务
function MsgService:Command_OpenGateWay(source,conf)
	assert(conf.login,"没有填写登录端口")
	assert(not self._socket,"已经存在一个服务消息了")
	local port =  assert(tonumber(conf.port),"未填入监听端口")
	local address = conf.address or "0.0.0.0"  

	self._mediatorObj:SetLoginHandle(conf.login)
	self._maxclient = conf.maxclient or 1024 
	self._nodelay = conf.nodelay 
	self._socket = socketdriver.listen(address,port) 
	socketdriver.start(self._socket)
	skynet.error(string.format("GateWay %s Start Listen %s:%d", self._gatewayName,address,port)) 
	return self._mediatorObj:OpenGateWayHandle(source)--执行回调
end  

function MsgService:Command_CloseGateWay(source) 
	assert( self._socket,"试图关闭一个不存在的网络服务") 
	socketdriver.close( self._socket )--关闭当前服务器  
	self._mediatorObj:CloseGateWayHandle(source)--源 和 数据
end 

function MsgService:RegisterCommand(commandTable) 
	commandTable.open =  handler(self,MsgService.Command_OpenGateWay) 
	commandTable.close =  handler(self,MsgService.Command_CloseGateWay)  
end  
   
function MsgService:FindCommandHandle(command)
	return  self._commandList[command]  or self._mediatorObj:FindCommand(command)
 end
  
--初始化系统
function MsgService:InitSystem()   
	self:InitNetDispatch()
end     
local MsgService = MsgService.new(...)