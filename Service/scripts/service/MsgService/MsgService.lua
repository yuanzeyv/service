local skynet = require "skynet"
local netpack = require "skynet.netpack"
local socketdriver = require "skynet.socketdriver"
local MsgMediator = require "MsgService.MsgMediator" 
local MsgService = class("MsgService")    
require "Tool.Class"  
function MsgService:Openclient(fd)--当打开一个客户端的时候
	if self._connection[fd] ~= false then--如果当前已经连接了的话， 
		return 
	end
	self._connection[fd] = true--当前套接字可以读了
	socketdriver.start(fd)--开始监听这个套接字 
end
--直接关闭一个客户端
function MsgService:CloseClient(fd)
	local c = self._connection[fd]--如果当前存在客户端连接的话
	if c ~= nil then 
		self._connection[fd] = nil 
		socketdriver.close(fd) --直接关闭客户端
	end
end

function MsgService:WriteClient(fd,msg)
	if self._connection[fd] ~= true then--当前必须连接了
		return 
	end   
	socketdriver.send(fd, msg) 
end 
--打开一个网络监听服务
function MsgService:Command_OpenListen(source,conf)
	assert(conf.login,"没有填写登录端口")--没有填写登录服务器的话
	self._port =  assert(tonumber(conf.port),"未填入监听端口")
	assert(not self._socket,"已经存在一个服务消息了") --连续打开时的容错
	self._msgMediatorObj:SetLoginHandle(conf.login)
	self._address = conf.address or "0.0.0.0" 
	self._maxclient = conf.maxclient or 1024 
	self._nodelay = conf.nodelay 
	self._socket = socketdriver.listen(self._address, self._port)-- 设置监听信息
	socketdriver.start(self._socket)--开始监听端口  
	skynet.error(string.format("Listen on %s:%d", self._address, self._port)) 
	return self._msgMediatorObj:OpenListenHandle(source, conf)--源 和 数据
end 

function MsgService:Command_CloseListen(source) 
	assert( self._socket,"试图关闭一个不存在的网络服务") 
	self._msgMediatorObj:CloseListenHandle(source)--源 和 数据
	socketdriver.close( self._socket )--关闭当前服务器
	self._socket = nil
end 

function MsgService:GetCMD()
    local CMD = {}
	CMD.open =  handler(self,MsgService.Command_OpenListen) 
	CMD.close =  handler(self,MsgService.Command_CloseListen) 
	return CMD
end  
 
function MsgService:Server_DispatchMsg(fd, msg, sz) --消息派发
	if not self._connection[fd] then
		skynet.error(string.format("Drop message from fd (%d) : %s", fd, netpack.tostring(msg,sz)))  
		return 
	end   
	self._msgMediatorObj:MessageDispose(fd, msg, sz)
end

function MsgService:Server_DispatchQueue()
	local fd, msg, sz = netpack.pop(self._queue)
	if fd then
		skynet.fork(handler(self,self.Server_DispatchQueue)) --用几个进程轮询处理事件派发 
		self:Server_DispatchMsg(fd, msg, sz) 
		for fd, msg, sz in netpack.pop, self._queue do --用最快的速度将所有消息打包完毕
			self:Server_DispatchMsg(fd, msg, sz) 
		end
	end
end

function MsgService:Server_ConnectClient(fd, msg) 
	if self._client_number >= self._maxclient then--如果连接已经到了最大数量的话
		socketdriver.shutdown(fd)--关闭当前的套接字 
		return
	end
	local a = self._nodelay and socketdriver.nodelay(fd)  --设置当前不时延
	self._connection[fd] = false--设置当前fd已经连接
	self._client_number = self._client_number + 1 --连接数目+1
	self._msgMediatorObj:ConnectDispose(fd, msg)--调用连接函数
end 
function MsgService:Server_DeconnectClient(fd)  --close 
	if fd ~= self._socket then 
		self._client_number = self._client_number - 1--数目减一
		if self._connection[fd] then--如果当前存在的话
		   self._connection[fd] = nil
		end
		self._msgMediatorObj:DisconnectDispose(fd) --电泳关闭连接的函数
	else
		self._socket = nil
	end
end 

function MsgService:Server_ClientError(fd, msg)
	if fd == self._socket then
		skynet.error("MsgService accept error:",msg)
	else
		socketdriver.shutdown(fd)--断开当前的连接
		self._connection[fd] = false
		self._msgMediatorObj:ErrorDispose(fd, msg)--调用错误的函数
	end
end 

function MsgService:Server_ClientWarning(fd, size) 
	self._msgMediatorObj:WarningDispose(fd, size) 
end
function MsgService:GetServerList()
    local serverList = {}   
	serverList.more = 	 handler(self,self.Server_DispatchQueue) 
	serverList.data = 	 handler(self,self.Server_DispatchMsg)
	serverList.open = 	 handler(self,self.Server_ConnectClient)
	serverList.close =	 handler(self,self.Server_DeconnectClient)
	serverList.error =	 handler(self,self.Server_ClientError)  
	serverList.warning = handler(self,self.Server_ClientWarning)
	return serverList 
end  
--初始化消息事件派发
function MsgService:InitEventDispatch() 
	skynet.dispatch("lua",function (_, source, cmd, ...)    
		local func = self._commandList[cmd] or self._msgMediatorObj:FindCommand(cmd) --优先查找自己的命令 ，如果没有查找中介
		if func then
			skynet.ret(skynet.pack(func(source, ...))) 
		end  
	end) 
	skynet.register_protocol {
		name = "client",
		id = skynet.PTYPE_CLIENT,
		pack = skynet.pack, 
 	} 
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
			local _ = type and self._serverList[type](...)  
		end
	}   
end 

function MsgService:ctor(...) 
	self:InitServerData(...)
	self:InitServer()
end
function MsgService:GetName()
	return self._serverName
end 
function MsgService:InitServerData(serverName) 
	self._serverName = assert(serverName,"not input server name")
	self._msgMediatorObj = MsgMediator.new(self)  --获取到消息处理中介
	self._commandList = self:GetCMD()
	self._serverList = self:GetServerList()

	self._nodelay = false
	self._address = nil
	self._port = nil
	self._socket = nil
	self._maxclient	= nil
	self._client_number = 0

	self._queue	= nil	--消息执行队列
	self._connection = {}--true : connected   nil : closed  false : close read 
end

function MsgService:InitServer() 
	skynet.start(function () 
		self:InitEventDispatch()--初始化事件
		self:InitNetDispatch()  --初始化网络
	end)
end
local MsgServiceObj = MsgService.new(...)