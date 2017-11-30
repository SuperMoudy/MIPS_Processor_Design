module Instruction_Memory(Read_Address , Instruction);

	input [7:0] Read_Address; //8-bit address
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


//Instruction_memory testbench
module inst_memo_tb;

	reg[7:0] PC; //Program Counter which is an address
	wire[31:0]Instruction; //Instruction that was fetched
	//Instance from our Instruction Memory
	Instruction_Memory m1(.Read_Address(PC),.Instruction(Instruction));
	
	//Simple Test of our Memory
	initial
	begin

		PC = 20;
		#5
		$display("%b",Instruction); //Display the instruction

	end


endmodule

