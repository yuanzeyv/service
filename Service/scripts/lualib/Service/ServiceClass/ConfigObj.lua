local ConfigObj = class("ConfigObj")    
function ConfigObj:ctor()  
    self:InitData()
end  
function ConfigObj:InitData()
    self._configService = skynet.queryservice(true,"ConfigService")  --自带一个配置服务 
end  
 
function ConfigObj:RetrievalTable(tableName)
    return skynet.call(self._configService,"lua","InspaectionTable",tableName) 
end 

function ConfigObj:RetrievalFiled(tableName,filedName)
    return skynet.call(self._configService,"lua","InspaectionCell",tableName,filedName) 
end
return ConfigObj