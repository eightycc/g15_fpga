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
// Bendix G-15 Input Output 1 & 2 (Page 2, 3D588)
// ----------------------------------------------------------------------------
`include "g15_config.vh"

module io_1_2 (
    input  logic rst,
    input  logic CLOCK,
    
    input  logic T21, T29,
    input  logic TF,

    input  logic S0, S1, S2,

`ifdef G15_GROUP_III
    input  logic AS,
    input  logic AUTO,     // (11) AS & SLOW_IN
    input  logic C1, CV,
    input  logic CIR_4,
    input  logic CIR_M,    // (5,6) CIR_N & SLOW_OUT & ~OE
    input  logic KEY_E,
    input  logic TYPE_FB,  // <F-B> Typewriter feedback
    input  logic M23,
    input  logic OA1, OA3,
    input  logic OC4,
    input  logic OS,
    input  logic T0,
`endif
    input  logic CC,
    input  logic CIR_A,    // (5,6) ~OD & CIR_Q
    input  logic CIR_C,    // (5,6) OG & OY & FAST_OUT
    input  logic CIR_D,    // (5,6) OD & CIR_Q
    input  logic CIR_F,    // (5,6) T0 & OE
    input  logic CIR_G,    // (5,6) T0 & ~OE
    input  logic CIR_N,    // (5,6) T1 & OZ
    input  logic CIR_Q,    // (5,6) ~AS & OG & SLOW_OUT & STOP_OB
    input  logic CIR_S,    // (5,6) CIR_E(IN & ~OF1 & OF2 & TF) & SLOW
    input  logic CIR_U,    // (11) OC1 | OC2
    input  logic CIR_W,    // (3,4) CIR_U & CIR_F & ~OY & FAST_OUT & ~OB3
    input  logic CIR_Z,    // (5,6) ~OY & ~OG & TF & FAST_OUT & OB3
    input  logic DS,
    input  logic FAST_IN,
    input  logic FAST_OUT,
    input  logic KEY_A,
    input  logic KEY_T,
    input  logic HC,
    input  logic IN,
    input  logic M2,
    input  logic M3,
    input  logic M19,
    input  logic MZ,
    input  logic OA4,
    input  logic OB2, OB3, OB4, OB5,
    input  logic OC1, OC2,
    input  logic OUT,
    input  logic READY,
    input  logic SLOW_OUT,
    input  logic STOP_OB,
    input  logic SW_SA,
    input  logic TAB_OB,
    input  logic CR_TAB_OB,
    input  logic TYPE,
    input  logic WAIT_OB,
    
    output logic CIR_H,
    output logic OD,
    output logic OE,
    output logic OG,
`ifdef G15_GROUP_III
    output logic OH,
`endif
    output logic OY,
    output logic OF1, OF2, OF3,
    output logic DIGIT_OF,
    output logic SIGN_OF,
    output logic CR_TAB_OF,
    output logic WAIT_OF
);
    
    logic CIR_J;
    logic OD_s, OD_r;
    logic OE_s, OE_r;
    logic OG_s, OG_r;
`ifdef G15_GROUP_III
    logic OH_s, OH_r;
