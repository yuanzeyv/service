local HallSystemModule = require "Template.Hall.System.HallSystemService"
--大厅的数据对象
local HallModule = require "Template.Hall.System.Module.HallModule"
local SystemModule = require "Template.Hall.System.Module.SystemModule"
local BombooService = class("BombooService",HallSystemModule) 
local SystemConfig = {
    serviceName = "BombooService",--系统服务的名称  
    systemName = "接竹竿",--系统服务的名称  
    hallData = {hallPath = "bombooService/Hall",obj = HallModule}, 
    systemData = {obj = SystemModule}, 
}  
local SystemID = ... 
local BombooService = BombooService.new(tonumber(SystemID),SystemConfig)

