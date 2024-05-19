# Bendix G-15 FPGA Implementation

Here are the bare bones of a Bendix G-15 design targeting an FPGA. The goal of this project is to implement a complete Bendix G-15 on an FPGA. In it's present state it can start-up up under simulation through loading the number track. At home I'm using Xilinx (now AMD) Vivado to simulate and synthesize the design, but it should be portable to just about any other FPGA toolchain.

## Source Code

The source code is written in SystemVerilog. I manually captured the Bendix G-15 schematics ([bitsavers.org](http://bitsavers.org/pdf/bendix/g-15/schematics/G15D_Schems.pdf)) giving each drawing its own module and source file.

### Naming Conventions

As much as possible, I've preserved the original G-15 nomenclature. Most signal names are two upper case letters and are unchanged. In some cases, Bendix circled a number, letter, or Greek character to form a signal name. For these cases I've substituted the prefix 'CIR_' for the circle. For the cases that use Greek characters, I've used the English equivalent, i.e., 'ALPHA' for 'α', 'BETA' for 'β', etc.

### Bendix G-15 Component Modules

The G-15's sequential logic is implemented with a clock-edge triggered Set-Reset flip-flop. The `sr_ff` module maps nicely onto the D flip-flops commonly found on FPGAs.

I've substituted shift registers for the G-15's magnetic drum revolvers. The `drum_track` module implements a shift register without parallel load/store capability that maps onto FPGA distributed RAM.

### License

I've selected a permissive license that covers both software and hardware. ([Solderpad Hardware License v 2.1](https://solderpad.org/licenses/SHL-2.1/)). I'm in it solely for the attribution.