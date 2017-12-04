// Code your design here
module ForwardUnit(MEMRegRd,WBRegRd,EXRegRs,EXRegRt,MEM_RegWrite,WB_RegWrite, ForwardA, ForwardB);
 
   input[4:0] MEMRegRd,WBRegRd,EXRegRs,EXRegRt;  
   input MEM_RegWrite,WB_RegWrite; 
   output[1:0] ForwardA,ForwardB; 
   reg[1:0] ForwardA,ForwardB; 
   //Forward A 
   always@(MEM_RegWrite or MEMRegRd or EXRegRs or WB_RegWrite or WBRegRd) 
   begin 
      if((MEM_RegWrite)&&(MEMRegRd != 0)&&(MEMRegRd== EXRegRs)) 
         ForwardA = 2'b10; 
      else if((WB_RegWrite)&&(WBRegRd != 0)&&(WBRegRd == EXRegRs)&&(MEMRegRd != EXRegRs) ) 
         ForwardA = 2'b01; 
      else 
         ForwardA = 2'b00; 
   end 
   //Forward B 
   always@(WB_RegWrite or WBRegRd or EXRegRt or MEMRegRd or MEM_RegWrite) 
   begin 
      if((WB_RegWrite)&&(WBRegRd != 0)&&(WBRegRd == EXRegRt)&&(MEMRegRd != EXRegRt) ) 
         ForwardB = 2'b01; 
      else if((MEM_RegWrite)&&(MEMRegRd != 0)&&(MEMRegRd == EXRegRt)) 
         ForwardB = 2'b10; 
      else  
         ForwardB = 2'b00; 
   end 
endmodule