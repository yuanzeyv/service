local skynet = require "skynet"
require "Tool.Class"
local HallSystemModule = require "HallSystemModule.HallSystemFacade"
local BombooService = class("BombooService",HallSystemModule)

local SystemConfig = {
    name = "BombooService",--系统服务的名称
    hallData = {hallPath = "bombooService/Hall",},
    tableData= {},
    playerData = {},
    gameData  = {}
 } 
local SystemID = ...
local BombooService = BombooService.new(tonumber(SystemID),SystemConfig)