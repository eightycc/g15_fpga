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
// Bendix G-15 Control Switch (Page 8, 3D594)
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

module control_switch (
    input logic rst,
    input logic CLOCK,

    input logic CIR_2, CIR_3, CIR_4,
    input logic CI,
    input logic CJ,
    input logic CR,
    input logic M20,
    input logic PJ,
    input logic RC,
    input logic TR,

    output logic C1, C3, C5, C6, C7, C8, C9,
    output logic CU, CV, CW, CX,

    output logic D0, D1, D2, D3, D4, D5, D6, D7, DU, DV, DW, DX,
    output logic S0, S1, S2, S3, S4, S5, S6, S7, SU, SV, SW, SX,

    output logic CS,
    output logic DS,

    // Accessory interface on connectors PL19 and PL20
    input logic PL19_INPUT,
    output logic PL19_SHIFT_CMD_M20,
    output logic PL19_WRITE_PULSE,
    output logic PL19_START_INPUT,
    output logic PL19_STOP_INPUT,
    output logic PL19_SHIFT_CMD,
    output logic PL20_OUTPUT,
    output logic PL20_OUTPUT_SHIFT,
    output logic EB29
);

    logic C2, C4;
    logic RING_BELL;

    // -----------------------------------------------------------------------
    // Static source and destination decoders
    // -----------------------------------------------------------------------
    always_comb begin
      // Decode Destination field bits 6:2
      D0 = ~C4 & ~C5 & ~C6; 
      D1 = C4 & ~C5 & ~C6;
      D2 = ~C4 & C5 & ~C6;
      D3 = C4 & C5 & ~C6;
      D4 = ~C4 & ~C5 & C6;
      D5 = C4 & ~C5 & C6;
      D6 = ~C4 & C5 & C6;
      D7 = C4 & C5 & C6;
      DU = ~C2 & ~C3;
      DV = C2 & ~C3;
      DW = ~C2 & C3;
      DX = C2 & C3;

      // Decode Source Field bits 11:7
      S0 = ~C9 & ~CU & ~CV;
      S1 = C9 & ~CU & ~CV;
      S2 = ~C9 & CU & ~CV;
      S3 = C9 & CU & ~CV;
      S4 = ~C9 & ~CU & CV;
      S5 = C9 & ~CU & CV;
      S6 = ~C9 & CU & CV;
      S7 = C9 & CU & CV;
      SU = ~C7 & ~C8;
      SV = C7 & ~C8;
      SW = ~C7 & C8;
      SX = C7 & C8;

      // CS: Trans. via AR (TVA) or Add via AR (AVA) 
      CS = ~(D7 | ~CX | S7); // equivalent to  (~D7 & CX & ~S7)
      // DS: Transfer to special destination
      DS = TR & D7 & DX;
    end

    // -----------------------------------------------------------------------
    // Accessory Interface
    // -----------------------------------------------------------------------
    always_comb begin
      RING_BELL = DS & S4 & SV;
      PL19_SHIFT_CMD = ~DS & TR & S7 & SV;
      EB29 = PL19_INPUT & M20 & PL19_SHIFT_CMD;
      PL19_SHIFT_CMD_M20 = PL19_SHIFT_CMD & M20;
      // We don't have a write pulse, so we'll use the last half of the clock
      PL19_WRITE_PULSE = ~CLOCK;
      PL19_START_INPUT = RING_BELL & CIR_2;
      PL19_STOP_INPUT = RING_BELL & CIR_3;
      PL20_OUTPUT = PJ & DS & S4 & SW & CIR_4 & M20;
      PL20_OUTPUT_SHIFT = PJ & DS & S4 & SW & CIR_4 & PL19_WRITE_PULSE;
    end

    // Command register static bits
    //   S/D bit
    sr_ff ff_C1 ( .clk(CR), .rst(rst), .s(C2), .r(~C2), .q(C1) );
    //   Destination field bits 6 to 2
    sr_ff ff_C2 ( .clk(CR), .rst(rst), .s(C3), .r(~C3), .q(C2) );
    sr_ff ff_C3 ( .clk(CR), .rst(rst), .s(C4), .r(~C4), .q(C3) );
    sr_ff ff_C4 ( .clk(CR), .rst(rst), .s(C5), .r(~C5), .q(C4) );
    sr_ff ff_C5 ( .clk(CR), .rst(rst), .s(C6), .r(~C6), .q(C5) );
    sr_ff ff_C6 ( .clk(CR), .rst(rst), .s(C7), .r(~C7), .q(C6) );
    //   Source field bits 11 to 7
    sr_ff ff_C7 ( .clk(CR), .rst(rst), .s(C8), .r(~C8), .q(C7) );
    sr_ff ff_C8 ( .clk(CR), .rst(rst), .s(C9), .r(~C9), .q(C8) );
    sr_ff ff_C9 ( .clk(CR), .rst(rst), .s(CU), .r(~CU), .q(C9) );
    sr_ff ff_CU ( .clk(CR), .rst(rst), .s(CV), .r(~CV), .q(CU) );
    sr_ff ff_CV ( .clk(CR), .rst(rst), .s(CW), .r(~CW), .q(CV) );
    //    Characteristic field bits 13 to 12
    sr_ff ff_CW ( .clk(CR), .rst(rst), .s(CX), .r(~CX), .q(CW) );
    sr_ff ff_CX ( .clk(CLOCK), .rst(rst), .s(RC & CJ & CI), .r(RC & CJ & ~CI), .q(CX) );
endmodule