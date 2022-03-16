local skynet = require "skynet"  
require "Tool.Class" 
local SystemIDConfig = require("Config.SystemIDConfig").Instance()
local netCommandConfig = require("Config.NetCommandConfig").Instance()
local AgentService = class("AgentService")     

function AgentService:Command_Login(source, uid, sid,username)--登录成功，secret可以用来加解密数据 
    self:InitServerData(source, uid, sid,username)
end 

function AgentService:Command_Logout(source) 
    skynet.error(string.format("%s is logout", self._userid))
    if self._gate then
        skynet.call(self._gate, "lua", "logout", self._userid, self._subid)
    end
    skynet.exit()
end 

function AgentService:Command_Disconnect(source) --gate发现client的连接断开了，会发disconnect消息过来这里不要登出 
    skynet.error(string.format("disconnect"))
end 

function AgentService:Command_Write(source,...)    
    skynet.call(self._gate, "lua", "write",self._username,self:PackMsg(...))
end

function AgentService:Command_RegisterSystem(source,systemID,handle)  
    print("玩家登入了系统",systemID)
    self._systemControlHandle[systemID] = {handle = handle}
end 

function AgentService:Command_UnRegisterSystem(source,systemID) 
    self._systemControlHandle[systemID] = nil
end 

function AgentService:GetCMD()
    local CMD = {}
	CMD.login =  handler(self,AgentService.Command_Login)
	CMD.logout = handler(self,AgentService.Command_Logout)
	CMD.disconnect = handler(self,AgentService.Command_Disconnect)
	CMD.write = handler(self,AgentService.Command_Write)
	CMD.register_system = handler(self,AgentService.Command_RegisterSystem)
	CMD.unregister_system = handler(self,AgentService.Command_UnRegisterSystem)
	return CMD
end
 
function AgentService:PackMsg(msgId,param1,param2,param3,param4,str)
    assert(msgId,"msgId is error") 
    return string.pack("<I4 I4 I4 I4 I4 s4",msgId,param1 or 0 ,param2 or 0 ,param3 or 0 ,param4 or 0 ,str or "")
end  

function AgentService:InitEventDispatch() 
-- If you want to fork a work thread , you MUST do it in CMD.login
    skynet.dispatch("lua", function(session,source,command,...)   
        local f = assert(self._command[command])  
        skynet.ret(skynet.pack(f(source,...)))
    end)  
 
    skynet.register_protocol {
        name = "client",
        id = skynet.PTYPE_CLIENT,
        pack = skynet.pack,
        unpack = skynet.unpack,
        dispatch =function(_,source,msgId,param1,param2,param3,param4,str) 
            local FindSystem = netCommandConfig:FindByIndex(msgId)--寻找到消息ID对应的数据信息
            if not FindSystem then  
                return
            end
            local systemInfo = self._systemControlHandle[FindSystem.systemID]--通过对应的
            if not systemInfo then  
                print("消息" + msgId +"没有找到指定的系统" + FindSystem.systemID)
                return
            end  
            print(FindSystem.cmdName,param1,param2,param3,param4,str , "QQQQQQQQQ")
            skynet.send(systemInfo.handle,"client",FindSystem.cmdName,param1,param2,param3,param4,str)  
        end 
    }
end 

function AgentService:InitServerData(source, uid, sid,username) 
	assert(source and uid and sid,"参数传入有误") 
    self._gate   = source
    self._userid = uid
    self._subid  = sid  
    self._username = username
    self._systemControlHandle = {
        [SystemIDConfig:GetTable().SystemManager]= {handle = skynet.localname(".SystemManager")}
    }
end

function AgentService:ctor()  
    self._gate   = nil
    self._userid = nil
    self._subid  = nil   
    self._systemControlHandle = nil 

    self._command  = self:GetCMD()   
	self:InitServer()
end

function AgentService:InitServer()  
	skynet.start(function ()  
		self:InitEventDispatch()  
	end)
end
local AgentService = AgentService.new()