require "Tool.Class" 
local skynet = require "skynet" 
local LoginDataBaseOper = class("LoginDataBaseOper")  

function LoginDataBaseOper:ctor() 
	self._database = skynet.localname(".database")
end   
function LoginDataBaseOper:GetUserInfo(account)    
    local  t = skynet.call(self._database,"lua","query","select * from user_table where account = \"" .. account .. "\";")  
	if t.error then 
		return G_ErrorConf.DataOpertionFaile
	end 
	if #t == 0 then 
		return G_ErrorConf.NotFindDataInfo
	end  
	return G_ErrorConf.ExecuteSuccess,t[1] 
end 
return  LoginDataBaseOper 