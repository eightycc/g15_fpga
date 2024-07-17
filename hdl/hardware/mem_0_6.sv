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
// Bendix G-15 Memory Lines 0 to 6 (Page 12, 3D296)
// ----------------------------------------------------------------------------
`include "g15_config.vh"

module mem_0_6 (
    input  logic rst,
    input  logic CLOCK,

    input  logic KEY_MARK,
    input  logic C1, C8, CW, CX,
    input  logic D0, D1, DU, DV, DW, DX,
    input  logic S0, S1, S5, SU, SV, SW, SX,
    input  logic DS,
    input  logic AR,
    input  logic CM,
    input  logic TR,
    input  logic LB,
    input  logic M19, M23,
    input  logic KEY_C,
    input  logic READY,
    input  logic SW_SA,
    input  logic PWR_AUTO_TAPE_START,
    input  logic TYPE1, TYPE2, TYPE3,

    output logic CD1, CD2, CD3,
    output logic M0, M1, M2, M3,
    output logic EB0,
    output logic EB1,
    output logic EB2,
    output logic EB3,
    output logic EB4,
    output logic EB5,
    output logic EB6,

    output logic MC_not,
    output logic M0_in, M1_in, M2_in, M3_in, M4_in, M5_in, M6_in
);

    logic CD1_s, CD1_r;
    logic CD2_s, CD2_r;
    logic CD3_s, CD3_r;

    logic M4, M5, M6;

    always_comb begin
      CD1_s =   (CW & DS & S5 & ~C8)
              | (READY & TYPE1 & SW_SA)
              | (PWR_AUTO_TAPE_START);
      CD1_r =   (~CW & DS & S5 & ~C8)
              | (SW_SA & KEY_C);

      CD2_s =   (CX & DS & S5 & ~C8)
              | (READY & TYPE2 & SW_SA)
              | (PWR_AUTO_TAPE_START);
      CD2_r =   (~CX & DS & S5 & ~C8)
              | (SW_SA & KEY_C);

      CD3_s =   (C1 & DS & S5 & ~C8)
              | (READY & TYPE3 & SW_SA)
              | (PWR_AUTO_TAPE_START);
      CD3_r =   (~C1 & DS & S5 & ~C8)
              | (SW_SA & KEY_C);

      MC_not =   (~M0 & ~CD3 & ~CD2 & ~CD1)
              | (~M1 & ~CD3 & ~CD2 &  CD1)
              | (~M2 & ~CD3 &  CD2 & ~CD1)
              | (~M3 & ~CD3 &  CD2 &  CD1)
              | (~M4 &  CD3 & ~CD2 & ~CD1)
              | (~M5 &  CD3 & ~CD2 &  CD1)
              | (~M19 &  CD3 &  CD2 & ~CD1)
              | (~M23 &  CD3 &  CD2 &  CD1);

      EB0 = M0 & S0 & SU;
      EB1 = M1 & S0 & SV;
      EB2 = M2 & S0 & SW;
      EB3 = M3 & S0 & SX;
      EB4 = M4 & S1 & SU;
      EB5 = M5 & S1 & SV;
      EB6 = M6 & S1 & SW;

      M0_in =   (M0 & ~KEY_MARK & ~D0)
              | (M0 & ~KEY_MARK & ~(TR & DU))
              | (KEY_MARK & ~CM)
              | (LB & DU & D0);

      M1_in =   (M1 & ~KEY_MARK & ~D0)
              | (M1 & ~KEY_MARK & ~(TR & DV))
              | (KEY_MARK & AR)
              | (LB & DV & D0);
                
      M2_in =   (M2 & ~D0)
              | (M2 & ~(TR & DW))
              | (LB & DW & D0);

      M3_in =   (M3 & ~D0)
              | (M3 & ~(TR & DX))
              | (LB & DX & D0);

      M4_in =   (M4 & ~D1)
              | (M4 & ~(TR & DU))
              | (LB & DU & D1);

      M5_in =   (M5 & ~D1)
              | (M5 & ~(TR & DV))
              | (LB & DV & D1);

      M6_in =   (M6 & ~D1)
              | (M6 & ~(TR & DW))
              | (LB & DW & D1);
    end

    sr_ff ff_CD1 ( .clk(CLOCK), .rst(rst), .s(CD1_s), .r(CD1_r), .q(CD1) );
    sr_ff ff_CD2 ( .clk(CLOCK), .rst(rst), .s(CD2_s), .r(CD2_r), .q(CD2) );
    sr_ff ff_CD3 ( .clk(CLOCK), .rst(rst), .s(CD3_s), .r(CD3_r), .q(CD3) );

    drum_track #( .N(3132) ) track_M0 ( .clk(CLOCK), .din(M0_in), .dout(M0) );
    drum_track #( .N(3132) ) track_M1 ( .clk(CLOCK), .din(M1_in), .dout(M1) );
    drum_track #( .N(3132) ) track_M2 ( .clk(CLOCK), .din(M2_in), .dout(M2) );
    drum_track #( .N(3132) ) track_M3 ( .clk(CLOCK), .din(M3_in), .dout(M3) );
    drum_track #( .N(3132) ) track_M4 ( .clk(CLOCK), .din(M4_in), .dout(M4) );
    drum_track #( .N(3132) ) track_M5 ( .clk(CLOCK), .din(M5_in), .dout(M5) );
    drum_track #( .N(3132) ) track_M6 ( .clk(CLOCK), .din(M6_in), .dout(M6) );
endmodule
    
