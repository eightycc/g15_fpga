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
// Bendix G-15 Inverting Gate and Early Bus (Page 9, 3D393)
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

module invert_gate_eb (
    input logic rst,
    input logic CLOCK,

    input logic EB0, EB1, EB2, EB3, EB4, EB5, EB6, EB7, EB8, EB9, 
    input logic EB10, EB11, EB12, EB13, EB14, EB15, EB16, EB17, EB18, EB19,
    input logic EB21, EB22, EB23, EB25, EB26, EB27, EB28_29, EB29, EB30_31, EB31, EB32,
    
    
    input logic DA_OVFLW,
    
    input logic CW, CX,
    input logic D6, D7, DV, DW, DX,
    input logic S6, S7, SV, SW, SX,
    
    input logic AA,
    input logic AC,
    input logic AR,
    input logic CQ,
    input logic CS,
    input logic DS,
    input logic PA,
    input logic PC,
    input logic PG_CLEAR,
    input logic PP,
    input logic RC,
    input logic TR,
    input logic TS,
    input logic CIR_X,

    //output logic EB,
    output logic FO,
    output logic IB,
    output logic IC,
    output logic IP,
    output logic IS
);

    logic EB;
    logic FE_s, FE_r, FE;
    logic FO_s, FO_r;
    logic IC_s, IC_r;
    logic IP_s, IP_r;
    logic IS_s, IS_r;
    logic OVFLW;
    logic TR_TVA_from_MQ_IP_PN;
    logic TR_TVA_to_MQ_IP_PN;
    logic EB_to_LB_block;
    logic PN_TR_to_PN;

    // --------------------------------------------------------------
    // Early Bus
    // --------------------------------------------------------------
    always_comb begin
      // EB: Early Bus Mux
      EB =   EB0 | EB1 | EB2 | EB3 | EB4 | EB5 | EB6 | EB7 | EB8 | EB9
           | EB10 | EB11 | EB12 | EB13 | EB14 | EB15 | EB16 | EB17 | EB18 | EB19
           | EB21 | EB22 | EB23 |EB25 | EB26 | EB27 | EB28_29 | EB29
           | EB30_31 | EB31 | EB32;

      // Convenience decodes not part of original schematics
      // TR or TVA to ID, MQ, or PN during sign-bit transfer
      //   Dest. ID, MQ, or PN: D6 & ~(DX & TR)
      //   TR or TVA: ~CW & (CS | ~CX)
      TR_TVA_to_MQ_IP_PN = TS & TR & D6 & ~(DX & TR) & ~CW & (CS | ~CX);
      // TR or TVA from ID, MQ, or PN during sign-bit
      TR_TVA_from_MQ_IP_PN = TS & S6 & ~CW & (CS | ~CX);
      // TR or TVA from ID, MQ, or PN not to S6 during sign-bit
      //TR_TVA_from_MQ_IP_PN_not_to_S6 = TR_TVA_from_MQ_IP_PN & ~D6 & IP;
      // TR from PN to PN
      PN_TR_to_PN = TR_TVA_to_MQ_IP_PN & IP & ~CX & S6 & SW & DW;

      // IP: Buffers the EB sign bit when transferring 2-WD lines
      IP_s = TR_TVA_to_MQ_IP_PN & (~S6 | SX) & EB & ~IP;
      IP_r =   (EB & TR_TVA_to_MQ_IP_PN & (~S6 | SX) & ~(DV & TR) & IP)
             | (~EB & TR_TVA_to_MQ_IP_PN & (~S6 | SX) & DV & IP)
             | (PG_CLEAR);

      // EB to LB transfer sign blocking
      EB_to_LB_block = ~(  TR_TVA_from_MQ_IP_PN
                         | TR_TVA_to_MQ_IP_PN
                         | (TS & ~CS & CX)
                         | (IC & ~TS)  );
    end


    // --------------------------------------------------------------
    // Intermediate Bus
    // --------------------------------------------------------------
    always_comb begin
      // IB: Intermediate Bus Mux
      IB =   (~EB & IC & ~TS)
           | (EB & EB_to_LB_block)
           | (PN_TR_to_PN)
           | (IP & ~D6 & TR_TVA_to_MQ_IP_PN)
           | (~EB & ~CS & CX & CW & TS);

      // IC: Whether to complement EB->LB transfer
      IC_s = IS & EB & ~TS & TR;
      IC_r = TS;

      // IS: When to invert EB->LB transfer
      IS_s =   (TS & CW & (CS | ~CX) & ~EB)
             | (PN_TR_to_PN)
             | (EB & (CS | ~CX) & CW & TS);
      IS_r =   (RC)
             | ((CS | ~CX) & ~EB & CW & TS)
             | (~CS & CX & EB & TS);    
    end

    // --------------------------------------------------------------
    // Overflow detection and register
    // --------------------------------------------------------------
    always_comb begin
      FE_s = TS;
      FE_r =   (DS)
             | (AA & DV & IS & ~TS)
             | (PA & DW & IS & ~TS);

      OVFLW =   (DA_OVFLW)
             | (TS & ~AR & AC & FE)
             | (TS & ~PP & PC & FE)
             | (TS & ~AR & ~AC & IC & D7 & DV)
             | (TS & ~PP & ~PC & IC & D7 & DW);

      FO_s = OVFLW | CIR_X;
      FO_r = DS & S7 & SV & FO & CQ;
    end

    sr_ff ff_FE ( .clk(CLOCK), .rst(rst), .s(FE_s), .r(FE_r), .q(FE) );
    sr_ff ff_FO ( .clk(CLOCK), .rst(rst), .s(FO_s), .r(FO_r), .q(FO) );
    sr_ff ff_IC ( .clk(CLOCK), .rst(rst), .s(IC_s), .r(IC_r), .q(IC) );
    sr_ff ff_IP ( .clk(CLOCK), .rst(rst), .s(IP_s), .r(IP_r), .q(IP) );
    sr_ff ff_IS ( .clk(CLOCK), .rst(rst), .s(IS_s), .r(IS_r), .q(IS) );

endmodule