`endif
    logic OY_s, OY_r;
    logic OF1_s, OF1_r;
    logic OF2_s, OF2_r;
    logic OF3_s, OF3_r;
    logic RELOAD_OF;
    logic STOP_OF;
    
    // ---------------------------------------------------------------------------------
    // OF register control character decode. For slow-out operations, OF1, OF2, and OF3
    // are used to buffer the 3-bit control character shifted in from formatting code
    // words in M2 (M19 data out) or M3 (AR data out).
    // ---------------------------------------------------------------------------------
    always_comb begin
      DIGIT_OF  = ~OF1 & ~OF2 & ~OF3;  // M19<->OAs->OBs->Output
      SIGN_OF   =  OF1 & ~OF2 & ~OF3;  // OS->OB1->Output
      CR_TAB_OF =         OF2 & ~OF3;  // OFs->OBs->Output
      STOP_OF   = ~OF1 & ~OF2 &  OF3;  // (M19 == 0)? Stop->Output, Reset OCs
                                       //           : Change to RELOAD
      RELOAD_OF =  OF1 & ~OF2 &  OF3;  // OFs->OBs->Output, Reload format
      WAIT_OF   =  OF1 &  OF2 &  OF3;  // OFs->OBs->Output
    end

    // ---------------------------------------------------------------------------------
    // OF: During input processing, OF1 and OF2 synchronize sampling the input data
    //     and the CIR_E signal. OF3 selects 1 or 4 bit precession for slow input.
    //
    //     For slow output, OF1, OF2, and OF3 form a shift register used during
    //     output formatting.
    //
    //     For <T> (xfer N to AR) OF2 along with CIR_BETA, CIR_DELTA, and CIR_EPSILON
    //     time the transfer of WT+1 from CN into the upper bits of AR.
    // ---------------------------------------------------------------------------------
    always_comb begin
      // CIR_A: ~OD & CIR_Q
      // CIR_C: OG & OY & FAST_OUT
      // CIR_D: OD & CIR_Q
      // CIR_E: IN & ~OF1 & OF2 & TF
      // CIR_Q: ~AS & OG & SLOW_OUT & STOP_OB
      // CIR_S: CIR_E(IN & ~OF1 & OF2 & TF) & SLOW
      // CIR_U: OC1 | OC2
      CIR_H =   (OY & ~OG & FAST_OUT & ~OB2 & OB4)
              | (OY & ~OG & FAST_OUT & OC1 & ~OC2);

      // CIR_J: Shift OF1->OF2 control
      CIR_J =   (IN)        // In:  IN decode in OC
              | (CIR_A)     // Out: CIR_Q (MZ->OF1, OF2->OF3->MZ control) & ~OD
              | (CIR_D);    // Out: CIR_Q (MZ->OF1, OF2->OF3->MZ control) & OD

      OF1_s =   (IN & HC & ~OF2 & ~STOP_OB)        // In:  HC synchronization
              | (CIR_A & MZ)                       // Slow out: MZ->OF1
              | (CIR_C & OA4)                      // Fast out: OA4->OF1
              | (CIR_U & STOP_OF & SLOW_OUT & ~OG & M19)
                                                   // Slow out: convert STOP to RELOAD (M19 != 0)
              | (CIR_U & CIR_D & M2)               // Slow out: M19 format by M2
              | (CIR_D & ~OC1 & ~OC2 & M3);        // Slow out: AR format by M3
      OF1_r =   (IN & ~HC)                         // In: HC synchronization
              | (CIR_A & ~MZ)                      // Slow out: MZ->OF1
              | (CIR_H)                            // Fast out:
              | (CIR_U & CIR_D & ~M2)              // Slow out:
              | (CIR_D & ~OC1 & ~OC2 & ~M3)        // Slow out:
              | (READY);
                   
      OF2_s =   (READY & SW_SA & KEY_T & CC & T21) // N -> AR: Transfer start
              | (CIR_J & OF1);                     // I/O: OF1->OF2  
      OF2_r =   (READY & T29)                      // N -> AR: Transfer end
              | (CIR_J & (OUT | TF) & ~OF1);       // I/O: OF1->OF2
                
      OF3_s =   (CIR_S & CR_TAB_OB)                // Slow in: 1-bit precession
`ifdef G15_GROUP_III
              | (AUTO & OG & TF & OA3 & OH & OS)   // Slow in: 1-bit precession
