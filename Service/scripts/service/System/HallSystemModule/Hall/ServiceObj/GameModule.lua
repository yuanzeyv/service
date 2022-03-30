local BaseModule = require "BaseService.BaseModule" 
local GameModule = class("GameModule",BaseModule)     
function GameModule:InitModuleData(tableData)
    self._tableData = tableData --获取到自己的数据
end   

function GameModule:RegisterCommand(commandTable)
end 

function GameModule:Server_Abandon(systemHandle,msgName,sendObj,userHandle,param1,param2,param3,param4,str)  
    --找到对应的桌子
    --判断桌子的主人是否与用户相匹配
    --如果相匹配，那么就通过参数设置当前的桌子的信息
    skynet.send(userHandle,"lua","write",NetCommandConfig:FindCommand(self.systemID,"Net_LeaveHall_ret"),0) 
end
function GameModule:Server_Trustee(systemHandle,msgName,sendObj,userHandle,param1,param2,param3,param4,str)  
    --找到对应的桌子
    --判断桌子的主人是否与用户相匹配
    --如果相匹配，那么就通过参数设置当前的桌子的信息
    skynet.send(userHandle,"lua","write",NetCommandConfig:FindCommand(self.systemID,"Net_LeaveHall_ret"),0) 
end
function GameModule:Server_WinWin(systemHandle,msgName,sendObj,userHandle,param1,param2,param3,param4,str)  
    --找到对应的桌子
    --判断桌子的主人是否与用户相匹配
    --如果相匹配，那么就通过参数设置当前的桌子的信息
    skynet.send(userHandle,"lua","write",NetCommandConfig:FindCommand(self.systemID,"Net_LeaveHall_ret"),0) 
end 
function GameModule:RegisterNetCommand(serverTable)
    serverTable.Net_Abandon = handler(self,GameModule.Server_Abandon)    --托管
    serverTable.Net_Trustee = handler(self,GameModule.Server_Trustee)--认输
    serverTable.Net_WinWin = handler(self,GameModule.Server_WinWin) --求和 
end  
function  GameModule:Init()  
end
return GameModule