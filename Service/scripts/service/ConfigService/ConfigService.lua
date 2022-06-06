local ServiceDB = require "ServiceDB"  
local ConfigService = class("ConfigService",ServiceDB)      
require "Tool.Tool"      
function ConfigService:InitServerData(...)
    self.loadList = {}  
    self.filedTable = {}
end 

function ConfigService:InitServer() 
    self:InitLoadList()
end 

--初始化加载表
function ConfigService:InitLoadList()  
    self.loadList["con_SystemSetting"] = "Config/con_SystemSetting"--加入系统ID表  
end 
--初始化系统
function ConfigService:InitSystem()    
    self:ConnectRedis()
    self:LoadConfig()    
end    

function ConfigService:GetTableFiledName(tableName)
    return  tableName .. "_filedHash"
end  
function ConfigService:GetTableFiled(tableName)
    local fileTableName = self:GetTableFiledName(tableName)
    if self.filedTable[fileTableName] == nil then 
        self.filedTable[tableName] =  self:GetMset(fileTableName) 
    end  
    return self.filedTable[tableName]  
end 

function ConfigService:GetMset(key)
    local retTable = {} 
    if self:RedisExec("EXISTS", key) == 0 then 
        return retTable
    end  
    local keys = self:RedisExec("HKEYS", key) 
    local vals = self:RedisExec("HVALS", key) 
    for i = 1 , #keys ,1 do 
        retTable[keys[i]] = vals[i]
    end 
    return retTable
end 
--直接给我表名
function ConfigService:Command_InspaectionTable(source,tableName) --传入表名 返回表结构   
    local tableInfo = self:GetMset(tableName)--获取到所有的字段表信息    
    if not tableInfo then return nil end  
    local fileTable = self:GetTableFiled(tableName)
    if not fileTable then --如果不存在字段索引表,直接返回
        return tableInfo
    end  
    local retList = {}--将要返回的列表 
    local memory =Tool:TransFromTable(fileTable)
    for v,k in pairs(tableInfo) do--读取当前表中的所有信息
        local splitIntfo = Tool:Split(v,":")--绝对会有第二个值 a:a 
        local id,minorMapping = splitIntfo[1],splitIntfo[2]   
        if memory[minorMapping] then --一定会有的 
            if not retList[id] then  retList[id] = {}  end 
            retList[id][memory[minorMapping]] = k 
        end  
    end  
    return retList 
end 
function ConfigService:Command_InspaectionCell(source,tableName,id) 
    local fileTable = self:GetTableFiled(tableName)--获取到字段表
    if not fileTable then --如果不存在字段索引表,直接返回
        return self:RedisExec("HGET", tableName,id)  
    end
    local memory =Tool:TransFromTable(fileTable)
    local retTable = {}
    for v,k in pairs(memory) do
        local data = self:RedisExec("HGET", tableName,id ..":"..v ) 
        if data then 
            retTable[k] = data 
        end 
    end  
    return retTable
end   
function ConfigService:Command_InspaectionCell(source,tableName,id) 
    local fileTable = self:GetTableFiled(tableName)--获取到字段表
    if not fileTable then --如果不存在字段索引表,直接返回
        return self:RedisExec("HGET", tableName,id)  
    end
    local memory =Tool:TransFromTable(fileTable)
    local retTable = {}
    for v,k in pairs(memory) do
        local data = self:RedisExec("HGET", tableName,id ..":"..v ) 
        if data then 
            retTable[k] = data 
        end 
    end  
    return retTable
end   
function ConfigService:Command_InspaectionTableIsExist(source,tableName)  
    return self:RedisExec("EXISTS", key) == 1 
end 

--初始化信息
function ConfigService:RegisterCommand(commandTable)
    commandTable.InspaectionTable =  handler(self,ConfigService.Command_InspaectionTable )--检视Table 
    commandTable.InspaectionCell  =  handler(self,ConfigService.Command_InspaectionCell)--检视单元 
    commandTable.InspaectionTableIsExist =  handler(self,ConfigService.Command_InspaectionTableIsExist)--检视单元 
end  
--加载表
function ConfigService:LoadConfig()  
    self:RedisExec("FLUSHALL")--将清楚所有的redis数据
    for table_name,table_value in pairs(self.loadList) do
       local config = require(table_value) --打开当前的表 
       --表字段存储
       local filed = { __Count = 0 }  
       for v,k in pairs(config) do --全部都使用 哈希表 映射
            if type(k) == "table" then--如果当前是列表的话
                for cellV,cellK in pairs(k) do
                    --只有这两种状态才会进入
                    if type(cellK) ~= "string" or  type(cellK) ~= "number" then 
                        if not filed[cellV] then 
                            filed[cellV] = filed.__Count 
                            filed.__Count = filed.__Count + 1
                            self:RedisExec("HMSET",self:GetTableFiledName(table_name),cellV ,filed[cellV] )
                        end 
                        self:RedisExec("HMSET",table_name,v..":"..filed[cellV] ,cellK)
                    end
                end
           else
                self:RedisExec("HMSET",table_name,v ,k )
           end  
       end
    end
end
 
local ConfigService = ConfigService.new()