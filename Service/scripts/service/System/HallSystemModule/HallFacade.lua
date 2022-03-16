local skynet = require "skynet"
require "skynet.manager"
require "Tool.Class"
local GameService = require "HallSystemModule.Hall.ServiceObj.GameService"
local HallService = require "HallSystemModule.Hall.ServiceObj.HallService"
local PlayerService = require "HallSystemModule.Hall.ServiceObj.PlayerService"
local TableService = require "HallSystemModule.Hall.ServiceObj.TableService"

local HallFacade = class("HallFacade")   
HallFacade.SystemIndex = {HALL = 1 ,PLAYER = 2 , GAME = 3,TABLE = 4}   
function HallFacade:ctor(id,...) 
    self:InitServerData(id,...)
    self:InitServer()
end     
function HallFacade:InitSystemList()
    local hallObj = self._hallData.obj or HallService
    local playerObj = self._playerData.obj or PlayerService
    local gameObj = self._gameData.obj or GameService
    local tableObj = self._tableData.obj or TableService
    self._SystemList = {} 
    self._SystemList[self.SystemIndex.HALL] =  hallObj.new(self,self._hallData)
    self._SystemList[self.SystemIndex.PLAYER] =playerObj.new(self,self._playerData)
    self._SystemList[self.SystemIndex.GAME] =  gameObj.new(self,self._gameData)
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
    self._SystemList = nil 
    self:InitSystemList()    
end
--大厅的ID
function HallFacade:GetID(userHandle)  
    return self._id 
end   

--玩家进入大厅
function HallFacade:PlayerEnterHall(userHandle)  
    local player= self._playerMan:GetPlayer(userHandle)--如果玩家已经进入了的情况下
    assert(not player ,"player early exist") --发送早就进入了
    self._SystemList[self.SystemIndex.PLAYER]._playerMan:AddPlayer(userHandle)--添加一个玩家信息 
end    
--玩家离开大厅
function HallFacade:PlayerLeaveHall(userHandle)
    local player = assert(self._playerMan:GetPlayer(userHandle),"leave hall fail") 
    assert( player:GetHallStatus() == player.HALL_ACTION_STATUS.IDLE , "Player bus")--如果当前角色是忙碌状态的haunt 
    self._SystemList[self.SystemIndex.PLAYER]._playerMan:DeletePlayer(userHandle) 
end 

function HallFacade:InitSystem()
    for v,k in pairs(self._SystemList) do 
        k:Init()
    end 
end   
function HallFacade:InitServer() 
	skynet.start(function () 
        self:InitSystem() --初始化每个系统
        self:InitEventDispatch() 
	end) 
end
 
function HallFacade:InitEventDispatch()  
    skynet.dispatch("lua", function(session, source,command ,...)    
        local ret = nil 
        for v,k in pairs(self._SystemList) do 
            local func = k:FindCommand(command)
            if func then 
                ret =  func(source, ...)
            end 
        end 
        skynet.ret(skynet.pack(ret))
    end) 
    skynet.register_protocol{
        name = "client",
        id = skynet.PTYPE_CLIENT,
        unpack = skynet.tostring,
        dispatch = function(_,source,msgName,param1,param2,param3,param4,str)   
            for v,k in pairs(self._SystemList) do 
                local func = k:FindService(msgName)
                if func then 
                    skynet.ret(skynet.pack(func(source,msgName,param1,param2,param3,param4,str)))
                    return  
                end  
            end  
        end
    }
end
return HallFacade  