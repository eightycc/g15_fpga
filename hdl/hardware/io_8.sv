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
// Bendix G-15 Input Output 8 (Page 5, 3D591)
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

module io_8 (

    input logic PHOTO_READER_PERMIT,
    input logic PL6_PHOTO_TAPE_FWD,
    input logic FAST_IN, FAST_OUT,
    input logic SLOW_IN, SLOW_OUT,
    input logic SW_PUNCH,
    input logic CIR_F,
    input logic DS,
    input logic S3, SW,
    input logic OA1, OA2, OA3, OA4,
    input logic OB3,
    input logic OC1, OC2,
    input logic OF1, OF2, OF3,
    input logic OD,
    input logic OE,
    input logic OG,
    input logic OY,
    input logic STOP_OB,
    input logic TYPE,

    output logic CARD_PUNCH_SIGNAL,
    output logic CARD_READ_PULSE,
    output logic CARD_READ_SIGNAL,
    output logic CARD_PUNCH_PULSE,
    output logic MAG1_OUT, MAG2_OUT, MAG3_OUT, MAG4_OUT, MAG5_OUT,
    output logic PHOTO_READER_FWD,
    output logic PHOTO_READER_REV,
    output logic PL6_PHOTO_TAPE_REV,
    output logic PUNCH_SIGNAL,
    output logic TYPE_PULSE,

    output logic CIR_B,
    output logic CIR_I,
    output logic CIR_P
);

    logic MAG_OUT;

    always_comb begin
      CIR_B = CIR_F & SLOW_OUT & ~STOP_OB & OF1 & (OF2 | OF3);
      CIR_I = CIR_F & SLOW_OUT & ~STOP_OB & OF2 & (OF2 | OF3);
      CIR_P = CIR_F & SLOW_OUT & ~STOP_OB & OF3 & (OF2 | OF3);

      CARD_PUNCH_SIGNAL = SLOW_OUT & OC1 & OC2;
      CARD_PUNCH_PULSE = CARD_PUNCH_SIGNAL & TYPE & ~OD & ~OE & OY;
      CARD_READ_PULSE = DS & S3 & SW;
      CARD_READ_SIGNAL = SLOW_IN & ~OC1 & OC2;

      PUNCH_SIGNAL =   (SLOW_OUT & OG & SW_PUNCH & OG)
                     | (SLOW_OUT & OG & ~OC1 & OC2);

      PL6_PHOTO_TAPE_REV = FAST_IN & OC2;
      PHOTO_READER_REV = PL6_PHOTO_TAPE_REV & PHOTO_READER_PERMIT;
      PHOTO_READER_FWD = PL6_PHOTO_TAPE_FWD & PHOTO_READER_PERMIT;

      TYPE_PULSE = TYPE & ~OD & ~OE & OY & ~OC2;

      MAG_OUT = FAST_OUT & OY & ~OG & OC1 & ~OC2;
      MAG1_OUT =   (MAG_OUT & OA4)
                 | (MAG_OUT & OB3 & ~OF1);
      MAG2_OUT =   (MAG_OUT & OA3);
      MAG3_OUT =   (MAG_OUT & OA2);
      MAG4_OUT =   (MAG_OUT & OA1);
      MAG5_OUT =   (MAG_OUT & OF1);
    end
endmodule
