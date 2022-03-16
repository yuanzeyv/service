require "Tool.Class"
local Map = require "Tool.Map"
local skynet = require "skynet"   
local Table = require"HallSystemModule.Hall.StructManager.Table" --大厅里面有桌子 
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
    self._tableArray = TableManager:CreateTables(tableInfo)
end     
  
function TableManager:PlayerReady(tableData,player)
    return tableData:PlayerReady(player)  
end  

function TableManager:PlayerCancelReady(tableData,player)
    tableData:PlayerCancelReady(player)
end 

function TableManager:PlayerStandUp(tableData,player) 
    tableData:PlayerStandUp(player)
end  
function TableManager:PlayerSitDown(tableData,player) 
    tableData:PlayerSitDown(player)
end   

function TableManager:PlayerEnterTable(tableData,player,isLook)
    tableData:PlayerEnter(player,isLook)--将角色加入到桌子   
end

function TableManager:PlayerLeaveTable(tableData,player) 
    tableData:PlayerLeave(player ) --将角色从桌子中删除
end   
function TableManager:CheckStartGame(tableData) 
    if not tableData:CanStartGame() then
        return 
    end 
    local game = skynet.newservice("bombooService/Game/BombooGameService")
    tableData:SetTableGameHandle(game)
end 
return TableManager