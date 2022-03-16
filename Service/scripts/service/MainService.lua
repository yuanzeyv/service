local skynet = require "skynet"  
require "Tool.Json"
skynet.start(function() 
	local LoginService = skynet.newservice("LoginService",8888,".login")--打开登录服务器
	local gate = skynet.newservice("MsgService",LoginService) --打开消息服务器
	skynet.call(gate,"lua","open",{port = 8889,maxclient = 64,servername = "sample"}) --打开消息服务器
	skynet.newservice("SystemService/SystemService",0) --打开系统管理服务  
	
	skynet.newservice("Box2dTest",1); 
end)