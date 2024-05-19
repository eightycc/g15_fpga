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
// Bendix G-15 Accumulator Register and Adder (Page 11, 3D596)
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

module acc_reg (
    input logic rst,
    input logic CLOCK,

    input logic T1, T29,
    
    input logic C3, C8,
    input logic D7, DU, DV,
    input logic S6, S7, SU,

    input logic CE,
    input logic CS,
    input logic DS,
    input logic IB,
    input logic IC,
    input logic IS,
    input logic KEY_RETURN,
    input logic M1,
    input logic TR,

    input logic CIR_4,
    input logic CIR_V,
    input logic CIR_ALPHA,
    input logic CIR_BETA,
    input logic CIR_EPSILON,
    input logic CIR_GAMMA,
    input logic CIR_DELTA,
    
    output logic AA,
    output logic AC, AC_s,
    output logic AR,
    output logic EB32,
    output logic LB
);
    
    logic AC_r;
    logic AD;
    logic AU;
    logic AR_block;
    
    // ---------------------------------------------------------------------------------
    // LB Late Bus Mux and Early Bus EB32
    // ---------------------------------------------------------------------------------
    always_comb begin
      LB =   (TR & CS & AR)      // TR accumulator register (AR)
           | (TR & ~CS & IB);    // TR intermediate bus (IB)
      EB32 = AR & SU & S7;       // AR to early bus (EB32)
    end
                
    // ---------------------------------------------------------------------------------
    // Accumulator Register, Adder, and Associated Logic
    // ---------------------------------------------------------------------------------
    always_comb begin
      //   AD: addend
      AD =   (CIR_DELTA)
           | (CIR_EPSILON)
           | (CIR_GAMMA)
           | (LB & D7 & DV)              // LB to AD for AR+ destination
           | (LB & TR & D7 & DU)         // LB to AD for TR to AR
           | (IB & TR & CS)              // IB to AD for TR via AR
           | (KEY_RETURN & M1);
    
      //   AU: augend
      AR_block =   (CIR_ALPHA & CIR_V)
                 | (CIR_BETA)
                 | (TR & D7 & DU)        // TR to AR
                 | (TR & CS)             // TR Via AR
                 | (KEY_RETURN);
      AU = ~(~AR | AR_block);
    
      //   AA: adder sum
      AA =   (~AC & ~AD &  AU)
           | (~AC &  AD & ~AU)
           | ( AC & ~AD & ~AU)
           | ( AC &  AD &  AU);
    
      //   AC: adder carry-out flip-flop            
      AC_s =   (~T1 & AD & AU)   // carry-out, suppress if T1
             | (~T1 & AC & AU)
             | (~T1 & AC & AD)
             | (T29 & TR & ~AD & IS & ~IC & D7 & ~C3)
             | (T29 & ~CE & DS & S6 & C8 & CIR_4);  // shift or normalize and increment AR
                                                           // odd word
      AC_r = ~AC_s;
    end

    sr_ff ff_AC ( .clk(CLOCK), .rst(rst), .s(AC_s), .r(AC_r), .q(AC) );
    drum_track #( .N(29) ) track_AR ( .clk(CLOCK), .din(AA), .dout(AR) );
          
endmodule
