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
// Bendix G-15 Input Output 5 & 6 (Page 4, 3D590)
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

module io_5_6 (
    input logic rst,
    input logic CLOCK,
    
    input logic AS,
    input logic AUTO,
    input logic C7, C8, C9,
    input logic CIR_ALPHA,
    input logic CIR_H,
    input logic CIR_U,
    input logic CIR_V,
    input logic CU, CV,
    input logic DS,
    input logic KEY_A,
    input logic KEY_B,
    input logic KEY_E,
    input logic KEY_P,
    input logic KEY_Q,
    input logic KEY_CIR_S,
    input logic OA1,
    input logic OB3,
    input logic OF1, OF2, OF3,
    input logic OD,
    input logic OE,
    input logic OG,
    input logic OH,
    input logic OS,
    input logic OY,
    input logic OZ,
    input logic PHOTO_TAPE_REV,
    input logic PWR_AUTO_TAPE_START,
    input logic PWR_CLEAR,
    input logic S0,
    input logic SU,
    input logic SIGN_OF,
    input logic STOP_OB,
    input logic SW_SA,
    input logic T0, T1,
    input logic TF,
    
    output logic CIR_A,
    output logic CIR_C,
    output logic CIR_D,
    output logic CIR_E,
    output logic CIR_F,
    output logic CIR_G,
    output logic CIR_K,
    output logic CIR_L,
    output logic CIR_M,
    output logic CIR_N,
    output logic CIR_O,
    output logic CIR_Q,
    output logic CIR_R,
    output logic CIR_S,
    output logic CIR_T,
    output logic CIR_Y,
    output logic CIR_Z,
    output logic FAST,
    output logic FAST_IN,
    output logic FAST_OUT,
    output logic IN,
    output logic MAG_TAPE_STOP,
    output logic OC1, OC2, OC3, OC4,
    //output logic OC3_s, OC4_s,
    //output logic OC_r,
    output logic OUT,
    output logic PHOTO_TAPE_FWD,
    output logic READY,
    output logic SLOW_IN,
    output logic SLOW_OUT,
    output logic TAPE_START,
    output logic TYPE
);
    
    logic OC1_s, OC2_s, OC3_s, OC4_s;
    logic OC_r;
    logic SLOW;
    
    // ---------------------------------------------------------------------------------
    // Decode OC register bits 3 and 4 to IN/OUT, FAST/SLOW
    // ---------------------------------------------------------------------------------
    always_comb begin
      FAST = ~OC4;
      FAST_IN = OC3 & ~OC4;
      FAST_OUT = ~OC3 & ~OC4;
      IN = OC3;
      OUT = ~OC3;
      SLOW = OC4;
      SLOW_IN = OC3 & OC4;
      SLOW_OUT = ~OC3 & OC4;
    end
    
    // ---------------------------------------------------------------------------------
    // READY: I/O is idle and ready for next operation
    // ---------------------------------------------------------------------------------
    always_comb begin
      READY = ~OD & ~OC1 & ~OC2 & ~OC3 & ~OC4;
    end

    always_comb begin
      CIR_Q = SLOW_OUT & OG & ~STOP_OB & ~AS;           // (G-III)
    //CIR_Q = SLOW_OUT & OG;                            // (~G-III)
      CIR_A = ~OD & CIR_Q;
      CIR_C = OG & FAST_OUT & OY;
      CIR_D = OD & CIR_Q;
      CIR_E = IN & ~OF1 & OF2 & TF;
      CIR_F = OE & T0;
      CIR_G = ~OE & T0;
      CIR_K =   (STOP_OB & SLOW_OUT & OE & OZ)
              | (OC_r)
              | (CIR_E & FAST_IN)
              | (CIR_E & ~STOP_OB);
      CIR_N = T1 & OZ;
      CIR_M = CIR_N & SLOW_OUT & ~OE;
      CIR_L = CIR_M & OS & SIGN_OF;
      CIR_O = OG & ~TF & IN;
      CIR_T = OE & CIR_U & SLOW_OUT;
      CIR_R = CIR_T & CIR_V;
      CIR_S = CIR_E & SLOW;
      CIR_Y =   (CIR_ALPHA & CIR_V)
              | (CIR_C)
              | (CIR_O)
              | (CIR_R);
      CIR_Z = ~OY & FAST_OUT & ~OG & OB3 & TF;

      MAG_TAPE_STOP =   (OC1 & CIR_S & STOP_OB)
                      | (READY);
      PHOTO_TAPE_FWD = OC1 & OC2 & SLOW_IN;
      TYPE =   (SLOW_OUT & OC1)
             | (SLOW_OUT & ~OC2);
      TAPE_START =   (PWR_AUTO_TAPE_START)             // Turn-on cycle <AUTO TAPE START>
                   | (SW_SA & KEY_P & ~AS);            // Key P Start Tape
    
    end
    
    // ---------------------------------------------------------------------------------
    // OC: I/O operation control register
    // ---------------------------------------------------------------------------------
    always_comb begin
      OC1_s =   (DS & ~CV & C7)                        // I/O op bit 7
              | (TAPE_START)                           // Start phototape reader
              | (PHOTO_TAPE_REV & CIR_E & STOP_OB);

      OC2_s =   (DS & ~CV & C8)                        // I/O op bit 8
              | (TAPE_START)                           // Start phototape reader
              | (SW_SA & KEY_P & ~AS)                  // Key P Start Tape
              | (SW_SA & KEY_B);                       // Key B Start Tape Reverse

      OC3_s =   (DS & ~CV & C9)                        // I/O op bit 9
              | (TAPE_START)                           // Start phototape reader
              | (SW_SA & KEY_B)                        // Key B Start Tape Reverse
              | (SW_SA & KEY_E)                        // Key E Start Type-In, Alpha
              | (SW_SA & KEY_Q);                       // Key Q Start Type-In, Numeric

      OC4_s =   (DS & ~CV & CU)                        // I/O op bit 10
              | (TAPE_START)                           // Start phototape reader
              | (PHOTO_TAPE_REV & CIR_E & STOP_OB & OC1)
              | (SW_SA & KEY_A & CIR_N)                // Key A @(T1&OZ)
              | (SW_SA & KEY_E)                        // Key E Start Type-In, Alpha
              | (SW_SA & KEY_Q);                       // Key Q Start Type-In, Numeric
                   
      OC_r =    (FAST_IN & OF3 & ~OC2)                 // Mag. tape search complete
              | (DS & S0 & SU)                         // I/O op SET READY
              | (SW_SA & KEY_CIR_S)                        // Key S Stop Tape
              | (PWR_CLEAR)
              | (CIR_M & OH & ~OA1)
              | (CIR_F & OH & OF3 & AUTO)
              | (CIR_F & SLOW_OUT & STOP_OB)
              | (~OD & ~OF2 & SLOW_IN & STOP_OB)
              | (CIR_H & ~OF1 & ~OB3)
              | (OC1 & OC2 & KEY_CIR_S & ~OH);
    end
    
    sr_ff ff_OC1 ( .clk(CLOCK), .rst(rst), .s(OC1_s), .r(OC_r), .q(OC1) );
    sr_ff ff_OC2 ( .clk(CLOCK), .rst(rst), .s(OC2_s), .r(OC_r), .q(OC2) );
    sr_ff ff_OC3 ( .clk(CLOCK), .rst(rst), .s(OC3_s), .r(OC_r), .q(OC3) );
    sr_ff ff_OC4 ( .clk(CLOCK), .rst(rst), .s(OC4_s), .r(OC_r), .q(OC4) );
    
endmodule
