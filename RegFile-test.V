module RegFile(
    output reg signed  [31:0] ReadData1, ReadData2,
    input [4:0] ReadReg1, ReadReg2, WriteReg,
    input signed [31:0] WriteData,
    input RegWrite, Clk
    );

    reg signed [31:0] data [31:0];
    always @(negedge Clk)
    begin
       ReadData1 <= ReadReg1 == 0 ? 0 : data[ReadReg1];
       ReadData2 <= ReadReg2 == 0 ? 0 : data[ReadReg2];
    end

    initial $readmemh("registers.hex", data);

    always @(posedge Clk)
      if (RegWrite)
        data[WriteReg] <= WriteData;

    always @(ReadData1)
        if (ReadReg1 === 5'hxx) begin
            $writememh("registers.hex", data);
            $finish;
        end
endmodule

