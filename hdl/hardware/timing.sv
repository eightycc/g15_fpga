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
// Bendix G-15 Timing Gates (Page 11, 3D596)
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

module timing (
    input logic rst,
    
    input logic CLOCK, // 9.3uS clock
    
    input logic C1,    // Instruction S/D bit (CS)    
    input logic CE,    // Even word time FF (CG)
    input logic CF,    // Mod 2 and Mod 3 word time FF (CG)
    input logic CN,    // Number Track FF (CG)
    input logic DS,    // Transfer state for special command (CS)
    input logic S6,
    input logic SV,
            
    output logic T0,   // Index, T29 of word 107
    output logic T1,
    output logic T2,
    output logic T13,
    output logic T21,
    output logic T28,
    output logic T29,
    
    output logic TE,   // Even word time FF, T1 to T29
    output logic TF,   // T29 prior to word 0 of 4 word group
    output logic TS    // Sign bit time FF, T1
    );
    
    logic TM;
    logic TA, TA_s, TA_r;
    logic TB, TB_s, TB_r;
    logic TC, TC_s, TC_r;
    logic T1_s, T1_r;
    logic T29_s, T29_r;
    logic TE_s, TE_r;
    logic TS_s, TS_r;
    
    // -----------------------------------------------------------------------
    // Decode timing pulses
    // -----------------------------------------------------------------------
    always_comb begin
      T0 = ~CN & T29;                // T29 of word 107
      T2 = ~TA & ~TB & TC;
      T13 = TA & TB & ~TC & ~TM;
      T21 = TA & TB & ~TC & TM;
      T28 = TA & ~TB & TC;
    
      TF = T29 & CF & ~CE;           // T29 of 3rd word of 4 word group
    end
        

    always_comb begin
    // Timing flip-flops that follow the TM track to decode timing pulses
      TA_s = TM & ~TA;
      TA_r = ~TM | T21;
    
      TB_s = TA;
      TB_r = ~TA;
    
      TC_s = TM & TB & ~TA;
      TC_r = T2;
    
      T1_s = T29;
      T1_r = T1;
    
      T29_s = T28;
      T29_r = T29;
    
      TE_s = T29 & ~CE;
      TE_r = TE;
    
      TS_s = (T29 & ~(S6 & SV & DS) & C1) | (T29 & ~CE);
      TS_r = TS;
    end

    sr_ff ff_TA ( .clk(CLOCK), .rst(rst), .s(TA_s), .r(TA_r), .q(TA) );
    sr_ff ff_TB ( .clk(CLOCK), .rst(rst), .s(TB_s), .r(TB_r), .q(TB) );
    sr_ff ff_TC ( .clk(CLOCK), .rst(rst), .s(TC_s), .r(TC_r), .q(TC) );
    sr_ff ff_T1 ( .clk(CLOCK), .rst(rst), .s(T1_s), .r(T1_r), .q(T1) );
    sr_ff ff_T29 ( .clk(CLOCK), .rst(rst), .s(T29_s), .r(T29_r), .q(T29) );
    sr_ff ff_TE ( .clk(CLOCK), .rst(rst), .s(TE_s), .r(TE_r), .q(TE) );
    sr_ff ff_TS ( .clk(CLOCK), .rst(rst), .s(TS_s), .r(TS_r), .q(TS) );
    // Track TM timing. Repeating pattern that encodes the timing pulses.
    drum_track #(.N(29), .V(29'b0_1101000_1_1100000_01_10000_00000_0)) track_TM ( .clk(CLOCK), .din(TM), .dout(TM) );

endmodule
