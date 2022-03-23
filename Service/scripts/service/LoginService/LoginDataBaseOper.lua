require "Tool.Class" 
local skynet = require "skynet" 
local LoginDataBaseOper = class("LoginDataBaseOper")  

function LoginDataBaseOper:ctor() 
	self._database = skynet.localname(".database")
end   
function LoginDataBaseOper:VirifyAccount(account,password)    
    local  t = skynet.call(self._database,"lua","query","select * from user_table where account = \"" .. account .. "\";")  
	assert(t and not t.errno,407) 
	assert(#t > 0 ,402) 
	assert(t[1].password == tostring(password),404) 
end 
return  LoginDataBaseOper 