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
// Bendix G-15 Input Output Section top level module
// ----------------------------------------------------------------------------
`include "g15_config.vh"

module io_top (
    input  logic rst,
    input  logic CLOCK,

`ifdef G15_GROUP_III
    output logic AS,
    input  logic C1,
    input  logic CF,
    input  logic KEY_E,
    output logic OH,
    output logic OY,
    input  logic T2,
    input  logic TE,
`endif
    output logic OB1, OB2, OB3, OB4, OB5,
    output logic OC1, OC2, OC3, OC4,
    output logic READY,

    // Turn-on Cycle Controls
    input  logic PWR_AUTO_TAPE_START,
    input  logic PWR_CLEAR,

    // Mantenance Panel Controls
    input  logic MP_CLR_M19,
    input  logic MP_SET_M19,
    input  logic MP_CLR_M23,

    // Typewriter Interface
    input  logic KEY_A,
    input  logic KEY_B,
    input  logic KEY_P,
    input  logic KEY_Q,
    input  logic KEY_CIR_S,
    input  logic KEY_T,

    input  logic SW_PUNCH,
    input  logic SW_SA,

    input  logic TYPE_FB,
    input  logic TYPE1, TYPE2, TYPE3, TYPE4, TYPE5,

    output logic TYPE,
    output logic TYPE_PULSE,

    // Built-in Phototape Reader
    input  logic PHOTO1, PHOTO2, PHOTO3, PHOTO4, PHOTO5,
    output logic PHOTO_TAPE_FWD, PHOTO_TAPE_REV,

    // Card Reader/Punch Interface
    input  logic CARD_INPUT1, CARD_INPUT2, CARD_INPUT3, CARD_INPUT4, CARD_INPUT5,
    input  logic CARD_SIGN,
    output logic CARD_READ_PULSE,
    output logic CARD_READ_SIGNAL,
    output logic CARD_PUNCH_PULSE,
    output logic CARD_PUNCH_SIGNAL,

    // Magnetic Tape Interface
    input  logic MAG1_IN, MAG2_IN, MAG3_IN, MAG4_IN, MAG5_IN,
    output logic MAG1_OUT, MAG2_OUT, MAG3_OUT, MAG4_OUT, MAG5_OUT, MAG6_OUT,
    output logic MAG_TAPE_STOP,
    output logic MAG_TAPE_FWD, MAG_TAPE_REV,

    // Photoelectric Tape Reader Interface
`ifdef G15_PR_1
    input  logic PHOTO_READER_PERMIT,
`endif
    output logic PHOTO_READER_FWD, PHOTO_READER_REV,

    // Tape Punch Interface
    input  logic PUNCHED_TAPE1, PUNCHED_TAPE2, PUNCHED_TAPE3, PUNCHED_TAPE4, PUNCHED_TAPE5,
    input  logic PUNCH_SYNC,
    output logic PUNCH_SIGNAL,

    // CPU interface
    input  logic AR,
    input  logic C7, C8, C9, CU, CV, CW, CX,
    input  logic D4, D5, DX,
    input  logic S0, S1, S2, S3, S4, S5, S7, SU, SV, SW, SX,

    input  logic LB,

    input  logic CC,
    input  logic DS,
    input  logic TR,

    output logic CIR_1, CIR_2, CIR_3, CIR_4,
    output logic CIR_ALPHA, CIR_BETA, CIR_DELTA, CIR_EPSILON, CIR_GAMMA,
    output logic CIR_V,
    output logic TAPE_START,

    // Drum interface
    input  logic CN,
    input  logic M2, M3,
    output logic M19, M23,
    output logic M19_in, M23_in,
    output logic MZ_in,
    output logic EB19, EB23,

    input  logic T0, T1, T21, T29,
    input  logic TF
);

    // I/O section local signals
`ifdef G15_GROUP_III
    logic AUTO;
`endif
    logic HC;
    logic OD;
    logic OE;
    logic OG;
`ifndef G15_GROUP_III
    logic OY;
`endif
    logic OS;
    logic OZ;

    logic MZ;

    logic OA1, OA2, OA3, OA4;
    logic OF1, OF2, OF3;
`ifdef G15_ANC_2
    logic OC_r;
`endif

    //logic CIR_ALPHA;   // (11) OE & OZ & SLOW_OUT & ~OC1 & ~OC2
    //logic CIR_BETA;    // (11) READY & KEY_T & OF2
    //logic CIR_DELTA;   // (11) ~T29 & CIR_BETA & CN
    //logic CIR_EPSILON; // (11) T0 & CIR_BETA
    //logic CIR_GAMMA;   // (11) CIR_ALPHA & CIR_V & M19_insert
    logic CIR_A;    // (5,6) ~OD & CIR_Q
    logic CIR_B;    // (8)
    logic CIR_C;    // (5,6) OG & OY & FAST_OUT
    logic CIR_D;    // (5,6) OD & CIR_Q
    logic CIR_E;    // (5,6) TF & IN & ~OF1 & OF2
    logic CIR_F;    // (5,6) T0 & OE
    logic CIR_G;    // (5,6) T0 & ~OE
    logic CIR_H;    // (1,2)  (OY & ~OG & FAST_OUT & ~OB2 & OB4)
                    //      | (OY & ~OG & FAST_OUT & OC1 & ~OC2)
    logic CIR_I;    // (8)
    logic CIR_K;    // (5,6) OC_r | (STOP_OB & SLOW_OUT & OE & OZ) | (CIR_E & FAST_IN)
                    //            | (CIR_E & STOP_OB)
    logic CIR_L;    // (5,6) CIR_M & OS & SIGN_OF
    logic CIR_M;    // (5,6) CIR_N & SLOW_OUT & ~OE
    logic CIR_N;    // (5,6) T1 & OZ
    logic CIR_O;    // (5,6) ~TF & OG & IN
    logic CIR_P;    // (8)
    logic CIR_Q;    // (5,6) ~AS & OG & SLOW_OUT & STOP_OB
    logic CIR_R;    // (5,6) CIR_T & CIR_V
    logic CIR_S;    // (5,6) CIR_E & SLOW
    logic CIR_T;    // (5,6) OE & CIR_U & SLOW_OUT
    logic CIR_U;    // (11)  OC1 | OC2
    //logic CIR_V;    // (11)  CR_TAB_OF | WAIT_OF | DIGIT_OF
    logic CIR_W;    // (3,4) CIR_U & CIR_F & ~OY & FAST_OUT & ~OB3
    logic CIR_Y;    // (5,6) (CIR_ALPHA & CIR_V) | (CIR_C) | (CIR_O) | (CIR_R)
    logic CIR_Z;    // (5,6) ~OY & ~OG & TF & FAST_OUT & OB3

    logic IN, FAST_IN, SLOW_IN;
    logic OUT, FAST_OUT, SLOW_OUT;
    logic FAST;
    //logic READY;

    logic STOP_OB, TAB_OB, CR_TAB_OB, WAIT_OB;
    logic DIGIT_OF, CR_TAB_OF, WAIT_OF, SIGN_OF;
    //logic TYPE;

    io_1_2 io_1_2 (.*);
    io_3_4 io_3_4 (.*);
    io_5_6 io_5_6 (.*);
    io_8 io_8 (.*);
    io_11_mz io_11_mz (.*);
    mag_tape_ctrl mag_tape_ctrl (.*);

endmodule