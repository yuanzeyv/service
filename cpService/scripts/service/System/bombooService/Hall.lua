require "Tool.Class"
local skynet = require "skynet"     
local baseHall = require "Template.Hall.Hall.HallFacade"
local Hall = class("Hall",baseHall)     
local systemID,hallID = ...
local Hall = Hall.new(systemID,hallID,{ 
    tableData = { 
        tableCount = 80,
        maxPlayerCount = 20,--一个房间最多可以坐多少人
        maxSitDownPlayer = 6,--一个房间最多可以游戏多少人
        startGameNeedPlayer = 3,--一个房间最少多少人才可以开始游戏
    },  
    name = "AAABBB"
})