`else
              | (TYPE & OY & CIR_G)                // Slow out:
`endif
              | (CIR_Q & OF2)                      // Slow out: OF2->OF3
              | (~(DS & S1) & ~OF2 & FAST_IN);     // Fast_in:
      OF3_r =   (CIR_Q & ~OF2)                     // Slow out: OF2->OF3
              | (READY)
              | (CIR_S & OB5)                      // Slow in: 4-bit precession
              | (CIR_S & WAIT_OB);                 // Slow in: 4-bit precession
    end       
    
    
    // ---------------------------------------------------------------------------------
    // OD:
    // ---------------------------------------------------------------------------------
    always_comb begin
      // CIR_F: T29 of W107 (T0 & OE)
      // CIR_M: CIR_N & SLOW_OUT & ~OE
      // CIR_N: T1 & OZ
      // CIR_S: CIR_E(IN & ~OF1 & OF2 & TF) & SLOW
      // CIR_U: Not "SET READY" when combined with S0 (OC1 | OC2)
      // CIR_Z: ~OY & ~OG & TF & FAST_OUT & OB3
      OD_s =   (DS & S2)                           // @TR slow out cmd 
             | (DS & S0 & CIR_U)                   // @TR fast out cmd (not "SET READY")
             | (CIR_N & SW_SA & KEY_A)             // @(T1&OZ) Key A(type AR) 
             | (CIR_Z)                             // @TF ~OY & ~OG & FAST_OUT & OB3
             | (CIR_F & RELOAD_OF & SLOW_OUT)      // @(T0&OE) slow out RELOAD
`ifdef G15_GROUP_III
             | (~OB5 & OB3 & ~OB2 & CIR_S & ~AS)   // [STOP+RELOAD]OB & CIR_S & ~AS
             | (AUTO & OG & TF & OA3)              // in m23 full 4 bits (G-III)
             | (AUTO & OG & TF & M23)              // in m23 full 1 bit (G-III)
             | (CIR_M & OH & ~OA1);                // @(T1&OZ) slow out (G-III)
`else
             | (~OB5 & OB3 & ~OB2 & CIR_S);        // [STOP+RELOAD]OB & CIR_S
`endif
      OD_r =   (CIR_F & OD)                        // @(T0&OE&OD)
`ifdef G15_GROUP_III
    `ifdef G15_ANC_2
             | (~OC4 & ~HC & T0 & OH);             // (ANC-2, G-III)
    `else
             | (~OC4 & ~HC & T0 & AS);             // (~ANC-2, G-III)
    `endif
`endif
             ;
    end

    // ---------------------------------------------------------------------------------
    // OE:
    // ---------------------------------------------------------------------------------
    always_comb begin
      // CIR_F: OE & T0  
      // CIR_G: ~OE & T0           
      OE_s =   (CIR_G & OY & SLOW_OUT)             // @(T0&~OE)
`ifdef G15_GROUP_III
             | (CIR_G & OH & SLOW_OUT)             // @(T0&~OE)
    `ifdef G15_ANC_2
             | (CIR_G & OD & FAST_OUT & ~OH)       // @(T0&~OE) (ANC-2, G-III)
    `else
             | (CIR_G & OD & FAST_OUT & ~AS)       // @(T0&~OE) (~ANC-2, G-III)
    `endif
`else
             | (CIR_G & OD & FAST_OUT)             // @(T0&~OE) (~G-III)
`endif
             | (CIR_G & OD & IN);
      OE_r = CIR_F;                                // @(T0&OE)
    end
    
    // ---------------------------------------------------------------------------------
    // OG: Precession control
    // ---------------------------------------------------------------------------------
    always_comb begin
      // CIR_E: IN & ~OF1 & OF2 & TF
      // CIR_H: OY & ~OG & FAST_OUT & ~OB2 & OB4
      // CIR_N: T1 & OZ
      // CIR_S: CIR_E(IN & ~OF1 & OF2 & TF) & SLOW
      // CIR_Z: ~OY & ~OG & TF & FAST_OUT & OB3
      OG_s =   (CIR_S & OB5)                       // Slow in digit
             | (CIR_S & WAIT_OB)                   // Slow in wait
             | (CIR_S & TAB_OB)                    // Slow in tab
             | (CIR_N & ~OE & OY & SLOW_OUT)
             | (CIR_Z)
             | (CIR_H)
`ifdef G15_GROUP_III
             | (AUTO & OH & OS & ~OG & TF)         // (G-III)
`endif
             ;
      OG_r =   ~(   (CIR_S & OB5)
                  | (CIR_S & WAIT_OB)
                  | (CIR_S & TAB_OB) ) & OG & TF;
    end

