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
// Bendix G-15 Memory Lines M20, M21, and M22 (Page 14, 3D298)
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

module mem_20_21_22 (
    //input logic rst,
    input logic CLOCK,

    input logic CIR_2,
    input logic CU, CV,
    input logic D5, DU, DV, DW,
    input logic S5, S6, S7, SU, SV, SW, SX,
    input logic DS,
    input logic AR,
    input logic LB,
    input logic M18,
    input logic TR,
    
    input logic GO, // DA-1

    output logic EB21,
    output logic EB22,
    output logic EB25,
    output logic EB26,
    output logic EB27,
    output logic EB31,

    output logic M20
);

    logic M20_in, M21_in, M22_in;
    logic M21, M22;

    always_comb begin
      EB21 = M22 & SW & S5;
      EB22 = M21 & SV & S5;
      EB25 = M20 & SU & S5;
      EB26 = M21 & ~M20 & SW & S7;
      EB27 = ~M20 & AR & SX & S6;
      EB31 = M20 & M21 & CU & CV & SX;

      M20_in =   (CIR_2 & M18 & DS & S7 & SX)
               | (M20 & ~(TR & DU))
               | (M20 & ~D5)
               | (LB & DU & D5);

      M21_in =   (LB & DV & D5)
               | (M21 & ~GO & ~(TR & DV))
               | (M21 & ~GO & ~D5);

      M22_in =   (LB & D5 & DW)
               | (M22 & ~GO & ~D5)
               | (M22 & ~GO & ~(TR & DW));
    end

    drum_track #( .N(116) ) track_20 ( .clk(CLOCK), .din(M20_in), .dout(M20) );
    drum_track #( .N(116) ) track_21 ( .clk(CLOCK), .din(M21_in), .dout(M21) );
    drum_track #( .N(116) ) track_22 ( .clk(CLOCK), .din(M22_in), .dout(M22) );

endmodule
    