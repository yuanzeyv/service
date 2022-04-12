local BaseService = require "Template.Service.BaseService"   
local HallFacade = class("HallFacade",BaseService) 
local HallModule = require "Template.Hall.Hall.Module.HallModule" 
local TableModule = require "Template.Hall.Hall.Module.TableModule" 
HallFacade.SystemIndex = {HALL = 1 ,TABLE = 2}    
function HallFacade:GetHallPlugin()--获取到大厅插件
    return self._SystemList[self.SystemIndex.HALL]
end    

function HallFacade:GetTablePlugin()--获取到大厅插件
    return self._SystemList[self.SystemIndex.TABLE]
end  

function HallFacade:InitSystemList() 
    local hallObj = self._hallData.obj or HallModule  
    local tableObj = self._tableData.obj or TableModule  
    self._SystemList[self.SystemIndex.HALL] =  hallObj.new(self,self._hallData) 
    self._SystemList[self.SystemIndex.TABLE] = tableObj.new(self,self._tableData) 
end 
--传参需要传入 大厅数目,每个大厅的桌子数目
function HallFacade:InitServerData(id,tableData)  
    self._id = assert(id,"hall id not setting") 
    self._hallData = assert(tableData.hallData,"param name miss")
    self._tableData = assert(tableData.tableData,"param name miss")  
    self._name = assert(tableData.name,"param name miss")  
    self._SystemList = {} 
    self:InitSystemList()    
end
--大厅的ID
function HallFacade:GetHallID()  
    return self._id 
end    

function HallFacade:InitSystemData()
    for v,k in pairs(self._SystemList) do 
        k:Init()
    end 
end  

function HallFacade:InitSystem() 
    self:InitSystemData()
end    

--父类的找寻 命令函数
function HallFacade:FindCommandHandle(command)  
    local func = nil
    for v,k in pairs(self._SystemList) do  
        func = k:FindCommand(command)
        if func then 
            break
        end 
    end 
    return func
end 
--父类的找寻网络消息的函数  
function HallFacade:FindNetHandle(msgName)    
    local func = nil
    for v,k in pairs(self._SystemList) do 
        local func = k:FindCommand(msgName)
        if func then 
            break
        end 
    end 
    return func
end  
return HallFacade  