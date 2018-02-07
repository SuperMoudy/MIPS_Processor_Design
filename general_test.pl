#!/usr/bin/env perl
use strict; use warnings;

my %regdata = map { $_ => 0 } (0..31);
my @reg = qw(zero at v0 v1 a0 a1 a2 a3 t0 t1 t2 t3 t4 t5 t6 t7
               s0 s1 s2 s3 s4 s5 s6 s7 t8 t9 k0 k1 gp sp fp ra);
my %reg = map { $_ => $_, $reg[$_] => $_ } (0..31);

# `x => 1` is equiv to `'x', 1` in perl ;)
set(t0 => 8);
set(t1 => 9);
set(t2 => 10);
set(t5 => 40);

run('
    sw $t5, 40($0)
    add $s0, $t0, $t0
    add $s0, $s0, $s0
    lw $s1, 8($s0)
    add $s2, $s1, $s1
    beq $s2, $s1, L
    add $s2, $s2, $t0
L:  add $s2, $s2, $t0
    nop
    nop
    nop
    nop
');

chk(s1 => 40);
chk(s2 => 96);

# test ends here

sub set{
    my ($r, $v) = @_;
    unless (defined $reg{$r}) { warn "ERROR: unknown register $r\n"; exit; }
    $regdata{ $reg{$r} } = $v;
}

sub run {
    my ($instructions) = @_;
    # Registers
    my $regfile = 'registers.hex';
    open REGFILE, ">$regfile" or die $!;
    for my $r (0..31) {
        printf { *REGFILE } "%08x\n", $regdata{$r};
    }
    close REGFILE;
    # Instructions and Assembling
    my $asmfile = ".test.asm";
    my $hexfile = 'instructions.hex';
    # edit the following variable so it matches all the needed files
    my $mipsfiles = '*.v instruction_memory-sim.V RegFile-test.V';
    open ASMFILE, ">$asmfile" or die $!;
    print { *ASMFILE } $instructions;
    close ASMFILE;
    system('sh', '-c', "perl mas.pl '$asmfile' >$hexfile");
    # Running
    my $result = `sh -c 'iverilog $mipsfiles && ./a.out &>/dev/null'`;
    # Cleaning
    unlink $asmfile;
    unlink $hexfile;
    unlink 'a.out';
    # Reading Registers
    open REGFILE, "<$regfile" or die $!;
    my $r = 0;
    while ($r < 32) {
        my $in = <REGFILE>;
        next if ($in =~ m|^//|);
        chomp($in); # remove the newline
        $regdata{$r} = $in;
        ++$r;
    }
    close REGFILE;
    unlink($regfile);
}

sub prn {
    my ($r) = @_;
    unless (defined $reg{$r}) { warn "ERROR: unknown register $r\n"; exit; }
    printf $r . ":\t" . $regdata{ $reg{$r} } . "\n";
}

sub chk {
    my ($r, $v) = @_;
    unless (defined $reg{$r}) { warn "ERROR: unknown register $r\n"; exit; }
    if ($v == hex($regdata{ $reg{$r} })) {
        print "\e[1;32m$r:\t$v\e[m\n";
    } else {
        print "\e[1;31m$r:\tResult: " . hex($regdata{ $reg{$r} })
            ."\tExpected: $v\e[m\n";
    }
}


