#!/usr/bin/env perl
use strict; use warnings;
# a MIPS Assembler
# usage: ./mas.pl infile.asm > outfile.hex
# - it outputs to stdout; redirect it to a file if you need so.
# - exactly one file shall be supplied as arg.
#   every line in the input file shall be either an instruction, a comment,
#   an empty line (has spaces only), or a labeled instruction, which is a label
#   followed by an instrucion on the same line. Lable-only lines are NOT well
#   supported.
# an instruction shall exist in %r_instr or %i_instr.
# a lable shall match /[a-zA-Z_][a-zA-Z_0-9]*/ (ie, C-like identifier),
#   followed by a colon.
# License: CC0 (Public Domain)
# See the following page for updates:
# https://gist.github.com/noureddin/3c4e6eb3798fcd6388873b10d0c8fa96

sub make_hash_from_keys { return map { $_ => undef } @_ }

# definitions:
my $LBL_REGEX = '[a-zA-Z_][a-zA-Z_0-9]*';

# mips registers
my @reg = qw(zero at v0 v1 a0 a1 a2 a3 t0 t1 t2 t3 t4 t5 t6 t7
               s0 s1 s2 s3 s4 s5 s6 s7 t8 t9 k0 k1 gp sp fp ra);
my %reg = map { $_ => $_, $reg[$_] => $_ } (0..31);

# the following are dictionaries for the supported instructions of a certain
#  format. they are used for easier detecting of the instruction format.

my %r_instr = make_hash_from_keys(qw[ nop add sub sll and or ]);

my %i_instr = make_hash_from_keys(qw[ sw lw beq ]);

# opcode for the instructions
my %op = map { $_ => 0 } qw[ add sub sll nop and or ];
$op{sw} = 43;
$op{lw} = 35;
$op{beq} = 4;

# functcode for R-format instructions, the last field
my %fn = (
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
my %binary = make_hash_from_keys(qw[ add sub and or ]);

# NOP:
my %nop = make_hash_from_keys(qw[ nop ]);

# shift:
# for R-format instructions of the form: INSTR $2, $3, 4
# that is assembled into: OP 0 $3 $2 4 FUNCT
my %shift = make_hash_from_keys(qw[ sll ]);

# immediate:
# for I-format instructions of the form: INSTR $2, $3, 4
# that is assembled into: OP $3 $2 4
my %immediate = make_hash_from_keys(qw[ ]);

# loadstore:
# for I-format instructions of the form: INSTR $2, 3($4)
# that is assembled into: OP $4 $2 3
my %loadstore = make_hash_from_keys(qw[ lw sw ]);

# binary branch:
# for I-format instructions of the form: INSTR $2, $3, LBL
# that is assembled into: OP $2 $3 OFFSET_OF_LBL
my %binary_branch = make_hash_from_keys(qw[ beq ]);

# global vars

my $line_number = 0;

my %lables = ();        # store the line number of a lable with it

# main
open INFILE, "<$ARGV[0]" or die $!;

# 1st pass: detect all labels
$line_number = 0;
while (<INFILE>) {
    ++$line_number;     # line numbering starts from 1
    chomp;              # trim trailing newline
    next if /^\s*$/;    # ignore empty lines
    if (/\s*($LBL_REGEX)\s*:/) {
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
    chomp;              # trim trailing newline
    next if /^\s*$/;    # ignore empty lines
    next if /^\s*#/;    # ignore comments
    print assemble($_); # convert to instructions to hex
}

close INFILE;

# functions definition

# given an instruction as string, returns it assembled in hex as string.
# it returns zeros (nop) for invalid instructions.
# and returns nothing for lables.
sub assemble {
    my $i = shift;
    ($i) = $i =~ /\s* (?: $LBL_REGEX \s* :)? \s* (.*) \s*/x;
    return if $i =~ /^\s*$/;
    my ($instr_name) = $i =~ /(\S+)/;
    if      (exists $r_instr{$instr_name}) {
        assemble_r($i, $instr_name);
    } elsif (exists $i_instr{$instr_name}) {
        assemble_i($i, $instr_name);
    } else {
        warn "WARNING: unrecognized instruction ``$1'' at line $line_number\n";
        return sprintf "%08x\n", 0; # nop
   }
}

# given an R-format instruction as a string, returns its hex representation
sub assemble_r {
    # R-format:  | op (6) | rs (5) | rt (5) | rd (5) | sa (5) | fn (6) |
    #              31  26   25  21   20  16   15  11   10   6   5    0
    my ($i, $instr_name) = @_;
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
            ."for instruction ``$1'' at line $line_number in assemble_r()\n";
        return sprintf "%08x\n", 0; # nop
    }
}

sub assemble_i {
    # I-format:  | op (6) | rs (5) | rt (5) |     immediate (16)       |
    #              31  26   25  21   20  16   15                     0
    my ($i, $instr_name) = @_;
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
            ."for instruction ``$1'' at line $line_number in assemble_i()\n";
        return sprintf "%08x\n", 0; # nop
    }
}

