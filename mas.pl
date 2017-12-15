#!/usr/bin/env perl
use strict; use warnings;
# a MIPS Assembler
# usage: ./mas.pl infile.asm > outfile.hex
# - it outputs to stdout; redirect it to a file if you need so.
# - exactly one file shall be supplied as arg.
#   every line in the input file shall be either an instruction, or a lable,
#   or a labeled instruction, which is a label followed by an instrucion on
#   the same line.
# an instruction shall be one of: add, sw, lw, sll, and, or, beq.
# a lable shall match /[a-zA-Z_][a-zA-Z_0-9]*/ (ie, C-like identifier), 
#   followed directly by a colon.
# License: CC0 (Public Domain)

# definitions:
my $LBL_REGEX = '[a-zA-Z_][a-zA-Z_0-9]*';

# mips registers
my %reg = (
    0=>0, zero=>0,
            at=> 1, v0=> 2, v1=> 3, a0=> 4, a1=> 5, a2=> 6, a3=> 7,
    t0=> 8, t1=> 9, t2=>10, t3=>11, t4=>12, t5=>13, t6=>14, t7=>15,
    s0=>16, s1=>17, s2=>18, s3=>19, s4=>20, s5=>21, s6=>22, s7=>23,
    t8=>24, t9=>25, k0=>26, k1=>27, gp=>28, sp=>29, fp=>30, ra=>31,
);

# the following are dictionaries for the supported instructions of a certain
#  format. they are used for easier detecting of the instruction format.

my %r_instr = (
    nop  => 1,
    add  => 1,
    sub  => 1,
    sll  => 1,
    and  => 1,
    or   => 1,
);

my %i_instr = (
    sw   => 1,
    lw   => 1,
    beq  => 1,
);

my %op = (              # opcode for the instructions
    add  => 0,
    sub  => 0,
    sw   => 43,
    lw   => 35,
    sll  => 0,
    nop  => 0,
    and  => 0,
    or   => 0,
    beq  => 4,
);

my %fn = (              # functcode for R-format instructions, the last field
    add  => 32,
    sub  => 34,
    sll  => 0,
    nop  => 0,
    and  => 36,
    or   => 37,
);

# for easier decoding, these dectionaries are instroducted.

# binary:
# for R-format instructions of the form: INSTR $2, $3, $4
# that is assembled into: OP $3 $4 $2 0 FUNCT
my %binary = (
    add  => 1,
    sub  => 1,
    and  => 1,
    or   => 1,
);

# NOP:
my %nop = ( nop => 1, );
# shift:
# for R-format instructions of the form: INSTR $2, $3, 4
# that is assembled into: OP 0 $3 $2 4 FUNCT
my %shift = (
    sll  => 1,
);

# immediate:
# for I-format instructions of the form: INSTR $2, $3, 4
# that is assembled into: OP $3 $2 4

# loadstore:
# for I-format instructions of the form: INSTR $2, 3($4)
# that is assembled into: OP $4 $2 3
my %loadstore = (
    lw   => 1,
    sw   => 1,
);

# binary branch:
# for I-format instructions of the form: INSTR $2, $3, LBL
# that is assembled into: OP $2 $3 OFFSET_OF_LBL
my %binary_branch = (
    beq  => 1,
);

# global vars

my $line_number = 0;

my %lables = ();        # store the line number of a lable with it

# main
open INFILE, "<$ARGV[0]" or die $!;

# 1st pass: detect all labels
$line_number = 0;
while (<INFILE>) {
    ++$line_number;     # line numbering starts from 1
    chomp;              # trim leading and trailing spaces 
    if (/([a-zA-Z_][a-zA-Z_0-9]*):/) {
        if (exists $lables{$1}) { warn "WARNING: redefining lable ``$1''\n"; }
        #$lables{$l} = (/:\s*.*/) ? $line_number : $line_number + 1;
        $lables{$1} = $line_number;
    }
}

