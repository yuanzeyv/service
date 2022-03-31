if G_ErrorConf then 
    return 
end--防止重复包含 
require("Config.SystemIDConfig") 
Net_ErrorConfigClass = {}
function Net_ErrorConfigClass:ctor() 
    self._errorTable = {}
    self:InitTable(self._errorTable)
    setmetatable(self,{__index = self._errorTable })
end    

function Net_ErrorConfigClass:InitTable(table)   
    --0-500是通用错误
    table.ExecuteSuccess              =  0 --运行正常
    table.StatusERROR                 = -1 --状态出错，请尽快查明原因
    table.SystemNotExist              = -2 --没有找到对应的系统信息
    table.RepetSystem                 = -3 --角色已经登录了当前系统
    table.NotLoginSystem              = -4 --角色没有登录当前系统

    --500 - 1000 是大厅相关的
    table.LoginHallEarlie             = -500 --玩家很早之前就已经登入过大厅了
    table.HallNotExist                = -501 --玩家要登入的大厅不存在
    table.NotLoginHall                = -502 --玩家没有登入大厅
    table.HallPersonFull              = -503 --大厅能够容纳的人数已满
    table.PlayerNotEnterHall          = -504 --玩家没有进入到大厅
    table.PlayerEnterTableEarlie      = -505 --玩家已经加入了一个桌子
    table.PlayerRepeatEnterTable      = -507 --玩家重复加入了一个桌子

    --50000之后，按照ID划分，每个ID占用10000 
    local SystemID = G_SysIDConf:GetTable().SystemManager * -10000 
    table.System_JoinedTableEarlie           = SystemID - 1 --很早就连接了桌子


    local bombooID = G_SysIDConf:GetTable().PokerSystem * -10000
    table.bomboo_JoinedTableEarlie           = bombooID - 1 --很早就连接了桌子
    table.bomboo_ChairNotEnoughBySitDown     = bombooID - 2 --大厅座位已经满了，无法加入
    table.bomboo_TableCrowd                  = bombooID - 3 --桌子目前十分拥挤了 
    table.bomboo_NotEnterTable               = bombooID - 4 --角色没有进入桌子
    table.bomboo_PlayerHasStartGame          = bombooID - 5 --玩家已经开始了游戏
    table.bomboo_StatusSame                  = bombooID - 6 --当前已经是此状态了
    table.bomboo_NeedCancleReady             = bombooID - 7 --玩家需要取消准备
    table.bomboo_StatusERROR                 = bombooID - 8 --状态出错，请尽快查明原因
    table.bomboo_PlayerIsMaster              = bombooID - 9 --当前玩家是房主
    table.bomboo_PlayerNeedSitDown           = bombooID - 10--玩家需要先坐下
    table.bomboo_NeedOwnerMasterIdentity     = bombooID - 11--玩家不是房主
    table.bomboo_ExecuteError                = bombooID - 12--玩家状态错误 
    table.bomboo_NotReadyState               = bombooID - 13--玩家当前没有准备
end   
G_ErrorConf = Net_ErrorConfigClass:ctor()  