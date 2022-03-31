
--角色进入未准备模式
--return 0  函数执行正常
--return -1 玩家没有有加入到桌子
--return -2 玩家进入 LOOK 状态
--return -3 玩家进入 UNREADY 状态
--return -4 玩家进入 READY 状态
--return -5 玩家进入 PLAYING 状态
--return -6 当前坐下人数满员，无法坐下 
--return -7 当前桌子不存在
--return -8 当前玩家不是房主 没有权限进行操作
require "Tool.Class"
local Map = require "Tool.Map"
local skynet = require "skynet"   
local Table = require"HallSystemModule.Hall.StructManager.TableManager.Table" --大厅里面有桌子 
local TableManager = class("TableManager") 
function TableManager:ctor(tableInfo)   
    self:InitData(tableInfo) 
end     
function TableManager:CreateTables(tableInfo) 
    local table = {}
    for id = 1 , tableInfo.tableCount  do  
        table[id] = Table.new(tableInfo)
    end 
    return table 
end 
function TableManager:InitData(tableInfo) 
    self.tableCount = assert(tableInfo.tableCount,"param miss")
    self._tableMap = TableManager:CreateTables(tableInfo)
end      
--玩家加入一张桌子
function TableManager:EnterTable(tableID,playerHandle)  
    local tableInfo = self._tableMap[tableID]
    if not tableInfo then return -7 end --首先判断当前的桌子是否存在
    return tableInfo:PlayerEnter(playerHandle) 
end     
--玩家离开一张桌子
function TableManager:LeaveTable(tableID,playerHandle) 
    local tableInfo = self._tableMap[tableID]
    if not tableInfo then return -7 end --首先判断当前的桌子是否存在
    return tableInfo:PlayerLeave(playerHandle) 
end     
--玩家开始一场游戏
function TableManager:StartGame(tableID,playerHandle) 
    local tableInfo = self._tableMap[tableID]
    if not tableInfo then return -7 end --首先判断当前的桌子是否存在

end     
--玩家进入观战模式
function TableManager:EnterLookModule(tableID,playerHandle) 
    local tableInfo = self._tableMap[tableID]
    if not tableInfo then return -7 end --首先判断当前的桌子是否存在
    return tableInfo:PlayerEnterLookModule(playerHandle) 
end     
--玩家进入未准备模式
function TableManager:EnterUnReadyModule(tableID,playerHandle) 
    local tableInfo = self._tableMap[tableID]
    if not tableInfo then return -7 end --首先判断当前的桌子是否存在
    return tableInfo:PlayerEnterUnReadyModule(playerHandle) 
end     
--玩家进入准备模式 
function TableManager:EnterReadyModule(tableID,playerHandle) 
    local tableInfo = self._tableMap[tableID]
    if not tableInfo then return -7 end --首先判断当前的桌子是否存在
    return tableInfo:PlayerEnterReadyModule(playerHandle) 
end  
--玩家尝试加入游戏 
function TableManager:EnterPlayModule(tableInfo,playerHandle) 
    local tableInfo = self._tableMap[tableID]
    if not tableInfo then return -7 end --首先判断当前的桌子是否存在
    return tableInfo:PlayerEnterPlayModule(playerHandle) 
end    
return TableManager