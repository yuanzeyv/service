local HallSystemModule = require "Template.Hall.System.HallSystemService"
local BombooService = class("BombooService",HallSystemModule) --继承自大厅服务 
local HallModule = require "Template.Hall.System.Module.HallModule"    --传入大厅模块模板,以方便客制修改 
local SystemConfig = { 
    systemName = "接竹竿系统",--系统服务的名称  
    hallData = {hallPath = "bombooService/Hall",obj = HallModule,hallCount = 5 }, 
    systemData = {}, 
}   
local SystemID = ...  
local BombooService = BombooService.new(tonumber(SystemID),SystemConfig)