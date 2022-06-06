
local Service = require "Service" 
local ServiceDB = class("ServiceDB",Service)       
redis = require "skynet.db.redis"
--与 网络套接字重叠了，需要单独隔离出来
function ServiceDB:__InitServerData(...) 
    Service.__InitServerData(self,...) 
    self._redis = nil
end

function ServiceDB:ConnectRedis() 
	self._redis = redis.connect({
        host = "127.0.0.1" ,
        port = 6379 ,
        db = 0
    } ) 
end 

function ServiceDB:RedisExec(func,...) 
    return self._redis and self._redis[func](self._redis,...)
end  
return ServiceDB