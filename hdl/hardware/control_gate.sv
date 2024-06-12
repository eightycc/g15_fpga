// ----------------------------------------------------------------------------
// Copyright 2024 Robert E. Abeles
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Licensed under the Solderpad Hardware License v 2.1 (the "License");
// you may not use this file except in compliance with the License, or, at
// your option, the Apache License, Version 2.0. You may obtain a copy of
// the License at: https://solderpad.org/licenses/SHL-2.1/
//
// Unless required by applicable law or agreed to in writing, any work
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// Bendix G-15 Control Gate 1 & 2 (Page 7, 3D593)
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

module control_gate (
    input logic rst,
    input logic CLOCK,
    
    // Typewriter Switches
    input logic SW_GO,     // <GO>
    input logic SW_NO_GO,  // <NO_GO>        
    input logic SW_BP,     // <BP>
    input logic SW_PUNCH,  // <MANUAL PUN>
    input logic SW_SA,     // <SA>
    
    // Typewriter Keys
    input logic KEY_F,     // <F> Set N = 00
    input logic KEY_I,     // <I> Execute One Command
    input logic KEY_M,
    input logic KEY_R,     // <R> Return to Marked Place
    
    // Maintenance Panel Keys
    input logic MP_CLR_NT,
    input logic MP_SET_OP,
    input logic MP_SET_NT,
    
    // Turn-on Cycle Controls
    input logic PWR_CLEAR,    // <CLEAR>
    input logic PWR_NO_CLEAR, // <NO_CLEAR>
    input logic PWR_OP,       // <OP>
    input logic PWR_NO_OP,    // <NO_OP>
    input logic PWR_NT,       // <NT>
    
    // Card Adapter
    input logic CRP_CQ_s,
    
    // DA-1
    input logic GO,
    
    input logic PL19_READY_IN, PL20_READY_OUT, READY,
    input logic TAPE_START,
    
    input logic AC_s,
    input logic AR,
    
    input logic DS,
    input logic FO,
    
    input logic LB,
    input logic M0,
    input logic M19,
    input logic MC_not,
    input logic PM,
    
    input logic CIR_1, CIR_2, CIR_3, CIR_4,
    
    input logic C1,
    
    input logic D6, D7, DX,
    
    input logic S4, S5, S6, S7, SU, SV, SW, SX,
    
    input logic T0,
    input logic T1,
    input logic T2,
    input logic T13,
    input logic T21,
    input logic T28,
    input logic T29,
    input logic TF,
    
    output logic KEY_MARK,
    output logic KEY_RETURN,
    output logic CC,
    output logic CE,
    output logic CF,
    output logic CG,
    output logic CH,
    output logic CI,
    output logic CJ,
    output logic CM,
    output logic CN,
    output logic CQ,
    output logic RC,
    output logic TR,
    output logic TR_r
    );
    
    // Flip-flops
    //   CC Command Register Carry
    //   CE Even word time
    //   CF
    //   CG Next command from AR control
    //   CH Start/Stop halt
    //   CJ Read command control
    //   CK
    //   CL
    //   CQ Read next command from WT = N+1
    //   CT
    //     S: (T1 & CN) | (T2 & RC)
    //     R: T28 | (T21 & S6 & DX & D7 & (CL | CK))
    //   CY
    //   CZ Start/Stop
    
    // Signals local to this module
    logic CA;
    logic CB;
    logic CC_s, CC_r;
    logic CD;
    logic CE_s, CE_r; 
    logic CF_s, CF_r;
    logic CG_s, CG_r;
    logic CH_s, CH_r;
    logic CJ_s, CJ_r;
    logic CK, CK_s, CK_r;
    logic CL, CL_s, CL_r;
    logic CM_in;
    logic CN_in, CN_CLR, CN_NT;
    logic CQ_s, CQ_r;
    logic CT, CT_s, CT_r;
    logic CU;
    logic CY, CY_s, CY_r;
    logic CZ, CZ_s, CZ_r;
    logic W107;
    
    // ---------------------------------------------------------------------------------
    // Key Switch Inputs
    // ---------------------------------------------------------------------------------
    always_comb begin
      W107 = CT | (T1 & CN) | T0;
      KEY_MARK = SW_SA & W107 & KEY_M;
      KEY_RETURN = SW_SA & W107 & KEY_R;
    end
    
    // ---------------------------------------------------------------------------------
    // Operating States:
    //      RCnWT WRC TR WTR RC
    //   CK   1    0   0  1   1
    //   CL   0    0   1  1   0
    //   CQ   1    x   x  x   0
    //
    //   RCnWT: Read Command Next Word Time
    //   WRC:    Wait to Read Command
    //   TR:     Transfer
    //   WTR:    Wait to Transfer
    //   RC:     Read Command
    // ---------------------------------------------------------------------------------
    always_comb begin
      // Decode RC (Read Command) and TR (TRansfer) states
      RC = ~CL & CK & ~CQ;     // Read Command
      TR = CL & ~CK;           // TRansfer or Wait to TRansfer

      // TR_r: TR state conclusion (stop TR, start RC)
      TR_r =   (T29 & TR & CC)                     // immediate transfer (OP 29 == 1)
             | (T29 & TR & CM & ~C1)               // deferred single transfer
             | (T29 & TR & CM & ~CE)               // deferred double transfer
             | (T29 & DS & SV & S5);               // EXIT

      // CG: Next command from AR control
      CG_s =   (DS & S7 & SX & CIR_4);             // next command from AR

      CG_r =   (RC & T29)
             | (W107 & SW_SA & KEY_F)              // Set N = 00
             | (W107 & TAPE_START)
             | (PWR_OP);

      // CQ: Conditional Read Next Command
      CQ_s =   (DS & S4 & SV & CIR_1 & SW_PUNCH)   // test manual punch switch
             | (DS & S5 & SW & CIR_4 & T1 & AR)    // test AR sign
             | (D6 & DX & LB)                      // test LB == 0
             | (DS & S7 & SV & FO)                 // test overflow (FO flip-flop)
             | (CRP_CQ_s)                          // test card read/punch
             | (DS & S7 & SU & CIR_1 & PL19_READY_IN)   // test accessory READY_IN
             | (DS & S7 & SU & CIR_2 & PL20_READY_OUT)  // test accessory READY_OUT
             | (DS & S7 & SU & CIR_3 & ~GO)        // test DA-1 GO
             | (DS & S7 & SU & CIR_4 & READY);     // test I/O section READY
    
      CQ_r =   (T29 & CK & ~CL)                    // reset at end of RC
             | (PWR_CLEAR)
             | (W107 & SW_SA & KEY_F)              // Set N = 00
             | (W107 & TAPE_START);                // phototape start

      // CI: Complimented command input
      CI = ~(  (KEY_RETURN & ~M0)
             | (RC & ~CG & MC_not)                 // Read command from M line
             | (RC & CG & ~AR)                     // Read command from AR
             | (W107 & SW_SA & KEY_F)              // Block CI, set N = 00
             | (W107 & TAPE_START) );              // Block CI
    
      // CJ: True during static portion command during RC cycle
      //     Gates CK 'start RC' during cycle prior to RC
      CJ_s =   (T21 & CC & ~CK & ~CH & CZ)         // WRC->RC next cycle
             | (T1 & DS & S5 & SV)                 // MARK EXIT
             | (T13 & CC & ~CJ & DS & S5 & SU);    // RETURN EXIT

      CJ_r =   (T13 & TR & CJ)                     // T13 of TR cycle
             | (T13 & ~CQ & CJ);                   // T13 of RC cycle

      // CK == 0: Start TR
      // CK == 1: Start RC
      CK_s =   (TR_r & CJ)
             | (T29 & CJ & ~CK & ~CL);             // WRC->RC

      CK_r =   (T29 & ~CI & RC)                    // WTR->TR immediate
             | (T29 & CL & CK & CC);               // WTR->TR deferred

      // CL == 0: Stop TR
      // CL == 1: Stop RC
      CL_s = T29 & RC;                             // Stop RC
      CL_r =   (DS & S6 & SX & PM)                 // end NORMALIZE MQ
             | (DS & S6 & SW & T29 & ~CE & AC_s)   // end SHIFT MQ and ID
             | (TR_r);
    end
        

    // ---------------------------------------------------------------------------------
    // Number track and associated logic
    // ---------------------------------------------------------------------------------
    always_comb begin
      // CE: Even word time when enabled by CY. Synchronizes with CN track index.
      CE_s = T29 & CY & ~CE;
      CE_r = T29 & CN & CE;
    
      // CF: Second doubleword of 4-word block
      CF_s = T29 & ~CF & ~CE & CN;
      CF_r = TF;
    
      // CY: Number track initialization control
      CY_s = PWR_NO_OP & ~MP_SET_OP;
      CY_r = PWR_OP | MP_SET_OP;
    
      CN_CLR = ~PWR_NO_CLEAR | MP_CLR_NT;
      CN_NT = PWR_NT | MP_SET_NT;
      CN_in =   (CN_NT & M19)             // copy M19 to NT
              | (~CN_CLR & CY & CN)       // normal NT recirculation
              | (~CN_CLR & ~CE & CN)      // temporary NT recirculation
              | (~CY & ~CN & CE & T29);   // write 1's to NT words 0 to 106 bit 29
    end

    // ---------------------------------------------------------------------------------
    // Start-stop system
    // ---------------------------------------------------------------------------------
    always_comb begin
      CH_s =   (SW_BP & T21 & RC & CI)    // breakpoint
             | (SW_NO_GO & RC)            // single-cycle
             | (W107 & SW_SA & KEY_F)     // set N = 00
             | (W107 & TAPE_START)        // phototape start
             | (DS & S4 & SU);            // HALT
      CH_r = ~CZ;
    
      CZ_s = ~CZ & (SW_GO | (SW_SA & KEY_I)) & T0;
      CZ_r = CZ & ~(SW_GO | (SW_SA & KEY_I)) & T0;
    end
    
    // ---------------------------------------------------------------------------------
    // Command Register Track, Adder, and Associated Logic
    // ---------------------------------------------------------------------------------
    always_comb begin
      //  CU augend
      CU =   (CM & ~(   (DS & S5 & SV & CJ)  // Mark Exit
                      | (RC & ~CJ)
                      | (KEY_RETURN))) 
           | (~CJ & ~CI);                    // Load dynamic portion of command
      
      //  CD addend
      CD = CT & CN;
    
      //  CA sum
      CA =   (~CC & ~CD &  CU)
           | (~CC &  CD & ~CU)
           | ( CC & ~CD & ~CU)
           | ( CC &  CD &  CU);
    
      //  CB carry out
      CB = CU & CT & CN;
    
      //  CC flip-flop: adder carry flag
      CC_s =   T1 | T13 | T21 | CB;
      CC_r = ~T1 & ~T13 & ~T21 & ~CU & ~CD;
    
      //  CT flip-flop: select addend bits from Number Track
      CT_s =   (T1 & CN)   // start selection at bit 2 for word 107
             | (T2 & RC);  // start selection at bit 3 for all others during RC
      CT_r =   (T28)         // end selection at bit 29
             | (T21 & S6 & DX & D7 & (CL | CK));  // or bit 22 for Multiply,
                                                       // DIVIDE, SHIFT, NORMALIZE
                                                       // during TR, WTR, RC
    
      //  Block possible 1 bit entering bit 29 during Read Command:
      //    (~CK | CL | CQ | ~T29) by DeMorgan's is ~(CK & ~CL & ~CQ & T29) or ~(T29 & RC)
      CM_in = CA & (~CK | CL | CQ | ~T29);
    end

    sr_ff ff_CC ( .clk(CLOCK), .rst(rst), .s(CC_s), .r(CC_r), .q(CC) );
    sr_ff ff_CE ( .clk(CLOCK), .rst(rst), .s(CE_s), .r(CE_r), .q(CE) );
    sr_ff ff_CF ( .clk(CLOCK), .rst(rst), .s(CF_s), .r(CF_r), .q(CF) );
    sr_ff ff_CG ( .clk(CLOCK), .rst(rst), .s(CG_s), .r(CG_r), .q(CG) );
    sr_ff ff_CH ( .clk(CLOCK), .rst(rst), .s(CH_s), .r(CH_r), .q(CH) );
    sr_ff ff_CJ ( .clk(CLOCK), .rst(rst), .s(CJ_s), .r(CJ_r), .q(CJ) );
    sr_ff ff_CK ( .clk(CLOCK), .rst(rst), .s(CK_s), .r(CK_r), .q(CK) );
    sr_ff ff_CL ( .clk(CLOCK), .rst(rst), .s(CL_s), .r(CL_r), .q(CL) );
    sr_ff ff_CQ ( .clk(CLOCK), .rst(rst), .s(CQ_s), .r(CQ_r), .q(CQ) );
    sr_ff ff_CT ( .clk(CLOCK), .rst(rst), .s(CT_s), .r(CT_r), .q(CT) );
    sr_ff ff_CY ( .clk(CLOCK), .rst(rst), .s(CY_s), .r(CY_r), .q(CY) );
    sr_ff ff_CZ ( .clk(CLOCK), .rst(rst), .s(CZ_s), .r(CZ_r), .q(CZ) );

    drum_track #( .N(29) ) track_CM ( .clk(CLOCK), .din(CM_in), .dout(CM) );
    drum_track #( .N(3132) ) track_NT ( .clk(CLOCK), .din(CN_in), .dout(CN) );
endmodule
