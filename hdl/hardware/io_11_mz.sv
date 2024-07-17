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
// Bendix G-15 Input Output 11 and Register MZ (Page 6, 3D592)
// ----------------------------------------------------------------------------
`include "g15_config.vh"

module io_11_mz (
    input  logic rst,
    input  logic CLOCK,
    
    input  logic T0,
    input  logic T29,

    input  logic D4, D5, DX,
    input  logic S4, S5, SX,

    input  logic CIR_C,
    input  logic CIR_Q,
    input  logic CIR_R,
    input  logic CN,
    input  logic FAST,
    input  logic FAST_OUT,
    input  logic IN,
    input  logic KEY_T,
    input  logic LB,
    input  logic OA1, OA4,
    input  logic OC1, OC2,
    input  logic OD,
    input  logic OE,
    input  logic OF2, OF3,
    input  logic OG,
    input  logic OY,
    input  logic MP_CLR_M19,
    input  logic MP_SET_M19,
    input  logic MP_CLR_M23,
    input  logic READY,
    input  logic SLOW_OUT,
    input  logic TR,
    
    input  logic CR_TAB_OF,
    input  logic WAIT_OF,
    input  logic DIGIT_OF,
`ifdef G15_ANC_2
    input  logic OC_r,
`endif
    
`ifdef G15_GROUP_III
    output logic AS,
    output logic AUTO,
    input  logic C1, CV,
    input  logic CF,
    input  logic DS,
    input  logic KEY_E,
    input  logic OC3, OC4,
    input  logic OH,
    input  logic SLOW_IN,
    input  logic SW_SA,
    input  logic TE,
`endif
    output logic CIR_U,
    output logic CIR_V,
    output logic CIR_ALPHA,       // AR to output logic word 00 & OE
    output logic CIR_BETA,
    output logic CIR_DELTA,
    output logic CIR_EPSILON,
    output logic CIR_GAMMA,
    output logic EB19, EB23,
    output logic M19,
    output logic M19_in,
    output logic M23,
    output logic M23_in,
    output logic MZ,
    output logic MZ_in,
    output logic OZ               // Word 0 T1 to T29
    
);
    
`ifdef G15_GROUP_III
    logic AS_s, AS_r;
`endif
    logic OZ_s, OZ_r;
    logic M19_recirc, M19_insert;
    logic M23_recirc;
    //logic MZ_in;
    
    always_comb begin
`ifdef G15_GROUP_III
      AUTO = AS & SLOW_IN; // automatic reload
`endif
      CIR_U = OC1 | OC2; 
      CIR_V = CR_TAB_OF | WAIT_OF | DIGIT_OF;
      CIR_ALPHA = OZ & OE & SLOW_OUT & ~OC1 & ~OC2; // Type AR or M19
      CIR_BETA = READY & KEY_T & OF2;               // <T> transfer N to AR
      CIR_EPSILON = T0 & CIR_BETA;                  // Special case for T29 of W107 that
                                                    //   disambiguates N=00 and N=20
      CIR_DELTA = ~T29 & CIR_BETA & CN;             // CN WT+1 (T22-T28)
      CIR_GAMMA = CIR_ALPHA & CIR_V & M19_insert;
      EB19 = M19 & S4 & SX;
      EB23 = M23 & S5 & SX;
    end

`ifdef G15_GROUP_III    
    // ---------------------------------------------------------------------------------
    // AS:
    // ---------------------------------------------------------------------------------
    always_comb begin
      // AS indicates alphanumeric operation 
      // TYPE = SLOW_OUT & (OC1 | ~OC2)
      // OHs = 
      AS_s =   (DS & ~CV & C1)    // Auto-reload I/O instruction
             | (SW_SA & KEY_E);   // Start type-in alphanumeric
  `ifdef G15_ANC_2
      AS_r = OC_r;
  `else
      AS_r = READY;
  `endif
    end
`endif

    // ---------------------------------------------------------------------------------
    // OZ:
    // ---------------------------------------------------------------------------------
    always_comb begin
      OZ_s = T0;
      // The ~T0 term is added to avoid potential meta-stability during G-15 turn-on
      // where T0 occurs every word time until the CN track is initialized.
      OZ_r = T29 & OZ & ~T0;
    end
    
    always_comb begin
      MZ_in =   (M19 & OE & (FAST | IN))
              | (MZ & ~OD & (FAST | IN))
              | (MZ & ~OE & ~OY & IN)
              | (M23 & OY & IN)
              | (MZ & SLOW_OUT & ~OG)
              | (CIR_Q & OF3);
    end
    
    always_comb begin
      // Instead of gating M19 recirculation it is blocked by OR'ing (by De Morgan's theorom) 
      M19_recirc =   (~M19)
                   | (TR & D4 & DX)
                   | (MP_CLR_M19)
                   | ((CIR_R | IN | FAST_OUT) & OE);
      M19_insert =   (MZ & IN)
                   | (OA4 & SLOW_OUT & (DIGIT_OF | WAIT_OF))
                   | (OA1 & ~OF3 & OF2 & SLOW_OUT)
                   | (MZ & FAST_OUT);
      M19_in =   ((CIR_R | IN | FAST_OUT) & OE & M19_insert)
               | (~M19_recirc)
               | (CN & MP_SET_M19)
               | (LB & TR & DX & D4);
    end

    // ---------------------------------------------------------------------------------
    // M23: 
    // ---------------------------------------------------------------------------------
    always_comb begin
      // CIR_C: OG & OY & FAST_OUT
      M23_recirc =   (M23)
                   & (SLOW_OUT | ~OG)
`ifdef G15_GROUP_III
                   & (~AS | ~OY | ~OC3 | ~OC4)      // ~(AUTO & OY)
`endif
                   & (~D5 | ~(DX & TR))
                   & ~MP_CLR_M23;                   // <M23 CLEAR> button
      M23_in =   (M23_recirc)
`ifdef G15_GROUP_III
// Note: Schematic 3D592 shows signal "SLOW IN (PR2 AUTO)", but condensed schematic
//  68 and schematic 3D589 show "AUTO" instead. Since this term controls auto-reload
//  marker insertion, it is assumed that "AUTO" is the correct signal.
               | (AUTO & OY & ~OG & TE & ~CF)       // marker, bit 1 of even words
               | (IN & OG & OF3 & OA1 & ~OH)        // 1-bit prec, insert OA1
`else
               | (IN & OG & OF3 & OA1)              // 1-bit prec, insert OA1
`endif
               | (IN & OG & OA4 & ~OF3)             // 4-bit prec, insert OA4
               | (D5 & DX & LB)                     // LB->M23
               | (CIR_C & OA4)                      // insert OA4, mag tape out
               | (MZ & OG & ~OY & FAST_OUT);        // MZ->M23, mag tape out
    end

`ifdef G15_GROUP_III
    sr_ff ff_AS ( .clk(CLOCK), .rst(rst), .s(AS_s), .r(AS_r), .q(AS) );
`endif
    sr_ff ff_OZ ( .clk(CLOCK), .rst(rst), .s(OZ_s), .r(OZ_r), .q(OZ) );
    drum_track #( .N(116) ) track_MZ ( .clk(CLOCK), .din(MZ_in), .dout(MZ) );
    drum_track #( .N(3132) ) track_M19 ( .clk(CLOCK), .din(M19_in), .dout(M19) );
    drum_track #( .N(116) ) track_M23 ( .clk(CLOCK), .din(M23_in), .dout(M23) );
endmodule
