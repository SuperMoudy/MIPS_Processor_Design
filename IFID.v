module IFID(MEMWB_RegWrite, IDEX_MemRead, IDEX_RegisterRt, clk, IDControl, IDPC, IDInst,IDRegAOut, IDRegBOut);

input MEMWB_RegWrite, IDEX_MemRead, clk;
input [4:0] IDEX_RegisterRt;
output wire [10:0]  IDControl;
output [31:0] IDPC;
output wire [31:0]  IDInst;

//IF vars
wire [31:0] nextPC, IFPC_plus4, IFInst;
reg [31:0] PC;

//ID vars
wire PCSrc;
wire[4:0] ID_RegisterRs, ID_RegisterRt, ID_RegisterRd;
wire[31:0] IDPC_plus4;
output wire[31:0] IDRegAOut, IDRegBOut;
wire[31:0] IDImm_Value, BranchAddr, PCMuxOut, JumpTarget;

wire PCWrite, IFIDWrite, HazMuxCon;
wire flush;
wire [10:0] ConOut;

//IF
initial
PC=0;

assign PCSrc = ( (IDRegAOut==IDRegBOut) & IDControl[2]) |  ((IDRegAOut!=IDRegBOut) & IDControl[3]);
assign IFPC_plus4 = PC+4;
assign nextPC = PCSrc? BranchAddr : PCMuxOut;

always@(posedge clk) begin
#3

  if(PCWrite)
  begin
    PC=nextPC;
    $display("PC : %d",PC);
  end
  else
   $display("Skipped PC noop");
end

Instruction_Memory IM(PC,IFInst);

assign flush=0;
IFIDRegister IFIDReg(IFInst, IFPC_plus4, clk, IFIDWrite, flush, IDInst, IDPC_plus4);


//ID

assign IDRegisterRs = IDInst[25:21];
assign IDRegisterRt = IDInst[20:16];
assign IDRegisterRd = IDInst[15:11];
assign IDImm_Value = {IDInst[15],IDInst[15],IDInst[15],IDInst[15],IDInst[15],IDInst[15],IDInst[15],IDInst[15],IDInst[15],IDInst[15],
IDInst[15],IDInst[15],IDInst[15],IDInst[15],IDInst[15],IDInst[15],IDInst[15:0]};

assign BranchAdrr = (IDImm_Value<<2) + IDPC_plus4;
assign JumpTarget[31:28] = IFPC_plus4[31:28]; 
assign JumpTarget[27:2] = IDInst[25:0]; 
assign JumpTarget[1:0] = 0; 

assign IDControl = HazMuxCon ? ConOut : 0;

hazardDetection HD(IDEXMEM_Read, IDEX_RegisterRt, IDInst[25:21], IDInst[20:16], PCWrite, IFIDWrite, HazMuxCon);
controlUnit CU(IDInst[31:26],  ConOut); 


endmodule
