// Code your testbench here
// or browse Examples

module decode_test ;

reg clock ;
reg [31:0] IDpc_plus_4,IDinst; 
//inputs from ex statge 
reg [1:0]EXM;
reg [4:0]EXRegRt;
//inouts from mem stage 
reg [4:0]WBRegRd;
reg [1:0] WBWB;
reg [31:0] datatowirte;
  
wire [1:0]WB;
wire [2:0]M;
wire [3:0]EX;
wire [4:0]IDRegRs,IDRegRt,IDRegRd;
wire [31:0]DataA,DataB,imm_value;
// output to fetcf stsge 
wire [31:0] BranchAddr ;
wire brunch_taken,brunch_control,PCWrite,IFIDWrite;

initial 
  begin
    $dumpfile("dump.vcd"); $dumpvars;
    clock=1;
    IDinst =32'h00642820;//add R5,R3,R4
    #10;
    WBWB=1 ; datatowirte=9;WBRegRd=14;#10;
    WBWB=1 ; datatowirte=14;WBRegRd=12;#10;
    IDinst=32'h11CC0000;
    #10;
    IDinst=32'h00A43022;//sub R6,R5,R4 
    EXRegRt=5;EXM=2'b10;
    #10;
    
    WBWB=1 ; datatowirte=8;WBRegRd=14;#10;
    WBWB=1 ; datatowirte=8;WBRegRd=12; 
    IDinst=32'h11CC0000;//beq R14,R12,   
    #10;
    IDinst= 32'h8C030000; //lw R3,0(R1) 
    #10;
    IDinst=32'hADCE0006;//sw 
    #10
    
    $finish;
  end

initial 
  begin
    forever #5 clock=~clock;
  end 
  
 decode d(clock,WBRegRd,WBWB,EXM,EXRegRt,datatowirte,IDpc_plus_4,IDinst,WB,M,EX,IDRegRs,IDRegRt,IDRegRd,DataA,DataB,imm_value,BranchAddr,brunch_taken,brunch_control ,PCWrite,IFIDWrite);
endmodule
  
  
  
  