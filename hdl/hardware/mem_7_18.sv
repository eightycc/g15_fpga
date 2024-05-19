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
// Bendix G-15 Memory Lines 7 to 18 (Page 132, 3D297)
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

module mem_7_18 (
    //input logic rst,
    input logic CLOCK,

    input logic CIR_1,
    input logic D1, D2, D3, D4, DU, DV, DW, DX,
    input logic S1, S2, S3, S4, S7, SU, SV, SW, SX,
    input logic DS,
    input logic CN,
    input logic TR,
    input logic LB,

    input logic DA1_M17,
    input logic GO,

    output logic EB7,
    output logic EB8,
    output logic EB9,
    output logic EB10,
    output logic EB11,
    output logic EB12,
    output logic EB13,
    output logic EB14,
    output logic EB15,
    output logic EB16,
    output logic EB17,
    output logic EB18,

    output logic M18
);

    logic M7_in, M8_in, M9_in, M10_in, M11_in, M12_in, M13_in, M14_in, M15_in, M16_in, M17_in, M18_in;
    logic M7, M8, M9, M10, M11, M12, M13, M14, M15, M16, M17;

    always_comb begin
      EB7 = M7 & SX & S1;
      EB8 = M8 & SU & S2;
      EB9 = M9 & SV & S2;
      EB10 = M10 & SW & S2;
      EB11 = M11 & SX & S2;
      EB12 = M12 & SU & S3;
      EB13 = M13 & SV & S3;
      EB14 = M14 & SW & S3;
      EB15 = M15 & SX & S3;
      EB16 = M16 & SU & S4;
      EB17 = M17 & SV & S4;
      EB18 = M18 & SW & S4;

      M7_in =    (M7 & ~D1)
               | (M7 & ~(TR & DX))
               | (LB & DX & D1);

      M8_in =    (M8 & ~D2)
               | (M8 & ~(TR & DU))
               | (LB & DU & D2);

      M9_in =    (M9 & ~D2)
               | (M9 & ~(TR & DV))
               | (LB & DV & D2);

      M10_in =   (M10 & ~D2)
               | (M10 & ~(TR & DW))
               | (LB & DW & D2);

      M11_in =   (M11 & ~D2)
               | (M11 & ~(TR & DX))
               | (LB & DX & D2);

      M12_in =   (M12 & ~D3)
               | (M12 & ~(TR & DU))
               | (LB & DU & D3);

      M13_in =   (M13 & ~D3)
               | (M13 & ~(TR & DV))
               | (LB & DV & D3);

      M14_in =   (M14 & ~D3 & ~GO)
               | (M14 & ~GO & ~(TR & DW))
               | (LB & DW & D3);

      M15_in =   (M15 & ~D3)
               | (M15 & ~(TR & DX))
               | (LB & DX & D3);

      M16_in =   (M16 & ~D4 & ~GO)
               | (M16 & ~GO & ~(TR & DU))
               | (LB & DU & D4);

      M17_in =   (M17 & ~D4 & ~GO)
               | (M17 & ~GO & ~(TR & DV))
               | (DA1_M17 & DV & TR)
               | (DA1_M17 & ~D4)
               | (LB & DV & D4);

      M18_in =   (M18 & ~D4)
               | (M18 & ~(TR & DW))
               | (LB & DW & D4)
               | (SX & S7 & DS & CIR_1 & CN);
    end

    drum_track #( .N(3132) ) track_M7 ( .clk(CLOCK), .din(M7_in), .dout(M7) );
    drum_track #( .N(3132) ) track_M8 ( .clk(CLOCK), .din(M8_in), .dout(M8) );
    drum_track #( .N(3132) ) track_M9 ( .clk(CLOCK), .din(M9_in), .dout(M9) );
    drum_track #( .N(3132) ) track_M10 ( .clk(CLOCK), .din(M10_in), .dout(M10) );
    drum_track #( .N(3132) ) track_M11 ( .clk(CLOCK), .din(M11_in), .dout(M11) );
    drum_track #( .N(3132) ) track_M12 ( .clk(CLOCK), .din(M12_in), .dout(M12) );
    drum_track #( .N(3132) ) track_M13 ( .clk(CLOCK), .din(M13_in), .dout(M13) );
    drum_track #( .N(3132) ) track_M14 ( .clk(CLOCK), .din(M14_in), .dout(M14) );
    drum_track #( .N(3132) ) track_M15 ( .clk(CLOCK), .din(M15_in), .dout(M15) );
    drum_track #( .N(3132) ) track_M16 ( .clk(CLOCK), .din(M16_in), .dout(M16) );
    drum_track #( .N(3132) ) track_M17 ( .clk(CLOCK), .din(M17_in), .dout(M17) );
    drum_track #( .N(3132) ) track_M18 ( .clk(CLOCK), .din(M18_in), .dout(M18) );

endmodule