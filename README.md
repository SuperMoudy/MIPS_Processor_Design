# 5-Stage Pipelined MIPS Processor in Verilog

This is the sent and graded version of the code.

This project was a computer engineering school project. It's here for historic
purposes only.

It's synthesizable but because the `top_mod` has no inputs or outputs it's not.

The files ending in `-sim.V` are for simulation.  
The files ending in `-synth.V` are for synthesization.  
The files ending in `-test.V` are for `general` testing.

It comes with an assembler (`mas.pl`) and two testing scripts
(`predefined_test.pl` and `general_test.pl`), all in Perl.

This following are some thoughts about them, particularly `mas.pl` and `general_test.pl`:

- The supported functions in the processor and assembler are

      nop  add  sub  sll  and  or  sw  lw  beq


- Labeled instructions are supported in the assembler, but label-only lines
  are not well supported yet.

  This produces the correct hex:

  ```verilog
      beq $s0, $s1, L
      ...
      L: add $s0, $t0, $t1
  ```

  But this won't give the correct hex yet:

  ```verilog
      beq $s0, $s1, L
      ...
      L:
      add $s0, $t0, $t1
  ```


- The assembler ignores anything after a valid statement in the same line.

  This:

      nop means no operation :P

  is correctly and silently assembled into

      00000000


- A line that consists only of white spaces, or starts with a `#` (optionally
  after white spaces), is ignored as if it weren't present in the source file.


- White spaces are insignificant most of the time.


- The test script and assembler accept registers by name or number (in decimal).

  This is valid:

      add $16, $1, $0

  and is equivalent to:

      add $s0, $at, $zero

  Similarly, in the `general` test, both of the following are equivalent:

  ```perl
      set(t0 => 1);
      set(8  => 1);
  ```


- Our MIPS ends the simulation once an instruction of `x`s enters the decoding
  stage. So we need to wait four cycles so that all instructions are complete;
  hence we need four `nop` at the end of every test.


- In `general_test.pl`, you can initialize registers with `set()`:

  ```perl
      set(t1 => 1);  # sets $t1 to 1
  ```

  Please note that there is no `$` there.

  Due to Perl syntax, the above line is equivalent to this:

  ```perl
      set('t1', 1);
  ```

  But I prefer the first. :)

  After that, pass the instructions as a multiline string to `run()`, then
  print any registers you like using `prn()` (prints them in hexadecimal) or
  check them using `chk()` against numbers in any base. All of the following
  are equivalent:

  ```perl
      chk(t0 => 16);      # decimal
      chk(t0 => 0x10);    # hexadecimal
      chk(t0 => 0b10000); # binary
      chk(t0 => 020);     # who uses octal deliberately anyway?
  ```

  If the check succeeds, it prints the register name and its value in green;
  otherwise it prints the name, the result, and the expectation, all in red
  (try it yourself!).

---

We should have made and used *isolated tests* as our primarily test, and used
*integrated tests* as complimentary. But because the code was badly organized,
badly tested, and the deadline was so close, we chose to go with the integrated
tests only, and make the code Just Works™. We regretted that decision; the code
became so unmaintainable that when we needed to do some additional stalls, we
did them in the instruction memory.

---

## License:

The Perl scripts are in public domain (CC0).
The Verilog code is under the terms of MIT; see [LICENSE](https://github.com/SuperMoody/MIPS_Processor_Design/blob/master/LICENSE).

