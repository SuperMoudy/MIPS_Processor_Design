
// Code your design here

/*`include "hazard_unit.v"
`include "control.v"
`include "PIPELINE.v"
`include "RegFile.v"*/

module decode (clock,WBRegRd,WBWB,EXM,EXRegRt,datatowirte,IDpc_plus_4,IDinst,WB,M,EX,IDRegRs,IDRegRt,IDRegRd,DataA,DataB,imm_value,BranchAddr,brunch_taken,brunch_control ,PCWrite,IFIDWrite);

//inputs from fetch stage 
input clock ;
input [31:0] IDpc_plus_4,IDinst; 
//inputs from ex statge 
input [2:0]EXM;
input [4:0]EXRegRt;
//inouts from mem stage 
input [4:0]WBRegRd;
input [1:0] WBWB;
input [31:0] datatowirte;
//output to ex_stage 
output [1:0]WB;
output [2:0]M;
output [3:0]EX;
output [4:0]IDRegRs,IDRegRt,IDRegRd;
output [31:0]DataA,imm_value;
output reg [31:0] DataB;
// output to fetcf stsge 
output [31:0] BranchAddr ;
output brunch_taken,brunch_control,PCWrite,IFIDWrite;

 

// rs ,rt , rd reg
assign IDRegRs[4:0]=IDinst[25:21]; 
assign IDRegRt[4:0]=IDinst[20:16]; 
assign IDRegRd[4:0]=IDinst[15:11]; 


assign imm_value ={IDinst[15],IDinst[15],IDinst[15],IDinst[15],IDinst[15],IDinst[15],IDinst[15],IDinst[15],IDinst[15],IDinst[15],IDinst[15],IDinst[15],IDinst[15],IDinst[15],IDinst[15],IDinst[15],IDinst[15:0]}; 

// calc brunch 
assign BranchAddr = (imm_value << 2) + IDpc_plus_4;

// conrol 
wire [8:0] IDcontrol,ConOut;
wire HazMuxCon;

assign IDcontrol = HazMuxCon?ConOut:0;

reg [4:0] readReg1, readReg2;
wire signed [31:0] DataB_;
always @(*) begin
    if ((IDinst[31:26] == 0) && (IDinst[5:0] == 0)) begin // sll
        readReg1 <= IDinst[20:16];
        readReg2 <= 0;
        DataB <= IDinst[10:6];
    end else begin
        readReg1 <= IDinst[25:21];
        readReg2 <= IDinst[20:16];
        DataB <= DataB_;
    end
end
wire ExMemStall = EXM[0] | EXM[1];
  HazardUnit HU(readReg1,readReg2,EXRegRt,ExMemStall,PCWrite,IFIDWrite,HazMuxCon);

Control thecontrol(IDinst[31:26],ConOut);


RegFile rf(DataA,DataB_,readReg1,readReg2,WBRegRd,datatowirte,WBWB[0],clock);

assign brunch_taken=(DataA==DataB)?1:0;
assign brunch_control=IDcontrol[6];

assign WB=IDcontrol[8:7];
assign M=IDcontrol[6:4];
assign EX=IDcontrol[3:0];

endmodule 
