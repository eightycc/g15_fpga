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
// Bendix G-15 Product Gates (Page 102, 3D595)
// ----------------------------------------------------------------------------
`include "g15_config.vh"

module prod_gate (
    input  logic rst,
    input  logic CLOCK,
    
    input  logic T2, T29,
    
    input  logic CIR_3, CIR_4,
    input  logic C5, C6, C7, C8, CW, CX,
    input  logic D6, D7, DU, DV, DW,
    input  logic S5, S6, SU, SV, SW, SX,
    
    input  logic CE,
    input  logic CS,
    input  logic DS,
    input  logic IC,
    input  logic IS,
    input  logic TE,
    input  logic TR,
    input  logic TR_r,
    
    input  logic M2,
    input  logic LB,

    output logic CIR_X,
    output logic EB28_29,
    output logic EB30_31,
    output logic ID_in,
    output logic MQ_in,
    output logic PN_in,
    output logic PA,
    output logic PC,
    output logic PG_CLEAR,
    output logic PJ,
    output logic PM,
    output logic PP
);

    logic PC_s, PC_r;
    logic PD;
    logic PI;
    logic PJ_s, PJ_r;
    logic PM_s, PM_r;
    logic PN_s, PN_r, PN;
    logic PQ_s, PQ_r, PQ;
    logic PR;
    logic PU, PU_block;

    logic ID_block_recirc;
    logic MQ_block_recirc;

    // -----------------------------------------------------------------------
    // Early Bus Inputs
    // -----------------------------------------------------------------------
    always_comb begin
      EB28_29 =   (PP & S6 & SW)
                | (PR & S6 & SU);
      EB30_31 =   (PJ & PN & S6)
                | (PA & TE & DS & S6 & SV);  // TODO: PA term creates a combinatorial loop
                     
      CIR_X = PR & TR_r & DS & S6 & SV;
    
      PG_CLEAR = DS & S5 & SX & CIR_4;
    end

    // -----------------------------------------------------------------------
    // ID: ID Register
    // -----------------------------------------------------------------------
    always_comb begin
      ID_block_recirc =
                     (TR & DS & DV)                    // TR ->ID
                   | (DS & S6 & ~C7)                   // ID shift right
                   | (DS & S5 & SX & CIR_3)            // PN & M2->ID
                   | (DS & S5 & SX & CIR_4);           // clear ID

      ID_in =   (LB & ~(CS & CE) & D6 & DV & TR)  // LB->ID
              | (PP & M2 & DS & S5 & SX & CIR_3)  // PN & M2->ID
              | (PI & ~TE & DS & S6 & ~C7)        // ID shift right
              | ~(~PJ | ID_block_recirc);         // ID->ID (recirculate)

      // PJ: ID Register Delayed
      PJ_s = PI;
      PJ_r = ~PI;
    end

    // -----------------------------------------------------------------------
    // MQ: MQ Register
    // -----------------------------------------------------------------------
    always_comb begin
      MQ_block_recirc =
                (TR & D6 & DU)                    // TR ->MQ
              | (DS & S5 & SX & CIR_4)            // clear MQ
              | (DS & S6);                        // MQ shift right
      MQ_in =   (T2 & CE & DS & S6 & SV)          // insert quotient 1 bit
              | (PQ & ~TE & DS & S6)              // MQ shift right
              | (LB & ~(CS & CE) & D6 & DU & TR)  // LB->MQ
              | (PR & ~MQ_block_recirc);          // MQ->MQ (recirculate)

      // PM:
      PM_s = MQ_in & T29 & ~CE;
      PM_r = ~MQ_in & T29 & ~CE;

      // PQ:
      PQ_s =   (PR)
             | (T2 & CE & ~IS & DS & S6 & SV);
      PQ_r = ~PQ_s;
    end

    // -----------------------------------------------------------------------
    // PN: PN Register
    // -----------------------------------------------------------------------
    always_comb begin
      PN_in =   (PN)
              | (PA & ~(DS & S6 & SV));

      // PN:
      PN_s = PA & ~TE & DS & S6 & SV;
      PN_r = ~PN_s;
    end

    // -----------------------------------------------------------------------
    // Product Adder
    // -----------------------------------------------------------------------
    always_comb begin
      // PD:
      PD =   (LB & D7 & DW) // Add to PN
           | (LB & ~TE & DS & S6 & SV) // Divide LB->PD execpt bit 29 of odd word
           | (LB & ~(CS & CE) & PJ)
           | (PM & PI & DS & S6 & ~C7 & ~C8 & ~TE);
                
      // PU:
      PU_block = ~(  (PJ)
                   | (DS & S5 & SX & CIR_4)
                   | (TR & D6 & DV & ~CW & (CS | ~CX))
                   | (PP & M2 & DS & S5 & SX & CIR_3) );
      PU = ~PU_block & PP;

      // PA:
      PA =   (~PC & ~PD &  PU)
           | (~PC &  PD & ~PU)
           | ( PC & ~PD & ~PU)
           | ( PC &  PD &  PU);

      // PC: Product Adder Carry Register
      //  PC_s:   IB is -0 or -1/2 (T29 & TR & IS & IC)
      //        & D = PNc or PN+ (C6 & C5 & DW & ~CE)
      //        & ~PD
      PC_s =   (~PD & T29 & ~CE & TR & DW & C6 & C5 & IS & IC)  // "minus zero" -> PD
             | (PD & PU & ~TE);
      PC_r =   (TE)
             | (~PD & PC & ~PU);
    end


    sr_ff ff_PC ( .clk(CLOCK), .rst(rst), .s(PC_s), .r(PC_r), .q(PC) );
    sr_ff ff_PJ ( .clk(CLOCK), .rst(rst), .s(PJ_s), .r(PJ_r), .q(PJ) );
    sr_ff ff_PM ( .clk(CLOCK), .rst(rst), .s(PM_s), .r(PM_r), .q(PM) );
    sr_ff ff_PN ( .clk(CLOCK), .rst(rst), .s(PN_s), .r(PN_r), .q(PN) );
    sr_ff ff_PQ ( .clk(CLOCK), .rst(rst), .s(PQ_s), .r(PQ_r), .q(PQ) );
    drum_track #( .N(57) ) track_ID ( .clk(CLOCK), .din(ID_in), .dout(PI) );
    drum_track #( .N(58) ) track_MQ ( .clk(CLOCK), .din(MQ_in), .dout(PR) );
    drum_track #( .N(58) ) track_PN ( .clk(CLOCK), .din(PN_in), .dout(PP) );
endmodule

