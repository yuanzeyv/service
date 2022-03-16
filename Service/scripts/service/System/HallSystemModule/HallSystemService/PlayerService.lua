local skynet = require "skynet"
require "Tool.Class"  
local PlayerService = class("PlayerService")    
function PlayerService:ctor(manager, tableData)   
    self:InitData(manager, tableData)
end
function PlayerService:InitData(manager, tableData)   
    self._manager = manager  
    self._tableData = tableData  
    self._systemPlayers = {}--当前登入系统的角色信息
    self._commandList = self:GetCMD() 
    self._serviceList = self:GetServer()  
end 

function  PlayerService:Init()
end 
    
function PlayerService:Command_LoginSystem(source,playHandle)
    local systemId = self._manager:GetSystemID()
    print("GetSystemID GetSystemID" ,systemId)
    if self._systemPlayers[playHandle] then 
        return 2,systemId
    end 
    assert(not self._systemPlayers[playHandle],"player is register" )--首先判断当前角色是否存在于当前系统，如果存在，返回错误码  
    skynet.send(playHandle,"lua","register_system",self._manager:GetSystemID(),skynet.self())
    self._systemPlayers[playHandle] = {}--格式为 hallIndex = handle 
    return  1,systemId
end

function PlayerService:Command_UnRegisterAgent(source,playHandle) 
    assert(not self._systemPlayers[playHandle],"player is register" )--首先判断当前角色是否存在于当前系统，如果存在，返回错误码
    skynet.send(playHandle,"lua","unregister_system",self.sysID,skynet.self())
    self._systemPlayers[playHandle] = nil

end

function PlayerService:GetCMD()
    local CMD = {}  
	CMD.login_system = handler(self,PlayerService.Command_LoginSystem)
	CMD.unregister_agent = handler(self,PlayerService.Command_UnRegisterAgent)
    return CMD
end 

function PlayerService:EnterHall(playHandle,hallIndex) 
    self._systemPlayers[playHandle].hallIndex = hallIndex
end
function PlayerService:LeaveHall(playHandle) 
    self._systemPlayers[playHandle] = playHandle
end

--获取到一个玩家是否进入了大厅
function PlayerService:GetPlayerHallHandle(playHandle)
    if not self._systemPlayers[playHandle] then
        return nil
    end
    return self._systemPlayers[playHandle].hallIndex
end
--获取到一个玩家是否进入了大厅
function PlayerService:GetPlayer(playHandle)
    return self._systemPlayers[playHandle] 
end

function PlayerService:FindCommand(cmd)
    return self._commandList[cmd]
end 
function PlayerService:FindService(cmd)
    return self._serviceList[cmd]
end 
function PlayerService:GetServer()
    local server = {}  
    return server
end 


return PlayerService