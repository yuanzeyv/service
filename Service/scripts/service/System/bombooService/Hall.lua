require "Tool.Class"
local skynet = require "skynet"     
local baseHall = require "Template.Hall.Hall.HallFacade"
local Hall = class("Hall",baseHall)     
function Hall:InitServiceData(tableInfo)  
    self.super:InitServiceData(tableInfo)  
end 

function Hall:CommandList()
    local CMD = {}  
    return CMD;
end 
local systemID,hallID = ...
local Hall = Hall.new(systemID,hallID,{
    hallData = {} ,  
    tableData = {
        --table = {maxPlayerCount = 999,maxSitDownPlayer = 200,startGameNeedPlayer = 3,tableCount = 27}
        tableCount = 80,
        maxPlayerCount = 20,--一个房间最多可以坐多少人
        maxSitDownPlayer = 6,--一个房间最多可以游戏多少人
        startGameNeedPlayer = 3,--一个房间最少多少人才可以开始游戏
    },
    playerData = {
        maxCapacity = 1000,--最多存1000个人员
    },
    gameData = {} ,
    name = "AAABBB"
})