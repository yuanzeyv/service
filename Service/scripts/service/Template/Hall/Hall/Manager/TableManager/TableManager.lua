local Map = require "Tool.Map"
local Table = require"Template.Hall.Hall.Manager.TableManager.Table" --大厅里面有桌子 
local TableManager = class("TableManager") 
function TableManager:ctor(tableInfo,module)   
    self:InitData(tableInfo,module) 
end     
function TableManager:InitData(tableInfo,module) 
    self.tableCount = assert(tableInfo.tableCount,"param miss") 
    self._tableMap = self:CreateTables(tableInfo,module)  
end      
function TableManager:CreateTables(tableInfo,module) 
    local table = {}
    for id = 1 , tableInfo.tableCount  do  
        table[id] = Table.new(tableInfo,module)
    end 
    return table 
end 
--判断一张桌子是否存在
function TableManager:GetTable(tableID)
    return self._tableMap[tableID]
end 
--玩家加入一张桌子
function TableManager:EnterTable(tableID,playerHandle)  
    local tableInfo = self._tableMap[tableID]
    if not tableInfo then return G_ErrorConf.TableNotExist end --首先判断当前的桌子是否存在
    return tableInfo:PlayerEnter(playerHandle) 
end     
--玩家离开一张桌子
function TableManager:LeaveTable(tableID,playerHandle) 
    local tableInfo = self._tableMap[tableID]
    if not tableInfo then return G_ErrorConf.TableNotExist end --首先判断当前的桌子是否存在
    return tableInfo:PlayerLeave(playerHandle) 
end     
--玩家开始一场游戏
function TableManager:StartGame(tableID,playerHandle) 
    local tableInfo = self._tableMap[tableID]
    if not tableInfo then return G_ErrorConf.TableNotExist end --首先判断当前的桌子是否存在

end     
--玩家进入观战模式
function TableManager:EnterLookModule(tableID,playerHandle) 
    local tableInfo = self._tableMap[tableID]
    if not tableInfo then return G_ErrorConf.TableNotExist end --首先判断当前的桌子是否存在
    return tableInfo:PlayerEnterLookModule(playerHandle) 
end     
--玩家进入未准备模式
function TableManager:EnterUnReadyModule(tableID,playerHandle) 
    local tableInfo = self._tableMap[tableID]
    if not tableInfo then return G_ErrorConf.TableNotExist end --首先判断当前的桌子是否存在
    return tableInfo:PlayerEnterUnReadyModule(playerHandle) 
end     
--玩家进入准备模式 
function TableManager:EnterReadyModule(tableID,playerHandle) 
    local tableInfo = self._tableMap[tableID]
    if not tableInfo then return G_ErrorConf.TableNotExist end --首先判断当前的桌子是否存在
    return tableInfo:PlayerEnterReadyModule(playerHandle) 
end  
--玩家尝试加入游戏 
function TableManager:EnterPlayModule(tableID,playerHandle) 
    local tableInfo = self._tableMap[tableID]
    if not tableInfo then return G_ErrorConf.TableNotExist end --首先判断当前的桌子是否存在
    return tableInfo:PlayerEnterPlayModule(playerHandle) 
end   
--检查房主信息
function TableManager:CheckMaster(tableID) 
    local tableInfo = self._tableMap[tableID]
    if not tableInfo then return G_ErrorConf.TableNotExist end --首先判断当前的桌子是否存在
    tableInfo:ResetTableMaster(self._module)
end      
return TableManager