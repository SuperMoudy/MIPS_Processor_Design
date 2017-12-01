/*module main;
reg  [31:0] read_data1 , read_data2,sign_extend;
wire [3:0] op_code;
reg  [4:0] shift_amt;
wire [31:0] result,write_data;
reg  [1:0]	ALUOp ;	
reg  [5:0]	FUNCT ;
wire zero ;
reg ALUSrc;
initial
begin

$monitor("%b\n%b\n%b\n%b\n%b\n%b\n%b\n%b\n%b\n%b\n%b\n%b\n\n\n",ALUOp,FUNCT,op_code,read_data1 , read_data2 , sign_extend,ALUSrc,write_data,op_code , shift_amt , result,zero);

#10 
ALUOp=2'b00 ;
read_data1 = 2;
read_data2 = 2;
ALUSrc=1;
sign_extend=0;
shift_amt = 1;
#10 
ALUOp=2'b00 ;
read_data1 = 2;
read_data2 = 2;
sign_extend=0;
ALUSrc=0;
shift_amt = 1;
#10
ALUOp=2'b01 ;
read_data1 = 2;
read_data2 = 2;
shift_amt = 1;
#10
ALUOp=2'b10 ;
FUNCT=6'b000000;
read_data1 = 2;
read_data2 = 3;
shift_amt = 1;
#10
FUNCT=6'b101010;
read_data1 = 1;
read_data2 = 3;
shift_amt = 1;
#10
FUNCT=6'b100101;
read_data1 = 2;
read_data2 = 3;
shift_amt = 1;
#10
FUNCT=6'b100010;
read_data1 = 1;
read_data2 = 1;
shift_amt = 1;
#10
FUNCT=6'b100000;
read_data1 = 2;
read_data2 = 3;
shift_amt = 1;
#10
FUNCT=6'b100100; 
read_data1 = 2;
read_data2 = 3;
shift_amt = 1;



end

ALU my_alu1(read_data1 , write_data , op_code , shift_amt , result,zero);
alu_control ver1(ALUOp,FUNCT,op_code);
two_to_one_mux ver11(read_data2 , sign_extend , ALUSrc , write_data);
endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////
/*
module test_bench_for_ALU_CTRL_ONLY;
reg 	[1:0]	ALUOp ;	
reg     [5:0]	FUNCT ;
reg	[3:0]	op_code ;
always @(*)	// at any change in the inputs 		 
// parallel block	
	if(ALUOp == 2'b00)	  //memory 
		op_code=4'b0010 ;   // add to find address
	else if(ALUOp == 2'b10)	  //branch  
		op_code=4'b0110  ;  // subtract 
// in case of R-type(sequential) 
	else 
	begin
	case 	( FUNCT )
		6'b100000 :		op_code=4'b0000	;	//add
		6'b100010 :		op_code=4'b0001	;	//sub	
		6'b100100 :		op_code=4'b0010	;	//and
		6'b100101 : 		op_code=4'b0011	;	//or
		6'b101010 :		op_code=4'b0111	;	//set on less than
		6'b000000 :		op_code=4'b0100	;	//sll
		default	  :		op_code=op_code	;	//stay on this state
	endcase
	end	
initial 
begin
$monitor ( $time,,,,, "%b     %b       %b  " , ALUOp , FUNCT , op_code);

#10 
ALUOp=2'b00 ;
#10
ALUOp=2'b10 ;
#10
ALUOp=2'b01 ;
FUNCT=6'b000000;
#10
FUNCT=6'b101010;
#10
FUNCT=6'b100101;
#10
FUNCT=6'b100010;
#10
FUNCT=6'b100000;
#10
FUNCT=6'b100100; 
end
endmodule*/
///////////////////////////////////////////////////////////////////////////////
module alu_control(ALUOp,FUNCT,op_code);
/////////////////////////////////////////
//ports :
input	[1:0]	ALUOp ;		 // control signal to define the required operation			
input 	[5:0]	FUNCT ;		 //to define the function in case of R-format 
output 	reg	[3:0]	op_code ; // signal going to the ALU
/////////////////////////////////////////
always @(*)	// at any change in the inputs 		 
// parallel block	
	if(ALUOp == 2'b00)	  //memory 
		op_code=4'b0000 ;   // add to find address
	else if(ALUOp == 2'b01)	  //branch  
		op_code=4'b0001  ;  // subtract 
// in case of R-type(sequential) 
	else 
	begin
	case 	( FUNCT )
		6'b100000 :		op_code=4'b0000	;	//add
		6'b100010 :		op_code=4'b0001	;	//sub	
		6'b100100 :		op_code=4'b0010	;	//and
		6'b100101 : 		op_code=4'b0011	;	//or
		6'b101010 :		op_code=4'b0111	;	//set on less than
		6'b000000 :		op_code=4'b0100	;	//sll
		default	  :		op_code=op_code	;	//stay on this state
	endcase
	end	
endmodule

/////////////////////////////////////////////////////////////////////////////
//ALU///////////////////////////////////////////////////////////////////////
module ALU(read_data1 , read_data2 , op_code , shift_amt , result,zero);
input [31:0] read_data1 , read_data2;
input [3:0] op_code;
input [4:0] shift_amt;
output reg [31:0] result;
output reg zero ;
always@(read_data1 or read_data2 or op_code or shift_amt)
begin
zero=1'b0; //reset zero flag 
if(op_code == 0)
begin result = read_data1 + read_data2; end

else if(op_code == 1)
begin result = read_data1 - read_data2; 
//check for branching 
if (result==0)  
zero=1'b1;
else 
zero=1'b0;
end

else if(op_code == 2)
begin result = read_data1 & read_data2; end

else if(op_code == 3)
begin result = read_data1 | read_data2; end

else if(op_code == 4)
begin result = read_data1 << shift_amt; end

else if(op_code == 5)
begin result = read_data1 >> shift_amt; end

else if(op_code == 6)
begin result = $signed(read_data1) >>> shift_amt; end

else if(op_code == 7)
begin
if(read_data1 > read_data2) begin result = read_data1; end
else begin result = read_data2; end
end

else if(op_code == 8)
begin

if(read_data1 < read_data2) begin result = read_data1; end
else begin result = read_data2; end
end

else begin result = 32'bx; end

end

endmodule 
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/* 2-1 Multiplexor */
module two_to_one_mux(read_data2 , sign_extend , ALUSrc , write_data);
input  [31:0]read_data2 ;
input  [31:0]sign_extend;
input ALUSrc;
output reg [31:0]write_data; 

always@(read_data2 or sign_extend or ALUSrc)
begin

if(ALUSrc == 0)
begin write_data = read_data2; end
else if(ALUSrc == 1)
begin write_data = sign_extend; end
else 
begin write_data = 32'bx; end

end

endmodule
