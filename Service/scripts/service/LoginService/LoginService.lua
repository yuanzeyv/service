require "Tool.Class"
local LoginMaster = require "LoginService.LoginMasterServer"
local LoginSalve = require "LoginService.LoginSalveServer"
local skynet = require "skynet"   
local crypt = require "skynet.crypt"
local LoginServerData = class("LoginServerData")
function LoginServerData:ctor(port,name)    
    self:InitServerData(port,name)
end

function LoginServerData:InitServerData(port,name) 
    self._port =  assert(port,"param port error") 
    self._serverName =  assert(name,"param name error")
    self._serverList = {}
    self._command = self:CommandList();
    self._server = self:ServiceList();
end

function LoginServerData:Command_register_gate(server, address) 
    self._serverList[server] = address
end

function LoginServerData:CommandList()
    local CMD = {}  
    CMD.register_gate = handler(self,self.Command_register_gate)
    return CMD;
end

function LoginServerData:ServerHandle_auth(token)
    -- the token is base64(user)@base64(server):base64(password) 
    local user, server, password = token:match("([^@]+)@([^:]+):(.+)") 
    user = crypt.base64decode(user)
    server = crypt.base64decode(server)
    password = crypt.base64decode(password) 
    skynet.error(string.format("%s@%s:%s", user, server, password))   
    assert(password == "password", "Invalid password")
    return server, user
end

--登录回调要返回一个 subid 
function LoginServerData:ServerHandle_login(server, uid, secret)
    local msgserver = assert(self._serverList[server],"unknow server")
    printf("%s@%s is login  %s", uid, server,secret)
    local subid = skynet.call(msgserver,"lua","login",uid,secret)
    return subid
end

function LoginServerData:ServerHandle_command (command, ...) 
    local f = assert(self._command[command])
    return f(...)
end
function LoginServerData:ServiceList(port,name)
    local server = { 
        port = self._port,
        multilogin = true, --disallow multilogin
        name = self._serverName,
    } 
    server.auth_handler = handler(self,self.ServerHandle_auth) 
    server.login_handler = handler(self,self.ServerHandle_login) 
    server.command_handler = handler(self,self.ServerHandle_command)
    return server 
end

local loginServerData = LoginServerData.new(...) 
local loginServiceChoose = (skynet.localname(loginServerData._serverName) and LoginSalve) or  LoginMaster 
local loginService = loginServiceChoose.new(loginServerData._server) 