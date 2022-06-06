--可以考虑把游戏设置为一个状态机 
local GameMachine = class("GameMachine")  
GameMachine.STATUS = {START = 1 , ATTACK = 2 , CHECK =3 ,CARD_CHECK = 4 , ABANDON = 5 ,WINWIN = 6 , OVER = 7 , ERROR = 8 }  
     
function GameMachine:ctor(game)
    self._game = game
end 

--改表状态
function GameMachine:ChangeStatus(status)
    self._game._NowStatusMachine = self._game:GetStatusMachine(status)
    self._game._NowStatusMachine:EnterMachineHandle()--开始的状态
end   
--进入时会调用的一个函数
function GameMachine:EnterMachineHandle()
end 

--有一个开始方法
function GameMachine:StartHandle() 
    assert(nil,"状态不是理想状态")
end 

--结束一场游戏
function GameMachine:OverHandle()
    assert(nil,"状态不是理想状态")
end 

--结束一场游戏
function GameMachine:CapHandle(player,index)
    assert(nil,"状态不是理想状态")
end 

--校验当前游戏
function GameMachine:CheckHandle()
    assert(nil,"状态不是理想状态")
end 

--校验当前游戏
function GameMachine:CardCheckHandle()
    assert(nil,"状态不是理想状态")
end 
--洗手牌
function GameMachine:FlushHandCards()
    assert(nil,"状态不是理想状态")
end 
--洗底牌
function GameMachine:FlushAwardCards()
    assert(nil,"状态不是理想状态")
end 
return GameMachine