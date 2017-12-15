module HazardUnit(IDRegRs,IDRegRt,EXRegRt,EXMemRead,PCWrite,IFIDWrite,HazMuxCon); 
input [4:0] IDRegRs,IDRegRt,EXRegRt; 
input EXMemRead; 
output PCWrite, IFIDWrite, HazMuxCon; 
reg PCWrite, IFIDWrite, HazMuxCon; 
always@(IDRegRs,IDRegRt,EXRegRt,EXMemRead) 
    if(EXMemRead&&((EXRegRt == IDRegRs)||(EXRegRt == IDRegRt))) 
       begin//stall 
           PCWrite = 0; 
           IFIDWrite = 0; 
           HazMuxCon = 1; 
       end 
    else 
       begin//no stall 
           PCWrite = 1; 
           IFIDWrite = 1; 
           HazMuxCon = 1; 
       end 
endmodule 
