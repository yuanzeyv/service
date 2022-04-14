if G_ErrorConf then 
    return 
end--防止重复包含   
--require("Config.SystemIDConfig") 
G_ErrorConf = {}
function G_ErrorConf:ctor() 
    self._errorTable = {}
    self:InitTable(self._errorTable)
    setmetatable(self,{__index = self._errorTable })
end    

function G_ErrorConf:InitTable(table)   
    --0-500是通用错误
    table.ExecuteSuccess              =  0 --运行正常
    table.ExecuteFailed               = -1 --角色没有登录当前系统
    table.UnknowError                 = -2 --状态出错，请尽快查明原因
    table.SystemNotExist              = -3 --没有找到对应的系统信息
    table.RepetSystem                 = -4 --角色已经登录了当前系统
    table.NotLoginSystem              = -5 --角色没有登录当前系统
    table.DataChaos                   = -6 --数据出现错误
    table.DataOpertionFaile           = -7--数据库操作失误
    table.NotFindDataInfo             = -8--未找到对于数据库的信息
    table.StatusERROR                 = -9--无法预知的错误
    table.SocketDisConnect            = -10--网络异常
    table.ConnectServerIndexError     = -11--登录索引错误
    table.UserNotLoggedIn             = -12--用户没有登录

    --数据库 50 - 100 
    table.DataBase_NotSelect         = -50 --未查询数据

    --登录的段,100 - 120
    table.AccountEmpty                = -100 --传入账号为空
    table.PasswordEmpty               = -101 --传入密码为空
    table.AccountLoginFail            = -102 --用户验证失败
    table.AccountNotExist             = -103 --用户不存在（账号）
    table.PasswordError               = -104 --用户密码错误
    table.ServerNotExist              = -105 --服务器不存在
    table.UserAlreadyLogin            = -106 --用户已经登录了  
    table.ServerNotSelect             = -107 --未选择区服

    --玩家系统的段 200 - 300
    table.PlayerSys_UserNotExist      = -200 --玩家不存在 
    --


    --500 - 1000 是大厅相关的
    table.LoginHallEarlie             = -500 --玩家很早之前就已经登入过大厅了
    table.HallNotExist                = -501 --玩家要登入的大厅不存在
    table.NotLoginHall                = -502 --玩家没有登入大厅
    table.HallPersonFull              = -503 --大厅能够容纳的人数已满
    table.PlayerNotEnterHall          = -504 --玩家没有进入到大厅
    table.PlayerEnterTableEarlie      = -505 --玩家已经加入了一个桌子
    table.PlayerRepeatEnterTable      = -507 --玩家重复加入了一个桌子
    table.TableNotExist               = -508 --桌子不存在
    table.PlayerNotEnterTable         = -509 --玩家没有进入桌子

end   
G_ErrorConf:ctor()  