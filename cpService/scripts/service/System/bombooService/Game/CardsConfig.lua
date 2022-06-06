
local table = {} 
table[1 ] = {"1", 1 ,1} 
table[2 ] = {"2", 2 ,1} 
table[3 ] = {"3", 3 ,1} 
table[4 ] = {"4", 4 ,1} 
table[5 ] = {"5", 5 ,1} 
table[6 ] = {"6", 6 ,1} 
table[7 ] = {"7", 7 ,1} 
table[8 ] = {"8", 8 ,1} 
table[8 ] = {"9", 8 ,1} 
table[10] = {"10",10,1} 
table[11] = {"11",11,1} 
table[12] = {"12",12,1} 
table[13] = {"13",13,1} 
table[14] = {"1", 1 ,2} 
table[15] = {"2", 2 ,2} 
table[16] = {"3", 3 ,2} 
table[17] = {"4", 4 ,2} 
table[18] = {"5", 5 ,2} 
table[19] = {"6", 6 ,2} 
table[20] = {"7", 7 ,2} 
table[21] = {"8", 8 ,2} 
table[22] = {"9", 8 ,2} 
table[23] = {"10",10,2} 
table[24] = {"11",11,2} 
table[25] = {"12",12,2} 
table[26] = {"13",13,2} 
table[27] = {"1", 1 ,3} 
table[28] = {"2", 2 ,3} 
table[29] = {"3", 3 ,3} 
table[30] = {"4", 4 ,3} 
table[31] = {"5", 5 ,3} 
table[32] = {"6", 6 ,3} 
table[33] = {"7", 7 ,3} 
table[34] = {"8", 8 ,3} 
table[35] = {"9", 8 ,3} 
table[36] = {"10",10,3} 
table[37] = {"11",11,3} 
table[38] = {"12",12,3} 
table[39] = {"13",13,3} 
table[40] = {"1", 1 ,4} 
table[41] = {"2", 2 ,4} 
table[42] = {"3", 3 ,4} 
table[43] = {"4", 4 ,4} 
table[44] = {"5", 5 ,4} 
table[45] = {"6", 6 ,4} 
table[46] = {"7", 7 ,4} 
table[47] = {"8", 8 ,4} 
table[48] = {"9", 8 ,4} 
table[49] = {"10",10,4} 
table[50] = {"11",11,4} 
table[51] = {"12",12,4} 
table[52] = {"13",13,4} 
table[53] = {"14",14,1} 
table[54] = {"15",14,3} 
function table.comparePoint(index,elseIndex)  
    if not (index and elseIndex) then
        return false
    end
    if table[index][2] == table[elseIndex][2] then
        return true 
    end
    return false
end 
return table