local ServiceModule = require "Template.ServiceModle.ServiceModule"
local BaseModule = class("BaseModule",ServiceModule)  
function BaseModule:GetSystemID()
    return self._manager:GetSystemID()
end  

function BaseModule:GetManager()
    return self._manager  
end    
return BaseModule 