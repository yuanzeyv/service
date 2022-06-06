local retTable = {}  
--系统管理模块 0 - 99 
retTable[1] = {msg ="Net_LoginSystem",sys= 1 }
retTable[2] = {msg ="Net_LoginOutSystem",sys= 1 }
retTable[3] = {msg ="Net_RequestSystem",sys= 1 }
retTable[4] = {msg ="Net_SystemInitSuccess",sys= 1 }

--接龙模块 100 - 199  
retTable[100] = {msg ="Net_Request_HallList",sys= 3 } 
retTable[101] = {msg ="Net_EnterHall",sys= 3 } 
retTable[102] = {msg ="Net_LeaveHall",sys= 3 } 
retTable[103] = {msg ="Net_EnterTable",sys= 3 } 
retTable[104] = {msg ="Net_LeaveTable",sys= 3 } 
retTable[105] = {msg ="Net_PlayerReady",sys= 3 } 
retTable[106] = {msg ="Net_PlayerUnready",sys= 3 } 
retTable[107] = {msg ="Net_PlayerStand",sys= 3 } 
retTable[108] = {msg ="Net_StartGame",sys= 3 } 
retTable[109] = {msg ="Net_EnterGame",sys= 3 } 
retTable[110] = {msg ="Net_LeaveGame",sys= 3 } 
retTable[111] = {msg ="Net_TableAllInfo",sys= 3 } 
retTable[112] = {msg ="Net_Request_HallInfo",sys= 3 } 
retTable[113] = {msg ="Net_Request_HallInfo",sys= 3 } 
retTable[114] = {msg ="Net_PlayerHallStatusChange",sys= 3 }  
--玩家信息模块 200 - 299
retTable[200] = {msg ="Net_Request_PlayerInfo",sys= 2 }   

--时间管理模块 300 - 399 
retTable[300] = {msg ="Net_Heartbeat",sys= 4 }   
retTable[301] = {msg ="Net_Request_Heartbeat",sys= 4 }   
retTable[302] = {msg ="Net_Player_Net_Break",sys= 4 }    

--资源管理系统 400  - 499
retTable[400] = {msg ="Net_DownLoad_Resource",sys= 5 }      
--背包系统 500 - 599  
return retTable