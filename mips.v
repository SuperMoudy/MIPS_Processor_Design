`include "AluCont.v"
`include "ControlUnit.v"
`include "Data_Memory.v"
`include "RegFile.v"
`include "instruction_memory.v"

module mips32bit(input clk);
    reg [9:0] pc;  // imem is 256 of 4bytes; the biggest address is 255*4 = 1020
    initial #1 pc <= 0;

    // Instruction Memeory ports:
    wire  [9:0] readAddress = pc;
    wire [31:0] instruction;

    Instruction_Memory imem(
        .Read_Address   (readAddress),
        .Instruction    (instruction)
    );

    // Control output signals:
    wire regDst, branch, memRead, memToReg, memWrite, aluSrc, regWrite;
    wire [1:0] aluOp;

    controlUnit cu(
        .OpCode     (instruction[31:26]),
        .RegDst     (regDst),
        .BranchEq   (branch),
        .MemRead    (memRead),
        .MemtoReg   (memToReg),
        .AluOp      (aluOp),
        .MemWrite   (memWrite),
        .AluSrc     (aluSrc),
        .RegWrite   (regWrite)
    );

    // Register file output signals:
    wire [31:0] readData1;
    wire [31:0] readData2;

    // RegFile write register and write data inputs:
    wire  [4:0] writeReg;
    wire [31:0] writeData;

    RegFile regfile(
        .ReadReg1   (instruction[25:21]),
        .ReadReg2   (instruction[20:16]),
        .WriteReg   (writeReg),
        .WriteData  (writeData),
        .ReadData1  (readData1),
        .ReadData2  (readData2),
        .RegWrite   (regWrite),
        .Clk        (clk)
    );

    // ALU inputs:
    wire [31:0] signextended  = $signed(instruction[15:0]);
    wire [31:0] alu2ndOperand = aluSrc ? signextended : readData2;
    wire  [3:0] opCode;

    // ALU and Data Memory output signals:
    wire [31:0] aluResult;
    wire        zero;
    wire [31:0] readData;
    
    alu_control aluCtrl(
        .ALUOp      (aluOp),
        .FUNCT      (instruction[5:0]),
        .op_code    (opCode)
    );

    ALU alu(
        .read_data1 (readData1),
        .read_data2 (alu2ndOperand),
        .op_code    (opCode),
        .shift_amt  (alu2ndOperand),  // FIXME
        .result     (aluResult),
        .zero       (zero)
    );

    Data_Memory dmem(
        .Address    (aluResult),
        .Write_Data (readData2),
        .MemWrite   (memWrite),
        .MemRead    (memRead),
        .Read_Data  (readData)
    );
    
    assign writeReg  = regDst   ? instruction[15:11] : instruction[20:16];
    assign writeData = memToReg ? readData           : aluResult;

    // updating PC
    always @(posedge clk)
        pc <= (branch & zero)
              ? (pc + 4) + (signextended << 2)
              : (pc + 4)
              ;
endmodule
