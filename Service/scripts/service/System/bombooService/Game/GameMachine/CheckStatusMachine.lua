local GameMachine = require("bombooService.Game.GameMachine.GameMachine")
local CheckStatusMachine = class("CheckStatusMachine",GameMachine)    
--进入时会调用的一个函数
function CheckStatusMachine:EnterMachineHandle()
    self:CheckHandle()
end 

--有一个开始方法
function CheckStatusMachine:StartHandle()  
    assert(nil,"状态不是理想状态")
end 

--结束一场游戏
function CheckStatusMachine:OverHandle()
    assert(nil,"状态不是理想状态")
end 

--结束一场游戏
function CheckStatusMachine:CapHandle(player,index) 
    assert(nil,"状态不是理想状态")
end 

--校验当前游戏
function CheckStatusMachine:CheckHandle()
    print("HAHAHAHHAHA",#self._game._playerList[self._game:NowOperationalUser()].handCards ,#self._game._tableCards, #self._game._playerList[self._game:NowOperationalUser()].awardCards,self._game:NowOperationalUser())
    local isFlush = self._game:CheckCardTable(self._game:NowOperationalUser())--判断当前是否有牌如奖励牌库
    if not isFlush then
        self._game:OperationalUserChange()
    end
    print("HAHAHAHHAHA",#self._game._playerList[self._game:NowOperationalUser()].handCards ,#self._game._tableCards, #self._game._playerList[self._game:NowOperationalUser()].awardCards,self._game:NowOperationalUser())
    self:ChangeStatus(self.STATUS.ATTACK)--修改状态到攻击模式--进入攻击模式
end 

--校验当前游戏
function CheckStatusMachine:CardCheckHandle() 
    assert(nil,"状态不是理想状态")
end 
--洗手牌
function CheckStatusMachine:FlushHandCards()
    assert(nil,"状态不是理想状态")
end 
--洗底牌
function CheckStatusMachine:FlushAwardCards()
    assert(nil,"状态不是理想状态")
end 
return CheckStatusMachine