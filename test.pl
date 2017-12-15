#!/usr/bin/env perl
# MIPS test suite

# We assemble several assembly tests into `instructions.hex` file, which is
# loaded by our Verilog MIPS implementation's simulation. We then run the
# simulation, which on finishing prints the values of $s0 and $s1.

test("independant add", '
add $s0, $0, $at
add $s1, $0, $at
nop
nop
nop
nop
', '1', '1');

test("independant sub", '
sub $s0, $0, $at
sub $s1, $at, $0
nop
nop
nop
nop
', '-1', '1');

test("independant sll", '
sll $s0, $at, 1
sll $s1, $at, 12
nop
nop
nop
nop
', '2', 4096);

test("independant and 1", '
and $s0, $0, $at
and $s1, $at, $0
and $s2, $0, $at
nop
nop
nop
nop
', '0', '0');

test("independant and 2", '
and $s0, $0, $0
and $s1, $at, $at
nop
nop
nop
nop
', '0', '1');

test("independant or 1", '
or $s0, $0, $at
or $s1, $at, $0
nop
nop
nop
nop
', '1', '1');

test("independant or 2", '
or $s0, $0, $0
or $s1, $at, $at
nop
nop
nop
nop
', '0', '1');

test("independant branch", '
add $t1, $at, $0
add $s0, $at, $at
add $t9, $0, $0
add $t9, $0, $0
add $t9, $0, $0
add $t9, $0, $0
add $t9, $0, $0
add $t9, $0, $0
beq $t1, $at, L1
add $s0, $0, $0
add $t9, $0, $0
beq $at, $at, L2
add $t9, $0, $0
add $t9, $0, $0
add $t9, $0, $0
L1: add $s0, $at, $at
L2: or $t8, $0, $0
', '2', 'x');

test("load and store", '
    add $s0, $at, $at
    add $s1, $0, $at
    nop
    nop
    sw $s0, 1($at)
    lw $s1, 1($at)
    nop
    nop
    nop
    nop
', '2', '2');

test("forward A 1", '
add $s0, $0, $at
add $s1, $s0, $at
nop
nop
nop
nop
', 1, 2);

test("forward A 2", '
add $t0, $0, $at
add $s0, $t0, $at
sub $s1, $t0, $at
nop
nop
nop
nop
nop
', 2, 0);

test("forward B", '
add $t0, $0, $at
add $s0, $at, $t0
sub $s1, $at, $t0
nop
nop
nop
nop
nop
', 2, 0);

test("stall", '
add $t0, $at, $at
nop
nop
nop
nop
sw $t0, 4($0)
lw $s0, 4($0)
add $s1, $at, $s0
nop
nop
nop
nop
', 2, 3);

sub test {
    my ($name, $instructions, $expected_s0, $expected_s1) = @_;
    my $asmfile = ".$name.test.asm";
    my $hexfile = 'instructions.hex';
    my $mipsfile = '*.v';
    open ASMFILE, ">$asmfile" or die $!;
    print { *ASMFILE } $instructions;
    close ASMFILE;
    system('sh', '-c', "perl mas.pl '$asmfile' >$hexfile");
    my $result = `sh -c 'iverilog $mipsfile && ./a.out | grep ^T'`;
    chomp $result;
    my ($result_s0, $result_s1) = $result =~ /T:\s*([-0-9Xx]+)\s*([-0-9Xx]+)\s*/;
    my $res_eq_exp = (($result_s0 eq $expected_s0) and ($result_s1 eq $expected_s1));
    print "$name: " . ($res_eq_exp ? "\e[1;32m1\e[m\n" : "\e[1;31m0\e[m\n");
    unless ($res_eq_exp) {
        print "$result\n";
        print "$result_s0\t$expected_s0\n$result_s1\t$expected_s1\n";
    }
    #print " \e[34$result\e[m\n\e[35m$expected\e[m\n";
    unlink $asmfile;
    unlink $hexfile;
    unlink 'a.out';
}
