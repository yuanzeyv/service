local BaseService = require "BaseService.BaseService"   
local HallModule = require "HallSystemModule.Hall.ServiceObj.HallModule"
local PlayerModule = require "HallSystemModule.Hall.ServiceObj.PlayerModule"
local TableModule = require "HallSystemModule.Hall.ServiceObj.TableModule"

local HallFacade = class("HallFacade",BaseService)
HallFacade.SystemIndex = {HALL = 1 ,PLAYER = 2 ,TABLE = 4}   
--获取到大厅插件
function HallFacade:GetHallPlugin()
    return self._SystemList[self.SystemIndex.HALL]
end 
--获取到系统插件
function HallFacade:GetGamePlugin()
    return self._SystemList[self.SystemIndex.SYSTEM]
end

--获取到大厅插件
function HallFacade:GetTablePlugin()
    return self._SystemList[self.SystemIndex.TABLE]
end 
--获取到系统插件
function HallFacade:GetPlayerPlugin()
    return self._SystemList[self.SystemIndex.PLAYER] 
end

function HallFacade:InitSystemList()
    local hallObj = self._hallData.obj or HallModule
    local playerObj = self._playerData.obj or PlayerModule
    local gameObj = self._gameData.obj or GameModule
    local tableObj = self._tableData.obj or TableModule  
    self._SystemList[self.SystemIndex.HALL] =  hallObj.new(self,self._hallData)
    self._SystemList[self.SystemIndex.PLAYER] =playerObj.new(self,self._playerData) 
    self._SystemList[self.SystemIndex.TABLE] = tableObj.new(self,self._tableData)
end 
--传参需要传入 大厅数目,每个大厅的桌子数目
function HallFacade:InitServerData(id,tableData)  
    self._id = assert(id,"id not setting") 
    self._hallData = assert(tableData.hallData,"param name miss")
    self._tableData = assert(tableData.tableData,"param name miss")
    self._playerData = assert(tableData.playerData,"param name miss")
    self._gameData = assert(tableData.gameData,"param name miss")
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