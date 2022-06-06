local Service = require "Service"  
local MainService = class("MainService",Service)       
--初始化系统
function MainService:InitSystem()    
	skynet.uniqueservice(true,"ConfigService")--打开登录服务器
	skynet.newservice("DataBaseService")--打开数据库管理服务  
	skynet.newservice("SystemService/SystemService") --打开系统管理服务  
	local LoginService = skynet.newservice("LoginService",8888)--打开登录服务器 
	local gate = skynet.newservice("MsgService","sample") --打开消息服务器
	skynet.call(gate,"lua","open",{login = LoginService, port = 8889,maxclient = 64}) --打开消息服务器    
end   
local service = MainService.new()