# 2nd pass: assembling
seek INFILE, 0, 0;      # seek to the 1st byte of the file
$line_number = 0;
while (<INFILE>) {
    ++$line_number;     # line numbering starts from 1
    chomp;              # trim leading and trailing spaces 
    next if /^$/;       # ignore empty lines
    print assemble($_); # convert to instructions to hex
}

close INFILE;

# functions definition

# given an instruction as string, returns it assembled in hex as string.
# it returns zeros (nop) for invalid instructions.
# and returns nothing for lables.
sub assemble {
    my $i = shift;
    ($i) = $i =~ /(?:$LBL_REGEX:)? \s* (.*)/x;
    return if $i eq "";
    my ($instr_name) = $i =~ /(\S+)/;
    if      (exists $r_instr{$instr_name}) {
        assemble_r($i);
    } elsif (exists $i_instr{$instr_name}) {
        assemble_i($i);
    } else {
        warn "WARNING: unrecognized instruction ``$1'' at line $line_number\n";
        return sprintf "%08x\n", 0; # nop
   }
}

# given an R-format instruction as a string, returns its hex representation
sub assemble_r {
    # R-format:  | op (6) | rs (5) | rt (5) | rd (5) | sa (5) | fn (6) |
    my $i = shift;
    my ($instr_name) = $i =~ /(\S+)/;
    if (exists $binary{$instr_name}) {
        $i =~ /(\S+) \s+ \$([a-z0-9]+) \s*, \s*
                         \$([a-z0-9]+) \s*, \s*
                         \$([a-z0-9]+)/x;
        my $hex = $op{$1}  << 26 |
                  $reg{$3} << 21 |
                  $reg{$4} << 16 |
                  $reg{$2} << 11 |
                  $fn{$1};
        return sprintf "%08x\n", $hex;
    } elsif (exists $shift{$instr_name}) {
        $i =~ /(\S+) \s+ \$([a-z0-9]+) \s*, \s*
                         \$([a-z0-9]+) \s*, \s*
                         ([0-9]+)/x;
        my $hex = $op{$1}  << 26 |
                  $reg{$3} << 16 |
                  $reg{$2} << 11 |
                  $4       <<  6 |
                  $fn{$1};
        return sprintf "%08x\n", $hex;
    } elsif (exists $nop{$instr_name}) {
        return sprintf "%08x\n", 0;
    } else {
        warn "WARNING: the impossible happend "
            ."for instruction ``$1'' at line $line_number in asemble_r()\n";
        return sprintf "%08x\n", 0; # nop
    }
}

sub assemble_i {
    # I-format:  | op (6) | rs (5) | rt (5) |     immediate (16)       |
    my $i = shift;
    my ($instr_name) = $i =~ /(\S+)/;
    if (exists $loadstore{$instr_name}) {
        $i =~ /(\S+) \s+ \$([a-z0-9]+) \s*, \s*
                         (-?[0-9]+) \s*
                         \( \s* \$([a-z0-9]+) \s* \)/x;
        my $hex = $op{$1}  << 26 |
                  $reg{$4} << 21 |
                  $reg{$2} << 16 |
                  $3 & 0xffff;
        return sprintf "%08x\n", $hex;
    } elsif (exists $binary_branch{$instr_name}) {
        $i =~ /(\S+) \s+ \$([a-z0-9]+) \s*, \s*
                         \$([a-z0-9]+) \s*, \s*
                         ([a-zA-Z_][a-zA-Z_0-9]*)/x;
        my $hex = $op{$1}  << 26 |
                  $reg{$2} << 21 |
                  $reg{$3} << 16 |
                  $lables{$4}-$line_number-1 & 0xffff;
        return sprintf "%08x\n", $hex;
    } else {
        warn "WARNING: the impossible happend "
            ."for instruction ``$1'' at line $line_number in asemble_i()\n";
        return sprintf "%08x\n", 0; # nop
    }
}

