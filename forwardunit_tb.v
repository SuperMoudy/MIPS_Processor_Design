// Code your testbench here
// or browse Examples
module FU_tb ;
  
  reg [4:0] MEMRegRd,WBRegRd,EXRegRs,EXRegRt;
  reg  MEM_RegWrite,WB_RegWrite;
  wire[1:0]ForwardA,ForwardB; 
  reg[1:0]a=0,b=0;
  wire check;
  assign check = (a===ForwardA && b===ForwardB)?1:0;
  
 initial 
  begin
    $dumpfile("dump.vcd"); $dumpvars;
    MEM_RegWrite=0; MEMRegRd=0;WBRegRd=0;EXRegRs=0;EXRegRt=0;#10
    
    //Forwards the result from the previous instruction(Ex/Mem hazard).
    MEM_RegWrite=1;MEMRegRd=9;EXRegRs=9;a=2'b10;b=2'b0;#10;//forward A
    MEM_RegWrite=1;MEMRegRd=8;EXRegRt=8;a=2'b0;b=2'b10;#10;//forward B
    //Forwards the result from the 2'nd previous instruction (MEM/WB    hazard).
    EXRegRt=10;
    WB_RegWrite=1;WBRegRd=7;EXRegRs=7;a=2'b01;b=2'b00 ;#10;//forward A
    WB_RegWrite=1;WBRegRd=6;EXRegRt=6;a=2'b00;b=2'b01 ;#10;//forward B
    
    
    
   
  end 
ForwardUnit test(MEMRegRd,WBRegRd,EXRegRs,EXRegRt,MEM_RegWrite,WB_RegWrite, ForwardA, ForwardB);
endmodule