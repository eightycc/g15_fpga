# Bendix G-15 FPGA Implementation

Here are the bones of a Bendix G-15 design targeting an FPGA. The goal of this project is to implement a complete Bendix G-15 on an FPGA. In it's present state it can start-up up under simulation through loading the number track and box test loader then running the loader through its message type out. At home I'm using Xilinx (now AMD) Vivado to simulate and synthesize the design, but it should be portable to just about any other FPGA toolchain.

## Source Code

The source code is written in SystemVerilog. I manually captured the Bendix G-15 schematics ([bitsavers.org](http://bitsavers.org/pdf/bendix/g-15/schematics/G15D_Schems.pdf)) giving each drawing its own module and source file.

### Naming Conventions

As much as possible, I've preserved the original G-15 nomenclature. Most signal names are two upper case letters and are unchanged. In some cases, Bendix circled a number, letter, or Greek character to form a signal name. For these cases I've substituted the prefix 'CIR_' for the circle. For the cases that use Greek characters, I've used the English equivalent, i.e., 'ALPHA' for 'α', 'BETA' for 'β', etc.

### Bendix G-15 Component Modules

The G-15's sequential logic is implemented with a clock-edge triggered Set-Reset flip-flop. The `sr_ff` module maps nicely onto the D flip-flops commonly found on FPGAs.

I've substituted shift registers for the G-15's magnetic drum revolvers. The `drum_track` module implements a shift register without parallel load/store capability that maps onto FPGA distributed RAM.

### G-15 Metastability

Since the G-15 uses set-reset flip-flops, metastability can occur when both set and reset are asserted coincident with a positive clock edge. There are a few places where G-15 logic causes this to occur. I've added the necessary terms to prevent metastability for the following cases:

1. During turn-on the `OZ` flip-flop is set and reset simultaneously due to `T0` and `T29` both being asserted for every word time. This is due to the number track being partially initialized but not yet loaded from the phototape reader. The `OZ` reset term is modified:
```
    old:    OZ_r = T29 & OZ;
    new:    OZ_r = T29 & OZ & ~T0;
```

2. G15 Group I ECOs introduce a potential metastability condition when the compute switch is in the neutral position. This occurs during the turn-on sequence when `W107 & TAPE_START` is true resulting in both `CH_s` and `CH_r` being set to 1. Addition of `CZ` to the Group I `CH_s` terms prevents this condition from occurring:
```
    old:    | (W107 & TAPE_START)
    new:    | (W107 & TAPE_START & CZ)
    old:    | (W107 & SW_SA & KEY_F)
    new:    | (W107 & SW_SA & KEY_F & CZ)
```

3. During transfer to a special destination `DS` is asserted. While `DS` is asserted it is also possible for `TS` to be asserted. These conditions result in `FE_s` and `FE_r` being set simultaneously. Modifying the `DS` term of `FE_r` by qualifying with `~TS` prevents this condition:
```
    old:    (DS)
    new:    (DS & ~TS)
```
### License

I've selected a permissive license that covers both software and hardware. ([Solderpad Hardware License v 2.1](https://solderpad.org/licenses/SHL-2.1/)). I'm in it solely for the attribution.