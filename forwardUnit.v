// Code your design here
module ForwardUnit(MEMRegRd, WBRegRd, EXRegRs,EXRegRt,MEM_RegWrite,WB_RegWrite, load, ForwardA, ForwardB);
    input[4:0] MEMRegRd,WBRegRd,EXRegRs,EXRegRt;  
    input MEM_RegWrite,WB_RegWrite, load;
    output[1:0] ForwardA,ForwardB; 
    reg[1:0] ForwardA,ForwardB; 
    //Forward A 
    always@(*) 
    begin 
        if ((load && MEM_RegWrite && EXRegRt == MEMRegRd)
         || (load && WB_RegWrite && EXRegRt == WBRegRd))
            ForwardA <= 2'b00;
        else if ((MEM_RegWrite)&&(MEMRegRd != 0)&&(MEMRegRd== EXRegRs)) 
            ForwardA <= 2'b10; 
        else if ((WB_RegWrite)&&(WBRegRd != 0)&&(WBRegRd == EXRegRs)&&(MEMRegRd != EXRegRs) ) 
            ForwardA <= 2'b01; 
        else 
            ForwardA <= 2'b00; 
    end 
    //Forward B 
    always@(*) 
    begin 
        if ((load && MEM_RegWrite && EXRegRt == MEMRegRd)
         || (load && WB_RegWrite && EXRegRt == WBRegRd))
            ForwardB = 2'b00;
        else if ((WB_RegWrite)&&(WBRegRd != 0)&&(WBRegRd == EXRegRt)&&(MEMRegRd != EXRegRt) ) 
            ForwardB = 2'b01; 
        else if ((MEM_RegWrite)&&(MEMRegRd != 0)&&(MEMRegRd == EXRegRt)) 
            ForwardB = 2'b10; 
        else  
            ForwardB = 2'b00; 
    end 
endmodule
