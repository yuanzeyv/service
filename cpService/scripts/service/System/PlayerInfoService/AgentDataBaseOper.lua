require "Tool.Class" 
local skynet = require "skynet" 
local LoginDataBaseOper = class("LoginDataBaseOper")  

function LoginDataBaseOper:ctor() 
	self._database = skynet.localname(".database")
end   
function LoginDataBaseOper:GetUserInfo(account)    
    local  t = skynet.call(self._database,"lua","query","select * from user_table where account = \"" .. account .. "\";")  
	if t.error then 
		return ErrorType.DataOpertionFaile
	end 
	if #t == 0 then 
		return ErrorType.NotFindDataInfo
	end  
	return ErrorType.ExecuteSuccess,t[1] 
end 
return  LoginDataBaseOper 