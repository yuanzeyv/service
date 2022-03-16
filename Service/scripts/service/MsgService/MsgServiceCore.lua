local skynet = require "skynet"
local netpack = require "skynet.netpack"
local socketdriver = require "skynet.socketdriver"
require "Tool.Class"  
local MsgServiceCore = class("MsgServiceCore")   
local function printf(...) 
    skynet.error(string.format(...))
end 

function MsgServiceCore:GetCMD()
	local CMD = setmetatable({}, { __gc = function() netpack.clear(self._queue) end })
	CMD.open = function ( source , conf ) 
		assert(conf.port,"未填入监听端口")
		assert(not self._socket,"已经存在一个服务消息了") 
		self._address = conf.address or "0.0.0.0"
		self._port  = conf.port
		self._maxclient = conf.maxclient or 1024 
		self._nodelay = conf.nodelay 
		self._socket = socketdriver.listen(self._address, self._port) 
		socketdriver.start(self._socket)
		printf("Listen on %s:%d", self._address, self._port) 
		if self._handleList.open then
			return self._handleList.open(source, conf)
		end
	end
	CMD.close = function ()
		assert( self._socket )
		socketdriver.close( self._socket )--关闭当前服务器
	end
	return CMD
end 

function MsgServiceCore:GetSocketHandle()
	local HandleList = {} 
	HandleList.dispatch_msg =function (fd, msg, sz) 
		if not self._connection[fd] then
			printf("Drop message from fd (%d) : %s", fd, netpack.tostring(msg,sz))
		end 
		self._handleList.message(fd, msg, sz)
	end
	HandleList.dispatch_queue = function()
		local fd, msg, sz = netpack.pop(self._queue)--
		if fd then
			skynet.fork(HandleList.dispatch_queue) --用几个进程轮询处理事件派发
			HandleList.dispatch_msg(fd, msg, sz) 
			for fd, msg, sz in netpack.pop, self._queue do --用最快的速度将所有消息打包完毕
				HandleList.dispatch_msg(fd, msg, sz) 
			end
		end
	end
	HandleList.connect_client = function (fd, msg) 
		if self._client_number >= self._maxclient then
			socketdriver.shutdown(fd)   
			return
		end
		local a = self._nodelay and socketdriver.nodelay(fd)  
		self._connection[fd] = true 
		self._client_number = self._client_number + 1 
		self._handleList.connect(fd, msg)
	end 
	HandleList.deconnect_client = function (fd) 
		if fd ~= self._socket then 
			self._client_number = self._client_number - 1--数目减一
			if self._connection[fd] then--如果当前存在的话
				self._connection[fd] = false
			end
			if self._handleList.disconnect then
				self._handleList.disconnect(fd) --电泳关闭连接的函数
			end
		else
			self._socket = nil
		end
	end
	HandleList.client_error = function (fd, msg)
		if fd == self._socket then
			skynet.error("MsgServiceCore accept error:",msg)
		else
			socketdriver.shutdown(fd)--断开当前的连接
			if self._handleList.error then--如果有错误的接收的话
				self._handleList.error(fd, msg)--调用错误的函数
			end
		end
	end 
	HandleList.client_warning = function (fd, size)
		if self._handleList.warning then
			self._handleList.warning(fd, size)
		end
	end
	return HandleList
end 
function MsgServiceCore:GetSocketMsgList() 
	local socketHandle = {} 
	local DispatchHandle = self:GetSocketHandle()  
	socketHandle.more = DispatchHandle.dispatch_queue
	socketHandle.data = DispatchHandle.dispatch_msg
	socketHandle.open = DispatchHandle.connect_client
	socketHandle.close = DispatchHandle.deconnect_client
	socketHandle.error = DispatchHandle.client_error 
	socketHandle.warning = DispatchHandle.client_warning
	return socketHandle
end 
 
function MsgServiceCore:Openclient(fd)--当打开一个客户端的时候
	if self._connection[fd] then--如果当前已经连接了的话， 
		socketdriver.start(fd)--开始监听这个套接字 
	end
end

function MsgServiceCore:Closeclient(fd)
	local c = self._connection[fd]
	if c ~= nil then 
		self._connection[fd] = nil
		socketdriver.close(fd)
	end
end

function MsgServiceCore:WriteClient(fd,msg)
	if self._connection[fd] then--如果当前已经连接了的话，
		printf("sendMsg:(%s) %s", fd,msg)
		socketdriver.send(fd, msg) 
	end
end 

function MsgServiceCore:SkynetLuaDispatch(_, address, cmd, ...)
	local func = self._commandList[cmd]
	if func then
		skynet.ret(skynet.pack(func(address, ...)))
	else--不存在命令  调用 handle里面的函数  
		skynet.ret(skynet.pack(self._handleList.command(cmd, address, ...)))
	end 
end 

function MsgServiceCore:InitEventDispatch() 
	local SocketHandle = self:GetSocketMsgList()
	skynet.register_protocol {
		name = "socket",
		id = skynet.PTYPE_SOCKET,
		unpack = function ( msg, sz )
			return netpack.filter(self._queue, msg, sz)
		end,
		dispatch = function (_, _, q, type, ...)
			self._queue = q
			local _ = type and SocketHandle[type](...)  
		end
	}  
	skynet.dispatch("lua",function (_, address, cmd, ...)  
		self:SkynetLuaDispatch(_, address, cmd, ...)
	end)
	
	skynet.register_protocol {
		name = "client",
		id = skynet.PTYPE_CLIENT,
		pack = skynet.pack, 
 	} 
end 
 

function MsgServiceCore:ctor(handlerList) 
	self:InitServerData(handlerList)
	self:InitServer()
end

function MsgServiceCore:InitServerData(handlerList) 
	assert(handlerList,"配置错误")
	assert(handlerList.message,"消息处理未找到")
	assert(handlerList.connect,"连接函数未找到") 
	self._handleList = handlerList
	self._commandList = self:GetCMD()

	
	self._nodelay = false
	--socket的配置项
	self._address = nil
	self._port = nil
	self._socket = nil
	self._maxclient	= nil
	self._client_number = 0

	self._queue	= nil	
	self._connection = {}--true : connected   nil : closed  false : close read 
end

function MsgServiceCore:InitServer() 
	skynet.start(function () 
		self:InitEventDispatch()  
	end)
end
return MsgServiceCore