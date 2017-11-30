module Data_Memory(Address , Write_Data , MemWrite , MemRead , Read_Data);

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
		else if(MemWrite == 1 && MemRead == 0) //for sw instruction
			D_Memory[Address] = Write_Data;
	end

	initial
	begin
		D_Memory[3] = 3;
		D_Memory[7] = 7;
	end
	
endmodule


module data_memo_tb;

	reg[31:0]Address;
	reg[31:0]Write_Data;
	reg MemWrite;
	reg MemRead;
	wire[31:0] Read_Data;

	Data_Memory m1(.Address(Address) , .Write_Data(Write_Data) , .MemWrite(MemWrite) , .MemRead(MemRead) , .Read_Data(Read_Data));
	initial
	begin
		//lw instruction after 2ns
		MemWrite = 0; 
		MemRead = 1;  
		Address = 7;
		#2
		$display($time,,"%b\n",Read_Data);
		//sw instruction after 1ns
		MemRead = 0;
		MemWrite = 1;
		Address = 15;
		Write_Data = 15; 

		#1
		//lw instruction after 1ns
		MemRead = 1;
		MemWrite = 0;
		#1
		$display($time,,"%b\n",Read_Data);
		//resetting control signals
		MemWrite = 0;
		MemRead = 0;
		
	end


endmodule
