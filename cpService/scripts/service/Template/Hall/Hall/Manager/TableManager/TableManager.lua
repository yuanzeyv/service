local TableManager = class("TableManager") 
local Table = require"Template.Hall.Hall.Manager.TableManager.Table" --大厅里面有桌子 
local Map = require "Tool.Map" 
function TableManager:ctor(tableInfo,module)   
    self:InitData(tableInfo,module) 
end     

function TableManager:InitData(tableInfo,module) 
    self.tableCount = assert(tableInfo.tableCount,"param miss")  
    self._playerMap = Map.new()--用于保存桌子下的玩家进入状态
    self._tableMap = self:CreateTables(tableInfo,module) 
end   

function TableManager:CreateTables(tableInfo,module) 
    local table = {}
    for id = 1 , tableInfo.tableCount  do  
        table[id] = Table.new(tableInfo,module,id)
    end 
    return table 
end 

function TableManager:GetTable(tableID)--获取到一张桌子
    return self._tableMap[tableID]
end 

function TableManager:GetTableByPlayer(playerHandle)
    return self._playerMap:Find(playerHandle)
end     

function TableManager:EnterTable(tableID,playerHandle)--玩家加入一张桌子 
    local tableInfo =  self:GetTableByPlayer(playerHandle)
    if tableInfo then--玩家已经加入了一张桌子
        return ErrorType.PlayerEnterTableEarlie
    end
    local tableInfo = self:GetTable(tableID) 
    if not tableInfo then--当前要加入的桌子不存在
        return ErrorType.TableNotExist
    end
    local enterRet = tableInfo:EnterTable(playerHandle) 
    if enterRet ~= ErrorType.ExecuteSuccess then 
        return enterRet
    end 
    self._playerMap:Add(playerHandle,tableInfo)
    return ErrorType.ExecuteSuccess
end     

--玩家离开一张桌子
function TableManager:LeaveTable(playerHandle)  
    local tableInfo =  self:GetTableByPlayer(playerHandle)
    if not tableInfo then--玩家已经加入了一张桌子
        return ErrorType.PlayerNotEnterTable
    end 
    local enterRet = tableInfo:LeaveTable(playerHandle) 
    if enterRet ~= ErrorType.ExecuteSuccess then 
        return enterRet
    end 
    self._playerMap:Delete(playerHandle)
    return ErrorType.ExecuteSuccess
end 
 
--玩家开始一场游戏
function TableManager:StartGame(playerHandle) 
    local tableInfo =  self:GetTableByPlayer(playerHandle)
    if not tableInfo then--玩家没有加入桌子
        return ErrorType.PlayerNotEnterTable
    end    
    return tableInfo:StartGame(playerHandle)
end  
function TableManager:EnterGame(playerHandle) 
    local tableInfo =  self:GetTableByPlayer(playerHandle)
    if not tableInfo then--玩家没有加入桌子
        return ErrorType.PlayerNotEnterTable
    end    
    return tableInfo:EnterGame(playerHandle)
end  
function TableManager:LeaveGame(playerHandle) 
    local tableInfo =  self:GetTableByPlayer(playerHandle)
    if not tableInfo then--玩家没有加入桌子
        return ErrorType.PlayerNotEnterTable
    end    
    return tableInfo:LeaveGame(playerHandle)
end     
--玩家进入观战模式
function TableManager:EnterLookModule(playerHandle) 
    local tableInfo =  self:GetTableByPlayer(playerHandle)
    if not tableInfo then--玩家没有加入桌子
        return ErrorType.PlayerNotEnterTable
    end    
    return tableInfo:EnterLookModule(playerHandle)
end     

--玩家进入未准备模式
function TableManager:EnterUnReadyModule(playerHandle) 
    local tableInfo =  self:GetTableByPlayer(playerHandle)
    if not tableInfo then--玩家没有加入桌子
        return ErrorType.PlayerNotEnterTable
    end    
    return tableInfo:EnterUnReadyModule(playerHandle)
end     

--玩家进入准备模式 
function TableManager:EnterReadyModule(playerHandle) 
    local tableInfo =  self:GetTableByPlayer(playerHandle)
    if not tableInfo then--玩家没有加入桌子
        return ErrorType.PlayerNotEnterTable
    end    
    return tableInfo:EnterReadyModule(playerHandle)
end  
--玩家尝试加入游戏 
function TableManager:EnterPlayModule(playerHandle) 
    local tableInfo =  self:GetTableByPlayer(playerHandle)
    if not tableInfo then--玩家没有加入桌子
        return ErrorType.PlayerNotEnterTable
    end    
    return tableInfo:EnterPlayModule(playerHandle)
end    

--获取到所有桌子的信息
function TableManager:GetTableListInfo()
    local ret = {} 
    for v, k in pairs(self._tableMap) do    
        ret[v] = k:GetTableBriefInfo() 
    end  
    return ret
end  
--获取到桌子下所有玩家的信息
function TableManager:GetTablePlayerList(playerHandle)
    local tableInfo =  self:GetTableByPlayer(playerHandle)
    if not tableInfo then--玩家没有加入桌子
        return ErrorType.PlayerNotEnterTable,nil
    end    
    return ErrorType.ExecuteSuccess,tableInfo:GetTablePlayerList()
end
return TableManager
