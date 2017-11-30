// Code your design here
module RegFile(
    output signed [31:0] ReadData1, ReadData2,
    input [4:0] ReadReg1, ReadReg2, WriteReg,
    input signed [31:0] WriteData,
    input RegWrite, Clk
    );

    reg signed [31:0] data [31:0];
    assign ReadData1 = data[ReadReg1];
    assign ReadData2 = data[ReadReg2];

    always @(posedge Clk)
      if (RegWrite)
        data[WriteReg] = WriteData;
    
endmodule