`ifdef G15_GROUP_III    
    // ---------------------------------------------------------------------------------
    // OH: 
    // ---------------------------------------------------------------------------------
    always_comb begin
      OH_s =   (DS & ~CV & C1 & CIR_4 & IN)        // auto-reload input op, char=0 (G-III)
             | (SW_SA & KEY_E)                     // (G-III)
             | (TYPE & AS & OY & T0);              // (G-III)
      OH_r =   (READY)                             // (G-III)
             | (TYPE & ~OY & T0);                  // (G-III)
    end
`endif

    // ---------------------------------------------------------------------------------
    // OY: For slow-out operations:
    //     (1) OY_s: Slow-out waiting for feedback (CIR_G & ~HC)
    //     
    //     
    // ---------------------------------------------------------------------------------
    always_comb begin
      // CIR_E: IN & ~OF1 & OF2 & TF    //     
      // CIR_F:  OE & T0
      // CIR_G: ~OE & T0
      // CIR_H: OY & ~OG & FAST_OUT & ~OB2 & OB4
      // CIR_S: CIR_E(IN & ~OF1 & OF2 & TF) & SLOW
      // CIR_U: OC1 | OC2
      // CIR_W: CIR_U & CIR_F & ~OY & FAST_OUT & ~OB3
      // CIR_Z: ~OY & ~OG & TF & FAST_OUT & OB3
      OY_s =   (CIR_W)                             // Fast-out:
             | (CIR_Z)                             // Fast-out:
`ifdef G15_GROUP_III
             | (DS & ~CV & C1 & AUTO & TF)         // Slow-in:
             | (KEY_E & SW_SA & T0)                // Start alphanumeric input
             | (AUTO & OG & TF & OA3)              // Slow-in:
             | (AUTO & OG & TF & M23)              // Slow-in:
             | (~OB5 & OB3 & ~OB2 & CIR_S & ~AS)   // Slow-in: [STOP + RELOAD]OB
             | (SLOW_OUT & ~HC & ~OY & ~OH & ~OS & T0);  // Slow-out:
`else
             | (~OB5 & OB3 & ~OB2 & CIR_S)         // Slow_in: [STOP + RELOAD]OB
             | (SLOW_OUT & CIR_G & ~HC);           // Slow_out: Waiting for HC feedback
`endif
      OY_r =   (OY & TF & IN)                      // In:
`ifdef G15_GROUP_III
             | (TYPE_FB & ~OH & TYPE & AS)         // Slow-out:
             | (CIR_F & TYPE & OY)                 // Slow-out:
`else
             | (CIR_F & TYPE)                      // Slow-out:
`endif
             | (CIR_H & OF1)                       // Fast-out:
             | (READY);
    end              
    
    sr_ff ff_OD ( .clk(CLOCK), .rst(rst), .s(OD_s), .r(OD_r), .q(OD) );
    sr_ff ff_OE ( .clk(CLOCK), .rst(rst), .s(OE_s), .r(OE_r), .q(OE) );
    sr_ff ff_OG ( .clk(CLOCK), .rst(rst), .s(OG_s), .r(OG_r), .q(OG) );
`ifdef G15_GROUP_III
    sr_ff ff_OH ( .clk(CLOCK), .rst(rst), .s(OH_s), .r(OH_r), .q(OH) );
`endif
    sr_ff ff_OY ( .clk(CLOCK), .rst(rst), .s(OY_s), .r(OY_r), .q(OY) );
    sr_ff ff_OF1 ( .clk(CLOCK), .rst(rst), .s(OF1_s), .r(OF1_r), .q(OF1) );
    sr_ff ff_OF2 ( .clk(CLOCK), .rst(rst), .s(OF2_s), .r(OF2_r), .q(OF2) );
    sr_ff ff_OF3 ( .clk(CLOCK), .rst(rst), .s(OF3_s), .r(OF3_r), .q(OF3) );
endmodule
