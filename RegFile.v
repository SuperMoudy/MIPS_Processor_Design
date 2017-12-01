// Code your design here
module RegFile(
    output signed [31:0] ReadData1, ReadData2,
    input [4:0] ReadReg1, ReadReg2, WriteReg,
    input signed [31:0] WriteData,
    input RegWrite, Clk
    );

    reg signed [31:0] data [31:0];
    assign ReadData1 = ReadReg1 == 0 ? 0 : data[ReadReg1];
    assign ReadData2 = ReadReg2 == 0 ? 0 : data[ReadReg2];
    initial data[1] = 1;  // for debugging

    always @(posedge Clk)
      if (RegWrite)
        data[WriteReg] = WriteData;

    // for wave form
    wire signed [31:0] zr = data[0];
    wire signed [31:0] at = data[1];
    wire signed [31:0] v0 = data[2];
    wire signed [31:0] v1 = data[3];
    wire signed [31:0] a0 = data[4];
    wire signed [31:0] a1 = data[5];
    wire signed [31:0] a2 = data[6];
    wire signed [31:0] a3 = data[7];
    wire signed [31:0] t0 = data[8];
    wire signed [31:0] t1 = data[9];
    wire signed [31:0] t2 = data[10];
    wire signed [31:0] t3 = data[11];
    wire signed [31:0] t4 = data[12];
    wire signed [31:0] t5 = data[13];
    wire signed [31:0] t6 = data[14];
    wire signed [31:0] t7 = data[15];
    wire signed [31:0] s0 = data[16];
    wire signed [31:0] s1 = data[17];
    wire signed [31:0] s2 = data[18];
    wire signed [31:0] s3 = data[19];
    wire signed [31:0] s4 = data[20];
    wire signed [31:0] s5 = data[21];
    wire signed [31:0] s6 = data[22];
    wire signed [31:0] s7 = data[23];
    wire signed [31:0] t8 = data[24];
    wire signed [31:0] t9 = data[25];
    wire signed [31:0] k0 = data[26];
    wire signed [31:0] k1 = data[27];
    wire signed [31:0] gp = data[28];
    wire signed [31:0] sp = data[29];
    wire signed [31:0] fp = data[30];
    wire signed [31:0] ra = data[31];
endmodule
