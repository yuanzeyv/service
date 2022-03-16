local skynet = require "skynet"
require "skynet.manager"
require "Tool.Class" 
local HallService = require "HallSystemModule.HallSystemService.HallService"
local PlayerService = require "HallSystemModule.HallSystemService.PlayerService" 
local SystemService = require "HallSystemModule.HallSystemService.SystemService" 
local HallSystemModule = class("HallSystemModule")  
HallSystemModule.SystemIndex = {HALL = 1 ,PLAYER = 2 ,SYSTEM = 3}   
function HallSystemModule:ctor(...)
    self:InitServerData(...)
    self:InitServer()
end

function HallSystemModule:PlayerEnterHall(playHandle,hallIndex) 
    self._SystemList[self.SystemIndex.PLAYER]:EnterHall(playHandle,hallIndex)
end
function HallSystemModule:PlayerLeaveHall(playHandle) 
    self._SystemList[self.SystemIndex.PLAYER]:LeaveHall(playHandle)
end 
--获取到一个玩家是否进入了大厅
function HallSystemModule:GetPlayerHallHandle(playHandle)
    return self._SystemList[self.SystemIndex.PLAYER]:GetPlayerHallHandle(playHandle)
end
--获取到一个玩家是否进入了大厅
function HallSystemModule:GetPlayer(playHandle)
    return self._SystemList[self.SystemIndex.PLAYER]:GetPlayer(playHandle)
end

function HallSystemModule:InitSystemList()
    local hallObj = self._hallData.obj or HallService
    local playerObj = self._playerData.obj or PlayerService  
    self._SystemList[self.SystemIndex.HALL] =  hallObj.new(self,self._hallData)
    self._SystemList[self.SystemIndex.PLAYER] =playerObj.new(self,self._playerData)  
    self._SystemList[self.SystemIndex.SYSTEM] = SystemService.new(self)
end 
function HallSystemModule:GetSystemID()
    return self._systemID  
end 
--传参需要传入 大厅数目,每个大厅的桌子数目
function HallSystemModule:InitServerData(systemID,tableData)      
    self._systemID = assert(systemID,"system is null ")
    self._hallData = assert(tableData.hallData,"param name miss")
    self._tableData = assert(tableData.tableData,"param name miss")
    self._playerData = assert(tableData.playerData,"param name miss") 
    self._name = assert(tableData.name,"param name miss")  
    self._SystemList =  {}  
    self:InitSystemList()   
end

function HallSystemModule:InitSystem()
    skynet.register(self._name)
    for v,k in pairs(self._SystemList) do 
        k:Init()
    end 
end   
function HallSystemModule:GetHallInfo()
    return self._SystemList[self.SystemIndex.HALL]._hallArray
end 

function HallSystemModule:InitServer() 
	skynet.start(function () 
        --skynet.register(self._name) 
        self:InitSystem() --初始化每个系统
        self:InitEventDispatch() 
	end)
end
function HallSystemModule:TransformToHall(playHandle,msgName,param1,param2,param3,param4,str) 
    assert(self._manager:GetPlayer(playHandle),"player not enter system")
    local hallHandle = assert(self._manager:GetPlayerHallHandle(playHandle),"player not enter hall")--玩家未加入系统 或者没有加入大厅    
    skynet.send(hallHandle,"client",msgName,playHandle,msgName,param1,param2,param3,param4,str)
end

function HallSystemModule:InitEventDispatch()  
    skynet.dispatch("lua", function(session, source,command ,...)
        local func = nil 
        for v,k in pairs(self._SystemList) do  
            func = k:FindCommand(command)
            if func then  
                break
            end 
        end     
        local ret,len
        if func then   
            ret,len = skynet.pack(func(source,...))
        else
            ret,len = skynet.pack(nil)
        end  
        skynet.ret(ret,len)
    end)
    skynet.register_protocol{
        name = "client",
        id = skynet.PTYPE_CLIENT,
        pack = skynet.pack,
        unpack = skynet.unpack,
        dispatch = function(_,source,msgName,param1,param2,param3,param4,str)   
            local handle = handler(self,self.TransformToHall) 
            for v,k in pairs(self._SystemList) do 
                local func = k:FindService(msgName)
                if  k:FindService(msgName) then 
                    handle = func  
                    break 
                end  
            end    
            skynet.ret(handle(source,msgName,param1,param2,param3,param4,str)) --转发到大厅
        end
    }
end
return HallSystemModule  