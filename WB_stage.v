/////////// EX-MEM Pipeline Register ///////////

module EXMEM(clock,WB,M,ALUOut,RegRD,WriteDataIn,Mreg,WBreg,ALUreg,RegRDreg,WriteDataOut);
input                   clock;
input           [1:0]   WB;
input           [2:0]   M;
input           [4:0]   RegRD;
input           [31:0]  ALUOut,WriteDataIn;
output  reg     [1:0]   WBreg;
output  reg     [2:0]   Mreg;
output  reg     [31:0]  ALUreg,WriteDataOut;
output  reg     [4:0]   RegRDreg;
initial 
begin
WBreg=0;
Mreg=0;
ALUreg=0;
WriteDataOut=0;
RegRDreg=0;
end
always@(posedge clock)
begin
WBreg <= WB;
Mreg <= M;
ALUreg <= ALUOut;
RegRDreg <= RegRD;
WriteDataOut <= WriteDataIn;
end
endmodule


//////////////////// Data Memory //////////////////////////


module Data_Memory(Clock , Address , Write_Data , MemWrite , MemRead , Read_Data);

	input wire Clock;
	input wire[31:0] Address; //Address computed in case of SW or LW
	input wire[31:0] Write_Data; //Data to be stored in memory in case of SW instruction
	input MemWrite;   //control Signal in case of a memory_write operation (like in sw)
	input MemRead;   //control signal in case of a memory read operation (like in lw)
	output reg[31:0] Read_Data; //Data Read from memory in case of LW instruction
	reg[31:0] D_Memory [0:255]; //Data Memory from inside (256 places)

	always@(Address or Write_Data or MemWrite or MemRead) //Detect ALU result
	begin
		if(MemWrite == 0 && MemRead == 1) //For lw instruction
			Read_Data = D_Memory[Address];
		/*else if(MemWrite == 1 && MemRead == 0) //for sw instruction
			D_Memory[Address] <= Write_Data;*/
	end

	always@(posedge Clock)
	begin
		if(MemWrite == 1 && MemRead == 0)
			D_Memory[Address] <= Write_Data;
	end

	initial
	begin
		D_Memory[3] = 3;
		D_Memory[7] = 7;
	end
	
endmodule

//////////////////// MEM-WB Pipeline Register //////////////////////////

module MEMWB(clock,WB,Memout,ALUOut,RegRD,WBreg,Memreg,ALUreg,RegRDreg);
input                   clock;
input           [1:0]   WB;
input           [4:0]   RegRD;
input           [31:0]  Memout,ALUOut;
output  reg     [1:0]   WBreg;
output  reg     [31:0]  Memreg,ALUreg;
output  reg     [4:0]   RegRDreg;
initial 
begin
WBreg = 0;
Memreg = 0;
ALUreg = 0;
RegRDreg = 0;
end
always@(posedge clock)
begin
WBreg <= WB;
Memreg <= Memout;
ALUreg <= ALUOut;
RegRDreg <= RegRD;
end

endmodule


/////////////////////// Multiplexor //////////////////////////////


module MUX(MemtoReg , Read_Data , ALU_Result , Write_Data);

input MemtoReg;
input[31:0] Read_Data;
input[31:0] ALU_Result;
output[31:0] Write_Data;

assign Write_Data = MemtoReg ? Read_Data : ALU_Result;

endmodule



///////////////////////////////////////////////////////////////////
///////////////////// Test Bench //////////////////////////////////
///////////////////////////////////////////////////////////////////

module wb_stage_tb;

//////EXMEM Wires//////
//innput
wire                   clock;
wire           [1:0]   WB;
wire           [2:0]   M;
wire           [4:0]   RegRD;
wire           [31:0]  ALUOut,WriteDataIn;
//output
wire     [1:0]   WBreg;
wire     [2:0]   Mreg;
wire     [31:0]  ALUreg,WriteDataOut;
wire     [4:0]   RegRDreg;
/////////////////////////////

EXMEM emem1(clock,WB,M,ALUOut,RegRD,WriteDataIn,Mreg,WBreg,ALUreg,RegRDreg,WriteDataOut);

////////////////////////////
/////Data Memory Wires//////
//input
//clock , ALUreg , WriteDataOut
wire MemWrite;
wire MemRead;

//output
wire[31:0] Read_Data; //Data Read from memory in case of LW instruction
////////////////////////////

Data_Memory dm1(.Clock(clock) , .Address(ALUreg) , .Write_Data(WriteDataOut) , .MemWrite(MemWrite) , .MemRead(MemRead) , 
		.Read_Data(Read_Data));

///////////////////////////
///////MEMWB Wires/////////
//input
//clock , WBreg , Read_Data , ALUreg , RegRDreg

//output
wire     [1:0]   WBreg2;
wire     [31:0]  Memreg2,ALUreg2;
wire     [4:0]   RegRDreg2;
//////////////////////////

MEMWB mwb(.clock(clock) , .WB(WBreg) , .Memout(Read_Data) , .ALUOut(ALUreg) , .RegRD(RegRDreg) , 
	  .WBreg(WBreg2) , .Memreg(Memreg2) , .ALUreg(ALUreg2) , .RegRDreg(RegRDreg2));

//////////////////////////
////////////MUX///////////
//input
wire MemtoReg;
//Memreg2 , ALUreg2

//output
wire[31:0] Write_Data;
/////////////////////////

MUX m1(.MemtoReg(MemtoReg) , .Read_Data(Memreg2) , .ALU_Result(ALUreg2) , .Write_Data(Write_Data));

/////////////////////////


endmodule
