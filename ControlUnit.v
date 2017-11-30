module controlUnit(input wire [5:0] OpCode,output reg RegDst,output reg BranchEq,output reg BranchNe,output reg MemRead,output reg MemtoReg,
output reg [1:0]AluOp,output reg MemWrite,output reg AluSrc,output reg RegWrite, output reg Jump);

always @(OpCode)
    begin
		

       case(OpCode)

         

          6'b100011: begin
          AluOp[1:0]	<= 2'b00;
          AluSrc	<= 1'b1;
	  BranchEq	<= 1'b0;
	  BranchNe	<= 1'b0;
	  MemRead	<= 1'b1;
	  MemtoReg	<= 1'b1;
	  MemWrite	<= 1'b0;
	  RegDst	<= 1'b0;
          RegWrite	<= 1'b1;
	  Jump		<= 1'b0;
         end

          6'b101011:  begin
         
          AluOp[1:0]	<= 2'b00;
          AluSrc	<= 1'b1;
	  BranchEq	<= 1'b0;
	  BranchNe	<= 1'b0;
	  MemRead	<= 1'b0;
	  MemtoReg	<= 1'b0;
	  MemWrite	<= 1'b1;
	  RegDst	<= 1'b1;
          RegWrite	<= 1'b0;
	  Jump		<= 1'b0;
          end          
          
          6'b000100: begin
          
          AluOp[1:0]	<= 2'b01;
          AluSrc	<= 1'b0;
	  BranchEq	<= 1'b1;
	  BranchNe	<= 1'b0;
	  MemRead	<= 1'b0;
	  MemtoReg	<= 1'b0;
	  MemWrite	<= 1'b0;
	  RegDst	<= 1'b1;
          RegWrite	<= 1'b0;
	  Jump		<= 1'b0;
          end
       
          //6'b000000: begin
          default:begin
          AluOp[1:0]	<= 2'b10;
          AluSrc	<= 1'b0;
	  BranchEq	<= 1'b0;
	  BranchNe	<= 1'b0;
	  MemRead	<= 1'b0;
	  MemtoReg	<= 1'b0;
	  MemWrite	<= 1'b0;
	  RegDst	<= 1'b1;
          RegWrite	<= 1'b1;
	  Jump		<= 1'b0;
          end

       endcase
     end

endmodule

/*

module controlUnit(input [5:0] OpCode,output reg RegDst,output reg BranchEq,output reg BranchNe,output reg MemRead,output reg MemtoReg,
output reg [1:0]AluOp,output reg MemWrite,output reg AluSrc,output reg RegWrite, output reg Jump);

always @(OpCode)
    begin
		



         

         if(OpCode== 6'b100011) begin
          AluOp[1:0]	= 2'b00;
          AluSrc	= 1'b1;
	  BranchEq	= 1'b0;
	  BranchNe	= 1'b0;
	  MemRead	= 1'b1;
	  MemtoReg	= 1'b1;
	  MemWrite	= 1'b0;
	  RegDst	= 1'b0;
          RegWrite	= 1'b1;
	  Jump		= 1'b0;
          end

          if(OpCode==6'b101011) begin
         
          AluOp[1:0]	= 2'b00;
          AluSrc	= 1'b1;
	  BranchEq	= 1'b0;
	  BranchNe	= 1'b0;
	  MemRead	= 1'b0;
	  MemtoReg	= 1'b0;
	  MemWrite	= 1'b1;
	  RegDst	= 1'b1;
          RegWrite	= 1'b0;
	  Jump		= 1'b0;
          end
          
         if(OpCode== 6'b000100) begin
          
          AluOp[1:0]	= 2'b01;
          AluSrc	= 1'b0;
	  BranchEq	= 1'b1;
	  BranchNe	= 1'b0;
	  MemRead	= 1'b0;
	  MemtoReg	= 1'b0;
	  MemWrite	= 1'b0;
	  RegDst	= 1'b1;
          RegWrite	= 1'b0;
	  Jump		= 1'b0;
          end
       
          if(OpCode==6'b000000) begin
          AluOp[1:0]	= 2'b10;
          AluSrc	= 1'b0;
	  BranchEq	= 1'b0;
	  BranchNe	= 1'b0;
	  MemRead	= 1'b0;
	  MemtoReg	= 1'b0;
	  MemWrite	= 1'b0;
	  RegDst	= 1'b1;
          RegWrite	= 1'b1;
	  Jump		= 1'b0;
          end

      
     end

endmodule
*/
         

