local skynet = require "skynet"
local b2 = require("libbox2d")  --对应于teste.c中的包名 
require "skynet.manager"
require "Tool.Class" 
require "Tool.Json"
local Box2dTest = class("Box2dTest")
function new(class,...)
    return class.new(...)
end  
function Box2dTest:InitServerData(id) 
    self._id = tonumber(id) 
    self._gravity = b2.b2Vec2.new(0,-9.8)
    self._world = b2.b2World.new(self._gravity)
    self._positionDelta = 10--游戏的碰撞修复
    self._velocityDelta = 20--游戏的速度修复
    self._frameStep = 33 --游戏的帧率   
end 
function Box2dTest:GetInterval()
    return math.floor( 100 / self._frameStep)
end  
-- function Box2dTest:CreateCircle()
--     local b2Def = new(b2.b2BodyDef)
--     b2Def.position:Set(0,0)
--     --创建一个圆形
--     local fixtureDef = new(b2.b2FixtureDef)
--     local cicleShape = new(b2.b2CircleShape)
--     fixtureDef.shape = cicleShape:GetShapePoint()--目前没有找到强制转换的方法，所以需要一个指针获取
--     fixtureDef.density = 20
--     cicleShape:GetShapePoint().p = 999
--     print(cicleShape.p ,cicleShape:GetShapePoint().p, "PP") 
--     local circleBody = self._world:CreateBody(b2Def) --首先需要创建一个刚体 
--     circleBody:CreateFixture_Fixture(fixtureDef)
--     return circleBody
-- end 
-- function Box2dTest:CreateSetAsBox()
--     local b2Def = new(b2.b2BodyDef)
--     b2Def.position:Set(0,0)
--     --创建一个圆形
--     local fixtureDef = new(b2.b2FixtureDef)
--     local boxShape = new(b2.b2PolygonShape)
--     local a = {
--         {0,0},
--         {0,5},
--         {5,5},
--         {5,5},
--         {5,5},
--         {5,5},
--         {5,0}, 
--     }  
--     boxShape:Set(a)  
--     fixtureDef.shape = boxShape:GetShapePoint()--目前没有找到强制转换的方法，所以需要一个指针获取
--     fixtureDef.density = 20
--     local circleBody = self._world:CreateBody(b2Def) --首先需要创建一个刚体 
--     circleBody:CreateFixture_Fixture(fixtureDef)
--     return circleBody
-- end 
-- function Box2dTest:SecondTest() 
--     local circle = self:CreateCircle()
--     local bex = self:CreateSetAsBox()
--     local bodyList = self._world:GetBodyList()  
-- end

function Box2dTest:SetGravity(x,y) 
    --self._gravity:Set(x,y)
   -- self._world:SetGravity(self._gravity)
end 

function Box2dTest:InitServer() 
   -- self:SecondTest()
	skynet.start(function ()  
       -- self:SetGravity(0,-9.8)
        --skynet.timeout(self:GetInterval(),handler(self,self.Task))
	end)  
end  

function Box2dTest:ctor(...)   
    self:InitServerData(...)
    self:InitServer()  
end  
function Box2dTest:Task()   
   -- self._world:Step(self._frameStep,self._positionDelta,self._velocityDelta) --物理迭代器
   -- skynet.timeout( self:GetInterval() ,handler(self,self.Task))
end 

local Box2dTest = Box2dTest.new(...)