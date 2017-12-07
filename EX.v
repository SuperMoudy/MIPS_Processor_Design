`include  "big_mux.v"
`include  "PIPELINE.v"
`include  "forwardUnit.v"
`include  "Alu.v"
module ExBrunch(clock,datatowrite,MEMALUOut,DEXWB ,DEXM,DEXEX,DEXRegRs,DEXRegRt,DEXRegRd,DEXDataA,DEXDataB,DEXimm_value,EXMEMRegRd,MEMWBRegRd,EXMEM_RegWrite,MEMWB_RegWrite,EXMWB,EXMM,EXALUOut,regtopass);
//inputs from decode brunch .
input                   clock;
input           [1:0]   DEXWB;
input           [2:0]   DEXM;
input           [3:0]   DEXEX;
input           [4:0]   DEXRegRs,DEXRegRt,DEXRegRd;
input           [31:0]  DEXDataA,DEXDataB,DEXimm_value;
//forwarding unit input from mem & WB brunches .
input           [4:0]   EXMEMRegRd,MEMWBRegRd;
input           [1:0]   EXMEM_RegWrite, MEMWB_RegWrite; 
// inputs to alu from mem & wb .
input            [31:0]  datatowrite,MEMALUOut;

output           [1:0]   EXMWB;
output           [2:0]   EXMM;
output           [4:0]   regtopass;
output           [31:0]  EXALUOut;//,EXMWriteDataIn;

//wires from from id/ex reg .
wire[1:0]EXWB;
wire[2:0]EXM;
wire[3:0]EXEX;
wire[4:0]EXRegRs,EXRegRt,EXRegRd;
wire[31:0]EXDataA,EXDataB,EXimm_value;


  IDEX idex(clock,DEXWB,DEXM,DEXEX,DEXDataA,DEXDataB,DEXimm_value,DEXRegRs,DEXRegRt,DEXRegRd,EXWB,EXM,EXEX,EXDataA,EXDataB,EXimm_value,EXRegRs,EXRegRt,EXRegRd);
// ex wires .

// wire b_value,alu_op ;supporting imm_value .
wire [31:0] ALUSrcA ,ALUSrcB ;//alu inputs
wire [ 1:0] ForwardA,ForwardB ;//forward unit outputs
wire [ 3:0] ALUCon;//lu control
 

  assign regtopass = EXEX[3]?EXRegRd:EXRegRt; // reg will pass to memory brunch .

//assign b_value   = EXEX[2]?D/EXimm_value:EXDataB; // supporting imm_value .

BIGMUX2 MUX0(ForwardA,EXDataA,datatowrite,MEMALUOut,0,ALUSrcA); 
  BIGMUX2 MUX1(ForwardB,EXDataB,datatowrite,MEMALUOut,0,ALUSrcB);
  ForwardUnit FU(EXMEMRegRd,MEMWBRegRd,EXRegRs,EXRegRt,EXMEM_RegWrite[0],MEMWB_RegWrite[0],ForwardA,ForwardB); 
alu_control ALUcontrol(EXEX[1:0],EXimm_value[5:0],ALUCon); 
 
  ALU alu(
        .read_data1 (ALUSrcA),
        .read_data2 (ALUSrcB),
        .op_code    (ALUCon),
        .result     (EXALUOut),
        .zero       (zero)
    );


assign EXMWB=EXWB;
assign EXMM =EXM ;  

endmodule 


