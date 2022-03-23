--[[
    游戏肯定是有角色的
    游戏肯定是由背包的
    游戏肯定是有任务的
    接竹竿肯定是有分数的
    接竹竿肯定是有游戏历史的
    接竹竿肯定是有游戏记录的
 
    角色表代表主键
]]

local skynet = require "skynet"  
require "Tool.Class"   
require "skynet.manager"
local mysql = require "skynet.db.mysql"
local DataBaseService = class("DataBaseService")     
function DataBaseService:GetCMD()
    local CMD = {} 
	CMD.query =  handler(self,DataBaseService.Command_Query)
	return CMD
end  
function DataBaseService:Command_Query(source,  queryStr)--登录成功，secret可以用来加解密数据   
    res = self._db:query(queryStr)  
    return res
end 
function DataBaseService:InitEventDispatch() 
-- If you want to fork a work thread , you MUST do it in CMD.login
    skynet.dispatch("lua", function(session,source,command,...)   
        local f = assert(self._command[command])  
        skynet.ret(skynet.pack(f(source,...)))
    end)   
end  


function DataBaseService:ctor()   
    local data = { 
		host="127.0.0.1",
		port=3306,
		account="root",
		pass="@Yuan980520",
        charSet="utf8mb4",
		databaseName="SuperGame",
		packetSize = 1024 * 1024
    }
    self:InitServerData(data)  
	self:InitServer()
end

function DataBaseService:InitServerData(data) 
    self._databaseName =  assert(data.databaseName ,"please enter database name")--需要数据库名称
    self._account = assert(data.account ,"please enter account")--需要用户名
    self._pass = assert(data.pass ,"please enter password")--需要用户密码
    self._charSet = data.charSet or "utf8mb4"--需要数据库编码值 
    self._maxPacketSize = data.packetSize or (1024 * 1024)--是否有限制
    self._host = data.host or "127.0.0.1" --需要主机
    self._port = data.port or 3306--需要端口
    self._command  = self:GetCMD() 
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

function DataBaseService:InitServer()  
	skynet.start(function ()  
		skynet.register(".database")--注册当前服务器的名称
		self:InitEventDispatch()  
        self:ConnectMySQL()
	end)
end
local DataBaseService = DataBaseService.new()