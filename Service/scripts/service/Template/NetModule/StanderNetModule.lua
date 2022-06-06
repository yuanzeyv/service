local StanderNetModule = class("StanderNetModule")  
local netpack = require "skynet.netpack"
local socketdriver = require "skynet.socketdriver"  
local NetStatus = {DISCONNECT = nil,OPEN = 1,CONNECT = 2,READY_CLOSE = 3} 
function StanderNetModule:Server_SocketDispatchMsg(fd, msg, sz) --消息派发
	if self._connection[fd] ~= NetStatus.CONNECT then--不等于连接状态的话
		skynet.error(string.format("Drop message from fd (%d) : %s", fd, netpack.tostring(msg,sz)))  
		return 
	end   
	self:MessageDispose(fd, msg, sz)--处理消息
end

function StanderNetModule:Server_SocketDispatchMore()
	local fd, msg, sz = netpack.pop(self._queue)
	if fd then
		skynet.fork(handler(self,self.Server_DispatchQueue)) --用几个进程轮询处理事件派发 
		self:Server_SocketDispatchMsg(fd, msg, sz) 
		for fd, msg, sz in netpack.pop, self._queue do --用最快的速度将所有消息打包完毕
			self:Server_SocketDispatchMsg(fd, msg, sz) 
		end
	end
end 
function StanderNetModule:Server_SocketOpen(fd, msg)  
	if self._loginCount >= self._maxLoginCount then
		socketdriver.shutdown(fd)--连接到达最大，关闭当前套接字 
		return
	end
	self._loginCount = self._loginCount + 1 --连接数目+1
	local _ = self._nodelay and socketdriver.nodelay(fd) --设置当前不时延 
	self._connection[fd] = NetStatus.OPEN --设置当前网络为打开状态
	self:SocketOpenHandle(fd, msg)--处理连接
end   

function StanderNetModule:Server_SocketClose(fd)  --close  
	if fd ~= self._socket then   
        --这里其实是一个容错但是我希望直接报错
		assert(self._connection[fd],"socket对象不存在" .. fd)--当前连接状态必须是 准备关闭的时候才能进入
		self._loginCount = self._loginCount - 1--数目减一
		self._connection[fd] = NetStatus.DISCONNECT --彻底关闭
		self:SocketCloseHandle(fd) --断开连接的回调
	else 
		self._socket = nil
	end
end 


function StanderNetModule:Server_SocketError(fd, msg)--当程序收到错误的消息时。
	if fd == self._socket then--如果当前为主socket的话
		skynet.error("StanderNetModule accept error:",msg) --仅仅发送一个打印
	else  
		self:CloseClient(fd) --关闭当前的套接字
		self:SocketErrorHandle(fd, msg)--调用错误的函数
	end
end 

function StanderNetModule:Server_ClientWarning(fd, size) 
	self:SocketWarningHandle(fd, size) --处理错误消息
end

function StanderNetModule:GetSocketHandleList()
	local serverList = setmetatable({}, { __gc = function() netpack.clear(self._queue) end }) 
	serverList.more = 	 handler(self,self.Server_SocketDispatchMore)--多条消息
	serverList.data = 	 handler(self,self.Server_SocketDispatchMsg)--单条消息
	serverList.open = 	 handler(self,self.Server_SocketOpen)--客户端准备连接
	serverList.close =	 handler(self,self.Server_SocketClose)--客户端关闭连接
	serverList.error =	 handler(self,self.Server_SocketError)--客户端发出错误告示
	serverList.warning = handler(self,self.Server_ClientWarning)--客户端发出警告告示
	return serverList 
end    

function StanderNetModule:OpenListen(fd) --打开一个客户端的网络连接
	if self._connection[fd] ~= NetStatus.OPEN then --已经记录的情况，但是未连接 
        return 
    end
	socketdriver.start(fd) --开始接听
	self._connection[fd] = NetStatus.CONNECT 
end

function StanderNetModule:CloseListen(fd) --打开一个客户端的网络连接
	if self._connection[fd] ~= NetStatus.CONNECT then --已经记录的情况，但是未连接 
        return 
    end
	socketdriver.abandon(fd) --放弃监听
	self._connection[fd] = NetStatus.OPEN 
end


function StanderNetModule:CloseClient(fd)--关闭一个客户端的网络连接 
	if self._connection[fd] == NetStatus.DISCONNECT or self._connection[fd] == NetStatus.READY_CLOSE then--已经关闭的情况下
		return --直接返回
	end 
	self._connection[fd] = NetStatus.READY_CLOSE --当前客户端准备被关闭 
	socketdriver.close(fd) --走完整流程 关闭客户端
end

function StanderNetModule:WriteClient(fd,msg)
	if self._connection[fd] ~= NetStatus.CONNECT then--如果当前客户端是连接状态的话
		return 
	end   
	socketdriver.send(fd, msg) 
end 

--打开一个网络监听服务
function StanderNetModule:ctor(...) 
    self:InitData(...)  
end 

function StanderNetModule:InitData(conf)  
	self._loginCount = 0 --登录的客户端数目 
	self._maxLoginCount = conf.maxListen or 100

	self._connection = {} 
	self._socket = nil    --被监听的socket
	self._socketHandleList = self:GetSocketHandleList() --回调列表 
	self._nodelay = conf.nodelay  --大数据包  
	self._queue	= nil	  --消息执行队列
	--初始化事件派发
    self:InitNetDispatch() --打开后，会监听网络消息 
	self:OpenGateWay(conf)
end    
function StanderNetModule:OpenGateWay(conf) 
	local port =  assert(tonumber(conf.port),"未填入监听端口")
	local address = conf.address or "0.0.0.0"  
	self._socket = socketdriver.listen(address,port)
	socketdriver.start(self._socket) --开始监听socket  
	return self:OpenSocketHandle(conf)--一个网络服务创建完成后，会执行初始化
end    

function StanderNetModule:CloseGateWay() 
	assert( self._socket,"试图关闭一个不存在的网络服务") 
	socketdriver.close( self._socket )--关闭当前服务器  
	self:CloseSocketHandle()--源 和 数据
end    

function StanderNetModule:InitNetDispatch()    
	skynet.register_protocol {
		name = "socket",
		id = skynet.PTYPE_SOCKET,
		unpack = function ( msg, sz )
			return netpack.filter(self._queue, msg, sz)
		end,
		dispatch = function (_, _, q, type, ...)
			self._queue = q   
			if self._socketHandleList[type] then 
				self._socketHandleList[type](...)   
			end 
		end
	}     
end   

--收到数据消息处理
function StanderNetModule:MessageDispose(fd, msg, sz)
end
--收到进入消息处理
function StanderNetModule:SocketOpenHandle(fd)
end
--收到退出消息处理
function StanderNetModule:SocketCloseHandle(fd)
end
--收到错误消息处理
function StanderNetModule:SocketErrorHandle(fd, msg)
end
--收到警告消息处理
function StanderNetModule:SocketWarningHandle(fd, size)
end
--打开一个网络监听服务
function StanderNetModule:OpenSocketHandle(source,conf)   
end   
--关闭一个网络监听服务
function StanderNetModule:CloseSocketHandle(source)   
end     
return  StanderNetModule