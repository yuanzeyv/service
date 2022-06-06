require "Tool.Class" 
local skynet = require "skynet" 
local LoginDataBaseOper = class("LoginDataBaseOper")  

function LoginDataBaseOper:ctor() 
	self._database = skynet.localname(".database")
end   

function LoginDataBaseOper:VirifyAccount(account,password)     
    local  t = skynet.call(self._database,"lua","query","select * from TAccount where account = \"" .. account .. "\";")  
	if not t or t.errno then  
		return ErrorType.StatusERROR --返回数据错误（未知错误）
	end  
	if t.error then 
		return ErrorType.DataOpertionFaile --数据库操作错误
	end    
	if #t == 0 then 
		return ErrorType.AccountNotExist --数据库操作错误
	end 
	--if t[1].password ~= tostring(password) then 
	--	return ErrorType.PasswordError --数据库操作错误
	--end    
	return ErrorType.ExecuteSuccess
end 

function LoginDataBaseOper:RegisterAccount(account,password) 
    local  t = skynet.call(self._database,"lua","query",string.format("INSERT INTO TAccount (Account,pass,RegisterDate) VALUES (\"%s\",\"%s\",NOW());",account,password)) 
	if not t or t.errno then  
		return ErrorType.StatusERROR --返回数据错误（未知错误）
	end  
	return ErrorType.ExecuteSuccess
end 
return  LoginDataBaseOper 