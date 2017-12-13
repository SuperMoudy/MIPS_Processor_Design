module Clock(clk);
	output reg clk;
	initial 
	begin
		clk = 0;
		#10;
	end

	always
	begin
		clk = ~clk; //f = 500 MHz
		#1;
	end
endmodule


module Adder(in1 , in2 , out);
	input[31:0] in1;
	input[31:0] in2;
	output[31:0] out;
	assign out = in1 + in2;
endmodule


module top_mod; 

/////////Including Clock Module///////
	wire clk;
	Clock c1(clk);

//////////////////////////////////////////////////
//////////////////////////////////////////////////
////////////////// STAGE  ONE ////////////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////


//////////Instruction Fetch///////////
	wire Branch_Control;
	wire Branch_Taken;
	wire PC_selector;
	and(PC_selector , Branch_Control , Branch_Taken);
/////////PC_MUX Module//////////

	wire[31:0] PC_from_Branch;
	wire[31:0] PC_from_Adder;
	wire[31:0] next_PC;

	MUX pc_mux(PC_selector , PC_from_Branch , PC_from_Adder , next_PC);

//////////PC Module//////////////
	wire PCWrite;
	wire[31:0] current_PC;
	PC pc1(clk , next_PC , PCWrite , current_PC);

//////////////Instruction Memory//////////
	wire[31:0] Instruction;
	Instruction_Memory(current_PC , Instruction);
///////////////////////////////////////
	Adder normal_pc_adder(current_PC , 4 , PC_from_Adder);

////////////////////////////////////////
	wire IFIDWrite;
	wire[31:0] Instruction_to_ID , PC_from_Adder_to_ID;
	IFID IFID1(clk , Instruction ,IFIDWrite , PC_from_Adder , Instruction_to_ID , PC_from_Adder_to_ID);





//////////////////////////////////////////////////
//////////////////////////////////////////////////
////////////////// STAGE  TWO ////////////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////

//wire clock ; //was reg in tb //this is clk
	//wire [31:0] IDpc_plus_4;//,IDinst; //was reg in tb 

//inputs from ex statge 
	wire [1:0]EXM; //was reg in tb
	wire [4:0]EXRegRt; //was reg in tb

//inouts from mem stage 
	wire [4:0]WBRegRd;  //was reg in tb
	wire [1:0] WBWB;    //was reg in tb
	wire [31:0] Write_Data;  //was reg in tb
  
	wire [1:0]WB;
	wire [2:0]M;
	wire [3:0]EX;
	wire [4:0]IDRegRs,IDRegRt,IDRegRd;
	wire [31:0]DataA,DataB,imm_value;
// output to fetcf stsge 
//wire [31:0] BranchAddr ;                        //this is PC_from_Branch
	//wire IFIDWrite; //,PCWrite; brunch_taken,brunch_control,


	decode d1(clk , WBRegRd , WBWB , EXM , EXRegRt , Write_Data , PC_from_Adder_to_ID , Instruction_to_ID ,
		WB , M , EX , IDRegRs , IDRegRt , IDRegRd , DataA , DataB, imm_value ,
		PC_from_Branch , Branch_Taken , Branch_Control , PCWrite , IFIDWrite);

//////////////////////////////////////////////////
//////////////////////////////////////////////////
///////////////// STAGE  THREE ///////////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////


/////Forwarding Unit

	//write your code here
	



////EX
	//write your code here




//////////////////////////////////////////////////
//////////////////////////////////////////////////
///////////////// STAGE  FOUR ////////////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////

	//////EXMEM Wires//////

	//innput
	//wire                   clock;
	//wire           [1:0]   WB;
	//wire           [2:0]   M;
	wire           [4:0]   RegRD;
	wire           [31:0]  ALUOut,WriteDataIn;


	//output
	wire     [1:0]   WBreg;
	wire     [2:0]   Mreg;
	wire     [31:0]  ALUreg,WriteDataOut;
	wire     [4:0]   RegRDreg;

	/////////////////////////////

	EXMEM emem1(clk,WB,M,ALUOut,RegRD,WriteDataIn,Mreg,WBreg,ALUreg,RegRDreg,WriteDataOut);

	////////////////////////////

	/////Data Memory Wires//////

	//input
	//clock , ALUreg , WriteDataOut
	wire MemWrite; assign MemWrite = Mreg[0:0];
	wire MemRead; assign MemRead = Mreg[1:1];
	
	//output
	wire[31:0] Read_Data; //Data Read from memory in case of LW instruction
	
	////////////////////////////
	
	Data_Memory dm1(.Clock(clk) , .Address(ALUreg) , .Write_Data(WriteDataOut) , .MemWrite(MemWrite) , .MemRead(MemRead) , 
			.Read_Data(Read_Data));
	
	///////////////////////////	
	
//////////////////////////////////////////////////
//////////////////////////////////////////////////
///////////////// STAGE  FIVE ////////////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////
	
	
	///////////////////////////
	///////MEMWB Wires/////////
	
	//input
	//clock , WBreg , Read_Data , ALUreg , RegRDreg
	
	//output
	wire     [1:0]   WBreg2;
	wire     [31:0]  Memreg2,ALUreg2;
	//wire     [4:0]   RegRDreg2;

	//////////////////////////
	
	MEMWB mwb(.clock(clk) , .WB(WBreg) , .Memout(Read_Data) , .ALUOut(ALUreg) , .RegRD(RegRDreg) , 
		  .WBreg(WBreg2) , .Memreg(Memreg2) , .ALUreg(ALUreg2) , .RegRDreg(WBRegRd));
	
	
	//////////////////////////

	////////////MUX///////////

	//input
	wire MemtoReg; assign MemtoReg = WBreg2[0:0];
	//Memreg2 , ALUreg2
	
	//output
	//wire[31:0] Write_Data;


	/////////////////////////
	
	MUX m1(.MemtoReg(MemtoReg) , .Read_Data(Memreg2) , .ALU_Result(ALUreg2) , .Write_Data(Write_Data));
	
	/////////////////////////
	
	
	
	
endmodule
	
