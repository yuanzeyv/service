local StanderNetModule =  require "NetModule.StanderNetModule" 
local GateWayControl = class("GateWayControl",StanderNetModule)       
local netpack = require "skynet.netpack" 
local AuthObj =  require "MsgService.ConnectObj.AuthObj"
function GateWayControl:ChangeStatus(fd,status) 
	self._SocketOnline[fd] = status
end

--收到数据消息处理
function GateWayControl:MessageDispose(fd, msg, sz) 
	local netObj = assert(self._SocketOnline[fd],"消息处理对象不存在，请检查代码")--首先获取到当前的连接对象  
	netObj:Execute(self.msgServer,fd,msg,sz)  
end
--收到进入消息处理
function GateWayControl:SocketOpenHandle(fd,addr)
	self:OpenListen(fd)
	self._SocketOnline[fd] =  AuthObj.new(fd,addr,self)--当一个用户连接成功时 
end
--收到退出消息处理
function GateWayControl:SocketCloseHandle(fd)
	skynet.error(string.format("(%d)对应的套接字，进入了SocketClose,将清除连接信息",fd))  
	assert(self._SocketOnline[fd],"连接信息不存在")  
	self._SocketOnline[fd] = nil --删除连接状态信息     
end 

function GateWayControl:WriteClient(fd,msg)--写一个数据 
	StanderNetModule.WriteClient(self,fd,string.pack(">I2",#msg) .. msg ) --写数据
end 

function GateWayControl:InitData(conf,msgServer) 
	StanderNetModule.InitData(self,conf)   
	self.msgServer = msgServer --主服务的对象 
	self._SocketOnline = {} 
end 
return GateWayControl 

