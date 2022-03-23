local skynet = require "skynet"  
require "Tool.Class"   
local redis  = require "skynet.db.redis"
local RedisService = class("RedisService")     
function RedisService:GetCMD()
    local CMD = {}
	return CMD
end  

function RedisService:InitEventDispatch() 
-- If you want to fork a work thread , you MUST do it in CMD.login
    skynet.dispatch("lua", function(session,source,command,...)   
        local f = assert(self._command[command])  
        skynet.ret(skynet.pack(f(source,...)))
    end)   
end  

function RedisService:ctor()    
    self:InitServerData(data) 
	self:InitServer() 
end

function RedisService:InitServerData(data)  
    self._command  = self:GetCMD()  
end  
 
function RedisService:InitRedis()   
    local conf = {
        host = "127.0.0.1" ,
        port = 6379 ,
        db = 0
    } 
	local db = redis.connect(conf) 
end  

function RedisService:InitServer()  
	skynet.start(function ()  
		self:InitEventDispatch()    
        self:InitRedis()
	end)
end
local RedisService = RedisService.new()