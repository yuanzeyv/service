require "Tool.Class" 
local skynet = require "skynet" 
local LoginDataBaseOper = class("LoginDataBaseOper")  

function LoginDataBaseOper:ctor() 
	self._database = skynet.localname(".database")
end   

function LoginDataBaseOper:VirifyAccount(account,password)    
    local  t = skynet.call(self._database,"lua","query","select * from user_table where account = \"" .. account .. "\";")  
	if not t or t.errno then 
		return G_ErrorConf.StatusERROR --返回数据错误（未知错误）
	end 
	if t.error then 
		return G_ErrorConf.DataOpertionFaile --数据库操作错误
	end   
	if #t == 0 then 
		return G_ErrorConf.AccountNotExist --数据库操作错误
	end
	if t[1].password ~= tostring(password) then 
		return G_ErrorConf.PasswordError --数据库操作错误
	end   
	return G_ErrorConf.ExecuteSuccess
end 
return  LoginDataBaseOper 