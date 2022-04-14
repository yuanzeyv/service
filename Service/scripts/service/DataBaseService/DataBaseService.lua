local mysql = require "skynet.db.mysql"    
local ServiceModle = require "ServiceModle.ServiceModle" 
local DataBaseService = class("DataBaseService",ServiceModle)     
function DataBaseService:Command_Query(source,  queryStr)--登录成功，secret可以用来加解密数据   
    res = self._db:query(queryStr)  
    return res
end 

function DataBaseService:RegisterCommand(commandTable) 
	commandTable.query =  handler(self,self.Command_Query)  
end  
 
function DataBaseService:InitServerData()   
    local data = { 
		host="127.0.0.1",
		port=3306,
		account="root",
		pass="@Yuan980520",
        charSet="utf8mb4",
		databaseName="SuperGame",
		packetSize = 1024 * 1024
    }
    self._databaseName =  assert(data.databaseName ,"please enter database name")--需要数据库名称
    self._account = assert(data.account ,"please enter account")--需要用户名
    self._pass = assert(data.pass ,"please enter password")--需要用户密码
    self._charSet = data.charSet or "utf8mb4"--需要数据库编码值 
    self._maxPacketSize = data.packetSize or (1024 * 1024)--是否有限制
    self._host = data.host or "127.0.0.1" --需要主机
    self._port = data.port or 3306--需要端口 
    self._db = nil  
end     

--开始连接数据库
function DataBaseService:ConnectMySQL()
	self._db =mysql.connect({
		host = self._host,
		port= self._port,
		database= self._databaseName,
		user= self._account,
		password= self._pass,
        charset= self._charSet,
		max_packet_size = self._maxPacketSize,
		on_connect = function (db)
            db:query("set charset utf8mb4");
        end
	})   
    assert(self._db,"failed to connect mysql")--连接到mysql  
end 
--初始化系统
function DataBaseService:InitSystem()    
    skynet.register(".database")--注册当前服务器的名称 
    self:ConnectMySQL()
end     
local DataBaseService = DataBaseService.new() 
