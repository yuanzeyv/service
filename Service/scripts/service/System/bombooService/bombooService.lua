local skynet = require "skynet"
require "Tool.Class"
local HallSystemModule = require "HallSystemModule.HallSystemFacade"
--大厅的数据对象
local HallService = require "HallSystemModule.HallSystemService.HallService"
local SystemService = require "HallSystemModule.HallSystemService.SystemService" 
local BombooService = class("BombooService",HallSystemModule) 
local SystemConfig = {
    serviceName = "BombooService",--系统服务的名称  
    systemName = "接竹竿",--系统服务的名称  
    hallData = {hallPath = "bombooService/Hall",obj = HallService}, 
    systemData = {obj = SystemService}, 
}  
local SystemID = ... 
local BombooService = BombooService.new(tonumber(SystemID),SystemConfig)
