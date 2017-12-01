`include "mips.v"

module mips_tb;
    reg clk = 1;
    always #5 clk = ~clk;

    mips32bit mips(clk);
    initial #1000 $finish;
    initial begin  // for waveform
        $dumpfile("mips.vcd");
        $dumpvars;
    end
endmodule
