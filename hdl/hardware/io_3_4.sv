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
// Bendix G-15 Input Output 3 & 4 (Page 3, 3D589)
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

module io_3_4 (
    input logic rst,
    input logic CLOCK,
    
    input logic AR,
    input logic AUTO,
    input logic CARD_INPUT1, CARD_INPUT2, CARD_INPUT3, CARD_INPUT4, CARD_INPUT5,
    input logic CARD_SIGN,
    input logic CIR_ALPHA,
    input logic CIR_B,
    input logic CIR_C,
    input logic CIR_E,
    input logic CIR_F,
    input logic CIR_H,
    input logic CIR_I,
    input logic CIR_K,
    input logic CIR_L,
    input logic CIR_M,
    input logic CIR_O,
    input logic CIR_P,
    input logic CIR_R,
    input logic CIR_S,
    input logic CIR_T,
    input logic CIR_U,
    input logic CIR_V,
    input logic CIR_Y,
    input logic CIR_Z,
    input logic CF,
    input logic CN,
    input logic DIGIT_OF,
    input logic DS,
    input logic FAST_OUT,
    input logic KEY_CIR_S,
    input logic KEY_FB,
    input logic IN,
    input logic M19,
    input logic M23,
    input logic MAG1_IN, MAG2_IN, MAG3_IN, MAG4_IN, MAG5_IN,
    input logic OC2,
    input logic OD,
    input logic OE,
    input logic OF1,
    input logic OG,
    input logic OH,
    input logic OY,
    input logic PHOTO1, PHOTO2, PHOTO3, PHOTO4, PHOTO5,
    input logic PUNCHED_TAPE1, PUNCHED_TAPE2, PUNCHED_TAPE3, PUNCHED_TAPE4, PUNCHED_TAPE5,
    input logic PUNCH_SYNC,
    input logic READY,
    input logic S2, SV,
    input logic SLOW_OUT,
    input logic SW_PUNCH,
    input logic SW_SA,
    input logic T1,
    input logic T2,
    input logic TE,
    input logic TF,
    input logic TYPE1, TYPE2, TYPE3, TYPE4, TYPE5,
    
    output logic CIR_W,
    output logic CR_TAB_OB,
    output logic TAB_OB,
    output logic STOP_OB,
    output logic HC,
    output logic OA1, OA2, OA3, OA4,
    output logic OB1, OB2, OB3, OB4, OB5,
    output logic OS,
    output logic WAIT_OB
);
    
    logic IN1, IN2, IN3, IN4, IN5;
    logic OA1_s, OA1_r;
    logic OA2_s, OA2_r;
    logic OA3_s, OA3_r;
    logic OA4_s, OA4_r;
    logic OAx_r;
    logic OB1_s, OB1_r;
    logic OB2_s, OB2_r;
    logic OB3_s, OB3_r;
    logic OB4_s, OB4_r;
    logic OB5_s, OB5_r;
    logic OS_s, OS_r;
    logic SIGN_OB;
    
    always_comb begin
      CR_TAB_OB =         OB2 & ~OB3 & ~OB5;
      SIGN_OB   =  OB1 & ~OB2 & ~OB3 & ~OB5;
      TAB_OB    =  OB1 &  OB2 & ~OB3 & ~OB5;   // not found on schematic
      WAIT_OB   =  OB1 &  OB2 &  OB3 & ~OB5 & CIR_S;
      STOP_OB   = ~OB1 & ~OB2 &  OB3 & ~OB5;
    
      CIR_W = CIR_U & CIR_F & ~OY & FAST_OUT & ~OB3; 
    
      IN1 = PUNCHED_TAPE1 | PHOTO1 | TYPE1 | MAG1_IN | CARD_INPUT1;
      IN2 = PUNCHED_TAPE2 | PHOTO2 | TYPE2 | MAG2_IN | CARD_INPUT2;
      IN3 = PUNCHED_TAPE3 | PHOTO3 | TYPE3 | MAG3_IN | CARD_INPUT3;
      IN4 = PUNCHED_TAPE4 | PHOTO4 | TYPE4 | MAG4_IN | CARD_INPUT4;
      IN5 = PUNCHED_TAPE5 | PHOTO5 | TYPE5 | MAG5_IN | CARD_INPUT5;
    
      HC =   (FAST_OUT & OC2 & PUNCH_SYNC)
           | (IN1)
           | (IN2)
           | (IN3)
           | (KEY_FB)
           | (SW_SA & SLOW_OUT)
           | (IN5);
    end

    // ---------------------------------------------------------------------------------
    // OS: I/O word sign, 0(+), 1(-)
    // ---------------------------------------------------------------------------------
    always_comb begin
      OS_s =   (AUTO & KEY_CIR_S)
             | (T1 & CN & CIR_T & M19)
             | (T1 & CIR_ALPHA & AR)
             | (CARD_SIGN)
             | (SIGN_OB)
             | (DS & S2 & SV);
      OS_r =   (READY)
             | (CIR_M)
             | (CIR_E & CR_TAB_OB);
    end

    // ---------------------------------------------------------------------------------
    // OA1 to OA4:
    // ---------------------------------------------------------------------------------
    always_comb begin
      // CIR_ALPHA: OZ & OE & SLOW_OUT & ~OC1 & ~OC2;
      // CIR_C: OG & FAST_OUT & OY;
      // CIR_E: IN & ~OF1 & OF2 & TF;
      // CIR_O: OG & ~TF & IN;
      // CIR_R: CIR_T & CIR_V;
      // CIR_T: OE & CIR_U & SLOW_OUT;
      // CIR_U: OC1 | OC2;
      // CIR_V: CR_TAB_OF | WAIT_OF | DIGIT_OF;
      OAx_r =   (READY)
              | (WAIT_OB)
              | (CIR_M)
              | (CIR_H)
              | (AUTO & OH & TF & OS & ~OG);
           
      OA1_s =   (CIR_E & OB4 & OB5)         // OB4 for [DIG]OB 
              | (CIR_R & M19)
              | (CIR_ALPHA & CIR_V & AR)
              | (CIR_O & ~OY & M23)
              | (CIR_C & M23)
              | (CIR_E & OS & CR_TAB_OB)
              | (TE & ~CF & OY & AUTO);     // Auto reload marker

      OA1_r =   (OAx_r)
              | (T2 & AUTO & OY)            // Auto reload marker
              | (CIR_C & ~M23)
              | (CIR_E & ~OS & CR_TAB_OB)
              | (CIR_E & ~OB4 & OB5)        // OB4 for [DIG]OB
              | (CIR_R & ~M19)
              | (CIR_ALPHA & CIR_V & ~AR)
              | (CIR_O & ~OY & ~M23);
    
      OA2_s =   (CIR_Y & OA1)
              | (CIR_Z)
              | (CIR_E & OB3 & OB5);

      OA2_r =   (OAx_r)
              | (CIR_Y & ~OA1)
              | (CIR_E & ~OB3);
        
      OA3_s =   (CIR_Y & OA2)
              | (CIR_E & OB2 & OB5);
    
      OA3_r =   (OAx_r)
              | (CIR_Y & ~OA2)
              | (CIR_E & ~OB2);
    
      OA4_s =   (CIR_Y & OA3)
              | (CIR_E & OB1 & OB5);
    
      OA4_r =   (OAx_r)
              | (CIR_Y & ~OA3)
              | (CIR_E & ~OB1);
    end

    // ---------------------------------------------------------------------------------
    // OB1 to OB4:
    // ---------------------------------------------------------------------------------
    always_comb begin                   
      OB1_s =   (CIR_L)
              | (CIR_B)
              | (IN1 & ((~OS & OF1 & IN) | (~OH & OF1 & IN)))
              | (OA4 & CIR_M & DIGIT_OF);
      OB1_r = CIR_K;
    
      OB2_s =   (CIR_I)
              | (HC & FAST_OUT & OC2)
              | (IN2 & ((~OS & OF1 & IN) | (~OH & OF1 & IN)))
              | (OA3 & CIR_M & DIGIT_OF);
      OB2_r =   (CIR_K)
              | (FAST_OUT & OC2 & HC);
                   
      OB3_s =   (CIR_P)
              | (CIR_W)
              | (IN3 & ((~OS & OF1 & IN) | (~OH & OF1 & IN)))
              | (OA2 & CIR_M & DIGIT_OF)
              | (CIR_U & OY & FAST_OUT & M19);
      OB3_r =   (CIR_Z)
              | (CIR_K);
                   
      OB4_s =   (IN4 & ((~OS & OF1 & IN) | (~OH & OF1 & IN)))
              | (OA1 & CIR_M & DIGIT_OF)
              | (FAST_OUT & TF & OB2);
      OB4_r =   (CIR_K)
              | (FAST_OUT & TF & ~OB2);
                   
      OB5_s =   (~OB1 & OB2 & OB3 & ~OB5 & OE & SLOW_OUT & DIGIT_OF)
              | (IN5 & ((~OS & OF1 & IN) | (~OH & OF1 & IN)))
              | (CIR_M & ~OD & DIGIT_OF & (SW_PUNCH | OC2 | OA1 | OA2 | OA3 | OA4));
      OB5_r =   (CIR_E & OB5)
              | (OE & SLOW_OUT & ~DIGIT_OF)
              | (READY);
    end
                
    sr_ff ff_OA1 ( .clk(CLOCK), .rst(rst), .s(OA1_s), .r(OA1_r), .q(OA1) );
    sr_ff ff_OA2 ( .clk(CLOCK), .rst(rst), .s(OA2_s), .r(OA2_r), .q(OA2) );
    sr_ff ff_OA3 ( .clk(CLOCK), .rst(rst), .s(OA3_s), .r(OA3_r), .q(OA3) );
    sr_ff ff_OA4 ( .clk(CLOCK), .rst(rst), .s(OA4_s), .r(OA4_r), .q(OA4) );
    sr_ff ff_OB1 ( .clk(CLOCK), .rst(rst), .s(OB1_s), .r(OB1_r), .q(OB1) );
    sr_ff ff_OB2 ( .clk(CLOCK), .rst(rst), .s(OB2_s), .r(OB2_r), .q(OB2) );
    sr_ff ff_OB3 ( .clk(CLOCK), .rst(rst), .s(OB3_s), .r(OB3_r), .q(OB3) );
    sr_ff ff_OB4 ( .clk(CLOCK), .rst(rst), .s(OB4_s), .r(OB4_r), .q(OB4) );
    sr_ff ff_OB5 ( .clk(CLOCK), .rst(rst), .s(OB5_s), .r(OB5_r), .q(OB5) );
    sr_ff ff_OS ( .clk(CLOCK), .rst(rst), .s(OS_s), .r(OS_r), .q(OS) );
endmodule
