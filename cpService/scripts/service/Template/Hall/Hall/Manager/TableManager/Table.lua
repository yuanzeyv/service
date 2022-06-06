local Table = class("Table")  
local Map = require "Tool.Map" 
local PlayerClass =  require("Template.Hall.Hall.Manager.TableManager.Player")  
local TableStartMachine = require "Template.Hall.Hall.Manager.TableManager.Machine.TableStartMachine" 
local TableUnStartMachine = require "Template.Hall.Hall.Manager.TableManager.Machine.TableUnStartMachine" 
Table.TABLE_STATUS = {UNSTART = 1, START = 2}  
Table.PLAYER_STATUS = PlayerClass.PLAYER_STATUS
function Table:ctor(tableInfo,sysModule,id)    
    self._tableId =  assert(id,"param miss") 
    self._maxPlayerCount = assert(tableInfo.maxPlayerCount,"param miss")--获取到一个桌子最大容纳玩家的数量
    self._maxSitDownPlayer = assert(tableInfo.maxSitDownPlayer,"param miss")--获取到一个桌子最大坐下的数量
    self._startGameNeedPlayer = assert(tableInfo.startGameNeedPlayer,"param miss") --获取到开始玩家需要的数量 
    self._systemModule = assert(sysModule,"param miss") --获取到开始玩家需要的数量 
    --房间能坐下的所有人员 
    self._StatusArray = {}
    self._StatusArray[PlayerClass.PLAYER_STATUS.LOOK]         = Map.new() --观看模式 
    self._StatusArray[PlayerClass.PLAYER_STATUS.UNREADY]      = Map.new() --未准备模式
    self._StatusArray[PlayerClass.PLAYER_STATUS.READY]        = Map.new() --准备模式
    self._StatusArray[PlayerClass.PLAYER_STATUS.PLAYING]      = Map.new() --游戏模式
    self._StatusArray[PlayerClass.PLAYER_STATUS.LOOK_PLAYING] = Map.new() --场外观战模式
    self._allPlayerArray = Map.new()    

    self._TableStateMachines = {}  
    self._TableStateMachines[self.TABLE_STATUS.UNSTART] = TableUnStartMachine.new(self,self.TABLE_STATUS.UNSTART ) 
    self._TableStateMachines[self.TABLE_STATUS.START]   = TableStartMachine.new(self,self.TABLE_STATUS.START ) 
    
    self._homeMaster = nil--当前的房主
    self._tableGameHandle = nil --桌子关联的游戏句柄
    self._tableMachines = self._TableStateMachines[self.TABLE_STATUS.UNSTART] --当前桌子所属的状态
end
--获取到一个桌子的简略信息
function Table:GetTableBriefInfo()
    local ret = {}  
    ret[1] = self._maxPlayerCount 
    ret[2] = self._maxSitDownPlayer
    ret[3] = self._startGameNeedPlayer 
    ret[4] = self._allPlayerArray:Count()
    ret[5] = self._tableId
    return ret 
end     

function Table:CreatePlayer(userHandle)
    return PlayerClass.new(userHandle) 
end 

function Table:AddPlayer(userHandle,player)
    self._allPlayerArray:Add(userHandle,player)
    local status = player:GetStatus() --获取到玩家的状态
    self._StatusArray[status]:Add(userHandle,player)
end 

function Table:DeletePlayer(userHandle)
    local player = self._allPlayerArray:Find(userHandle)
    local status = player:GetStatus() --获取到玩家的状态
    self._StatusArray[status]:Delete(userHandle)
    self._allPlayerArray:Delete(userHandle) 
end  
 
function Table:FindPlayer(userHandle)
    return self._allPlayerArray:Find(userHandle)
end 

--向所有角色推送消息
function Table:BroadcastNetMsg(cmd,msg,excludeSelf)  
   local sendObj = BaseMessageObj.new(self._systemModule,userHandle,msgName)  
   sendObj:SetCMD(cmd)
   sendObj:SetJson(msg)
   for v,k in pairs(self._allPlayerArray:GetTable() ) do 
        if v ~= excludeSelf then 
            sendObj:SetUser(v)
            sendObj:Send()
        end 
   end 
end 

--获取到一个列表的所有成员
function Table:GetAllPlayerHandle(status) 
    local ret = {} 
    for v,k in pairs(self._StatusArray[status]:GetTable()) do 
        table.insert(ret,v)
    end  
    return ret
end  
function Table:BroadcastPlayerStatus(handleList,excludeSelf)
    local sendTable = {} 
    for v,k in pairs(handleList) do 
        local cell = {} 
        cell.id = k
        cell.status = self:FindPlayer(k) and self:FindPlayer(k):GetStatus() or nil --空的话，为删除
        sendTable[v] = cell
    end 
    self:BroadcastNetMsg("Net_PlayerHallStatusChange",sendTable,excludeSelf)
end 


function Table:CanSitDown()--return true or false 
    local unReadyCount = self._StatusArray[PlayerClass.PLAYER_STATUS.UNREADY]:Count()
    local readyCount = self._StatusArray[PlayerClass.PLAYER_STATUS.READY]:Count() 
    return (unReadyCount + readyCount) < self._maxSitDownPlayer
end 
function Table:CanStartGame()--return true or false 
    local unReadyCount = self._StatusArray[PlayerClass.PLAYER_STATUS.UNREADY]:Count()
    local readyCount = self._StatusArray[PlayerClass.PLAYER_STATUS.READY]:Count() 
    return (unReadyCount + readyCount) >= self._maxSitDownPlayer
end  
 
function Table:CanEnterTable()--判断是否可以加入到观战队列
    return self._allPlayerArray:Count() < self._maxPlayerCount 
end 
 
function Table:GetStateMachine(state)--获取到指定的状态机
    return self._TableStateMachines[state]
end  

function Table:SetTableStateMachine(state)--设置当前的状态机
    self._tableMachines  = self:GetTableStateMachine(state) 
end  
function Table:GetTablePlayerList()--获取到桌子下的所有玩家信息
    local userTable = self._allPlayerArray:GetTable()
    local ret = {} 
    for v,k in pairs(userTable) do 
        table.insert(ret,k:GetInfo())
    end  
    return ret 
end    
--桌子的游戏句柄
function Table:GetGameHandle()
    return self._tableGameHandle
end   

--获取房间的主人
function Table:GetTableMaster()
    return self._homeSteward
end    
function Table:SetTableMaster(player)
    self._homeSteward = player
end     
 
--玩家进入桌子的话
function Table:EnterTable(playerHandle)
    return self._tableMachines:EnterTable(playerHandle)
end 
--角色将退出桌子
function Table:LeaveTable(playerHandle)
    return self._tableMachines:LeaveTable(playerHandle) 
end

--角色进入观战模式
function Table:EnterLookModule(playerHandle)
    return self._tableMachines:EnterLookModule(playerHandle)  
end
--角色进入未准备模式
function Table:EnterUnReadyModule(playerHandle)
    return self._tableMachines:EnterUnReadyModule(playerHandle)  
end
--角色进入准备模式
function Table:EnterReadyModule(playerHandle) 
    return self._tableMachines:EnterReadyModule(playerHandle)  
end
--玩家开始游戏（仅房主可以操作）
function Table:StartGame(playerHandle)
    return self._tableMachines:StartGame(playerHandle)   
end    
--玩家加入一场游戏
function Table:EnterGame(playerHandle)
    return self._tableMachines:EnterGame(playerHandle)   
end    
--玩家离开一场游戏
function Table:LeaveGame(playerHandle)
    return self._tableMachines:LeaveGame(playerHandle)    
end    
return Table 