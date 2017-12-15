module PC(clk , next_PC , PCWrite , current_PC);

	input clk;
	input[31:0] next_PC;
	input PCWrite;
	output reg[31:0] current_PC = 0;

	always@(posedge clk)
	begin
		if(PCWrite)
			current_PC <= next_PC;
                /* else */
                /*         current_PC <= current_PC + 4; */
	end

endmodule

module Instruction_Memory(Read_Address , Instruction);

	input [31:0] Read_Address; //8-bit address, multiplied by 4
	output [31:0]Instruction; //Instruction that was read
	reg[31:0]Instruction;
	reg[31:0] I_Memory [0:255]; //2 power 8 instructions of length 32-bits
//	integer i;
	wire [31:0] i0 = I_Memory[0];
	wire [31:0] i1 = I_Memory[1];
	wire [31:0] i2 = I_Memory[2];
	initial $readmemh("instructions.hex", I_Memory);
	always@(Read_Address) //when reading a new address fetch the corresponding instruction
		Instruction = I_Memory[Read_Address >> 2]; // because addresses are given multiplied by 4, so we div them by 4

/*	initial //Initializing Memory (we will read from assembler later)
	begin
		for(i = 0 ; i < 256 ; i=i+1)
		begin
			I_Memory[i]=i;
		end
	end
*/

endmodule
/*
module Instruction_Memory(Read_Address , Instruction);

	input [31:0] Read_Address; //8-bit address
	output [31:0]Instruction; //Instruction that was read
	reg[31:0]Instruction;
	reg[31:0] I_Memory [0:255]; //2 power 8 instructions of length 32-bits
	integer i;

	always@(Read_Address) //when reading a new address fetch the corresponding instruction
		Instruction = I_Memory[Read_Address];

	initial //Initializing Memory (we will read from assembler later)
	begin
		for(i = 0 ; i < 256 ; i=i+1)
		begin
			I_Memory[i]=i;
		end
	end


endmodule

*/
