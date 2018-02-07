#!/usr/bin/env perl
# MIPS test suite

# We assemble several assembly tests into `instructions.hex` file, which is
# loaded by our Verilog MIPS implementation's simulation. We then run the
# simulation, which on finishing prints the values of $s0 and $s1.

# each function call is a string representing the test name, then a multiline
# string representing the instructions, then the expected values of $s0 and $s1.

# `$0` is always zero, and `$1` (`$at`) is initialized to one.

# Our MIPS ends the simulation once an instruction of `x`s enters the decoding
# stage. So we need to wait four cycles so that all instructions are complete;
# hence the four `nop` at the end of every test.

test("independant add 1", '
    add $s0, $0, $1
    add $s1, $0, $1
    nop
    nop
    nop
    nop
    ', 1, 1);

test("independant add 2", '
    add $s0, $1, $1
    add $s0, $s0, $s0
    add $s0, $s0, $s0
    add $s0, $s0, $s0
    add $s1, $s0, $s0
    nop
    nop
    nop
    nop
    ', 16, 32);

test("independant sub", '
    sub $s0, $0, $1
    sub $s1, $1, $0
    nop
    nop
    nop
    nop
    ', -1, 1);

test("independant sll", '
    sll $s0, $1, 1
    sll $s1, $1, 12
    nop
    nop
    nop
    nop
    ', 2, 4096);

test("independant and 1", '
    and $s0, $0, $1
    and $s1, $1, $0
    and $s2, $0, $1
    nop
    nop
    nop
    nop
    ', 0, 0);

test("independant and 2", '
    and $s0, $0, $0
    and $s1, $1, $1
    nop
    nop
    nop
    nop
    ', 0, 1);

test("independant or 1", '
    or $s0, $0, $1
    or $s1, $1, $0
    nop
    nop
    nop
    nop
    ', 1, 1);

test("independant or 2", '
    or $s0, $0, $0
    or $s1, $1, $1
    nop
    nop
    nop
    nop
    ', 0, 1);

test("dependant on branch taken", '
    add $s0, $1, $0
    add $s1, $1, $0
    beq $s0, $s1, L
    add $s0, $s1, $s0
L:  sub $s1, $s1, $s0
    nop
    nop
    nop
    nop
    ', 1, 0);

test("dependant on branch not taken", '
    add $s0, $1, $0
    add $s1, $1, $1
    beq $s0, $s1, L
    add $s0, $s1, $s0
L:  sub $s1, $s1, $s0
    nop
    nop
    nop
    nop
    ', 3, -1);

test("independant load and store", '
    add $s0, $1, $1
    add $s1, $0, $1
    sw $s0, 1($1)
    lw $s1, 1($1)
    nop
    nop
    nop
    nop
    ', 2, 2);

test("dependant sw then lw then sw then lw", '
    add $s0, $1, $1
    add $s1, $0, $1
    sw $s0, 1($1)
    lw $s1, 0($s0)
    sw $s1, 0($s1)
    lw $s0, 0($s1)
    add $s0, $s0, $1
    nop
    nop
    nop
    nop
    ', 3, 2);

test("forward A 1", '
    add $s0, $0, $1
    add $s1, $s0, $1
    nop
    nop
    nop
    nop
    ', 1, 2);

test("forward A 2", '
    add $t0, $0, $1
    add $s0, $t0, $1
    sub $s1, $t0, $1
    nop
    nop
    nop
    nop
    ', 2, 0);

test("forward B", '
    add $t0, $0, $1
    add $s0, $1, $t0
    sub $s1, $1, $t0
    nop
    nop
    nop
    nop
    ', 2, 0);

test("add then sw; and lw then add", '
    add $t0, $1, $1
    sw $t0, 4($0)
    lw $s0, 4($0)
    add $s1, $1, $s0
    nop
    nop
    nop
    nop
    ', 2, 3);

test("add then lw then add", '
    add $t0, $1, $1
    sw $t0, 4($0)
    add $t0, $1, $1
    lw $s0, 2($t0)
    add $s1, $1, $s0
    nop
    nop
    nop
    nop
    ', 2, 3);

test("add then sw then add then lw then add", '
    add $t0, $1, $1
    sw $t0, 4($0)
    add $t0, $1, $t0
    lw $s0, 1($t0)
    add $s1, $t0, $s0
    nop
    nop
    nop
    nop
    ', 2, 5);

test("beq taken then lw", '
    sw $1, 4($0)
    beq $1, $1, L
    lw $s0, 4($0)
L:  nop
    nop
    nop
    nop
    ', 'x', 'x');

test("beq not taken then lw", '
    sw $1, 4($0)
    beq $1, $0, L
    lw $s0, 4($0)
L:  nop
    nop
    nop
    nop
    ', 1, 'x');

test("beq taken then sw", '
    add $s0, $1, $1
    beq $1, $1, L
    sw $s0, 4($0)
    lw $s1, 4($0)
L:  nop
    nop
    nop
    nop
    ', 2, 'x');

test("beq not taken then sw", '
    add $s0, $1, $1
    beq $1, $0, L
    sw $s0, 4($0)
    lw $s1, 4($0)
L:  nop
    nop
    nop
    nop
    ', 2, 2);

sub test {
    # read function arguments
    my ($name, $instructions, $expected_s0, $expected_s1) = @_;
    my $asmfile = ".$name.test.asm";
    my $hexfile = 'instructions.hex';
    # write asm to a file
    my $mipsfile = '*.v *-sim.V'; # change this to match all needed files
    open ASMFILE, ">$asmfile" or die $!;
    print { *ASMFILE } $instructions;
    close ASMFILE;
    # assemble
    system('sh', '-c', "perl mas.pl '$asmfile' >$hexfile");
    # compile, simulate, and run
    my $result = `sh -c 'iverilog $mipsfile && ./a.out | grep ^T'`;
    # check the result; here be dragons
    chomp $result;
    my ($result_s0, $result_s1) = $result =~ /T:\s*([-0-9Xx]+)\s*([-0-9Xx]+)\s*/;
    my $res_eq_exp = (($result_s0 eq $expected_s0) and ($result_s1 eq $expected_s1));
    print(($res_eq_exp ? "\e[1;32m" : "\e[1;31m") . "$name\e[m\n");
    unless ($res_eq_exp) {
        # print "$result\n";
        print "RESULTED\tEXPECTED\n--------\t--------\n";
        print "$result_s0\t\t$expected_s0\n$result_s1\t\t$expected_s1\n";
        print "--------\t--------\n";
    }
    #print " \e[34$result\e[m\n\e[35m$expected\e[m\n";
    # clean
    unlink $asmfile;
    unlink $hexfile;
    unlink 'a.out';
}
