local ServiceModule = require "ServiceModle.ServiceModule"    
local BaseModule = class("BaseModule",ServiceModule)  
function BaseModule:GetSystemID()
    return self._manager:GetSystemID()
end  
return BaseModule