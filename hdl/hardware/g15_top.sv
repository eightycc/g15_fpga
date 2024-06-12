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
// Bendix G-15 Top Level Module
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

module g15_top (
    input  logic rst,
    input  logic CLOCK,

    // IBM I/O Writer Connector PL1 to ANC-2 Alphanumeric Coupler
    output logic PL1_18_AN,         // AS
    output logic PL1_33_TYPE,       // TYPE
    output logic PL1_29_EXC,        // TYPE_PULSE
    output logic PL1_26_LEV1_IN,    // OB1
    output logic PL1_25_LEV2_IN,    // OB2
    output logic PL1_24_LEV3_IN,    // OB3
    output logic PL1_23_LEV4_IN,    // OB4
    output logic PL1_27_LEV5_IN,    // OB5 & (~AS | ~OY & OH)
    // Function key inputs. When a function key is pressed and the ENABLE switch
    // is on, the key signal will last ~40-60 ms. This is the total time that the
    // typewriter escapement keeps the key contacts closed.  
    input  logic PL1_2_KEY_CIR_S,   // <Ⓢ>
    input  logic PL1_1_KEY_A,       // <A>
    input  logic PL1_22_KEY_B,      // <B>
    input  logic PL1_21_KEY_C,      // <C>
    input  logic PL1_20_KEY_E,      // <E>
    input  logic PL1_3_KEY_F,       // <F>
    input  logic PL1_5_KEY_I,       // <I>
    input  logic PL1_6_KEY_M,       // <M>
    input  logic PL1_7_KEY_P,       // <P>
    input  logic PL1_8_KEY_Q,       // <Q>
    input  logic PL1_9_KEY_R,       // <R>
    input  logic PL1_10_KEY_T,      // <T>
    input  logic PL1_11_SA,         // <SA> = ~RY10(TYPE) & RY12(SA)
    input  logic PL1_28_REWIND,     // <REWIND>
    input  logic PL1_4_PUNCH,       // <PUNCH>
    input  logic PL1_30_GO,         // <GO>
    input  logic PL1_31_NO_GO,      // <~GO>
    input  logic PL1_32_BP,         // <BP>
    input  logic PL1_13_LEV1_OUT,   // LEV1
    input  logic PL1_14_LEV2_OUT,   // LEV2
    input  logic PL1_15_LEV3_OUT,   // LEV3 = TYPE? SP|CR|TAB|SA : encoder bit 3
                                    // Provides feedback for typewriter magnets that
                                    // do not echo through ANC-2 decoder.
    input  logic PL1_16_LEV4_OUT,   // LEV4
    input  logic PL1_12_LEV5_OUT,   // LEV5
    input  logic PL1_17_F_B,        // <F-B>

    // Card Reader/Punch I/O
    input logic CARD_INPUT1, CARD_INPUT2, CARD_INPUT3, CARD_INPUT4, CARD_INPUT5,
    input logic CARD_SIGN,
    output logic CARD_READ_PULSE,
    output logic CARD_READ_SIGNAL,
    output logic CARD_PUNCH_PULSE,
    output logic CARD_PUNCH_SIGNAL,

    // Magnetic Tape I/O
    input logic MAG1_IN, MAG2_IN, MAG3_IN, MAG4_IN, MAG5_IN,
    output logic MAG1_OUT, MAG2_OUT, MAG3_OUT, MAG4_OUT, MAG5_OUT, MAG6_OUT,
    output logic MAG_TAPE_STOP,
    output logic MAG_TAPE_FWD,
    output logic MAG_TAPE_REV,

    // Built-in Photoelectric Tape Reader I/O connector PL6
    input logic PL6_PHOTO1, PL6_PHOTO2, PL6_PHOTO3, PL6_PHOTO4, PL6_PHOTO5,
    output logic PL6_PHOTO_TAPE_FWD,      // PL6-9  to relay RY-A
    output logic PL6_PHOTO_TAPE_REV,      // PL6-10 to relay RY-B
    // PL6_REMOTE_REWIND connects to  on the typewriter adapter. When
    // closed, it energizes R4-C, starting the reverse motor and disabling the
    // REWIND position of SWITCH_1 on the photo reader.
    //output logic PL6_REMOTE_REWIND,       // PLM6-11 to relay RY-B
    //input logic PL6_WAIT_FOR_TAPE,        // PL6-18 when RY-A or RY-B is energized
    //input logic PL6_TAPE_RUN_SW,          // PL6-17 to punch

    // Additional Photoelectric Tape Reader I/O
    input logic PHOTO_READER_PERMIT,
    output logic PHOTO_READER_FWD,
    output logic PHOTO_READER_REV,

    // Tape Punch I/O
    input logic PUNCHED_TAPE1, PUNCHED_TAPE2, PUNCHED_TAPE3, PUNCHED_TAPE4, PUNCHED_TAPE5,
    input logic PUNCH_SYNC,
    output logic PUNCH_SIGNAL,
    
    // Maintenance Panel Keys
    input logic MP_CLR_M19,
    input logic MP_SET_M19,
    input logic MP_CLR_M23,
    input logic MP_CLR_NT,
    input logic MP_SET_OP,
    input logic MP_SET_NT,

    // Turn-on Cycle Controls
    input logic PWR_CLEAR,
    input logic PWR_NO_CLEAR,
    input logic PWR_OP,
    input logic PWR_NO_OP,
    input logic PWR_ATS,
    input logic PWR_NT,

    // Card Adapter
    input logic CRP_CQ_s,

    // DA-1
    input logic GO,
    input logic DA1_M17,
    input logic DA_OVFLW,

    // Accessory interface on connectors PL19 and PL20
    input logic PL19_INPUT,
    input logic PL19_READY_IN,
    input logic PL20_READY_OUT,
    output logic PL19_SHIFT_CMD_M20,
    output logic PL19_WRITE_PULSE,
    output logic PL19_START_INPUT,
    output logic PL19_STOP_INPUT,
    output logic PL19_SHIFT_CMD,
    output logic PL20_OUTPUT,
    output logic PL20_OUTPUT_SHIFT,

    // Debugging Assists
    //   Timing
    output T0, T1, T29,
    //   CPU
    output C1, C2, C3, C4, C5, C6, C7, C8, C9, CU, CV, CW, CX,
    output CM
);

    // Timing
    logic T2, T13, T21, T28;
    logic TE, TF, TS;

    // CPU
    logic D0, D1, D2, D3, D4, D5, DU, DV, DW, DX;
    logic S0, S1, S2, S3, S4, S5, S6, S7, SU, SV, SW, SX;

    logic AR;
    logic CC, CE, CF, CN;
    logic DS;
    //logic EB;
    logic LB;
    //logic RC;
    logic TR;
    logic KEY_MARK;

    // Memory
    logic M0, M1, M2, M3, M19, M20, M23, MC_not;

    // I/O
    logic AS;
    logic TYPE;
    logic TYPE1, TYPE2, TYPE3, TYPE4, TYPE5;
    logic TYPE_PULSE;
    logic CIR_1, CIR_2, CIR_3, CIR_4;
    logic CIR_ALPHA, CIR_BETA, CIR_EPSILON, CIR_GAMMA, CIR_DELTA;
    logic CIR_V;
    logic OB1, OB2, OB3, OB4, OB5;
    logic OH, OY;
    logic READY;
    logic TAPE_START;
    logic EB0, EB1, EB2, EB3, EB4, EB5, EB6, EB7, EB8, EB9;
    logic EB10, EB11, EB12, EB13, EB14, EB15, EB16, EB17, EB18, EB19;
    logic EB21, EB22, EB23, EB25, EB26, EB27, EB31;

    // Typewriter Switches
    logic SW_GO;
    logic SW_NO_GO;
    logic SW_BP;
    logic SW_PUNCH;
    logic SW_REWIND;
    logic SW_SA;

    // Typewriter Keys
    logic KEY_A;
    logic KEY_B;
    logic KEY_C;
    logic KEY_E;
    logic KEY_F;
    logic KEY_FB;
    logic KEY_I;
    logic KEY_M;
    logic KEY_P;
    logic KEY_Q;
    logic KEY_R;
    logic KEY_CIR_S;
    logic KEY_T;

    always_comb begin
      PL1_18_AN = AS;
      PL1_33_TYPE = TYPE;
      PL1_29_EXC = TYPE_PULSE;
      PL1_26_LEV1_IN = OB1;
      PL1_25_LEV2_IN = OB2;
      PL1_24_LEV3_IN = OB3;
      PL1_23_LEV4_IN = OB4;
      PL1_27_LEV5_IN = OB5 & (~AS | ~OY & OH);
      KEY_CIR_S = PL1_2_KEY_CIR_S;
      KEY_A = PL1_1_KEY_A;
      KEY_B = PL1_22_KEY_B;
      KEY_C = PL1_21_KEY_C;
      KEY_E = PL1_20_KEY_E;
      KEY_F = PL1_3_KEY_F;
      KEY_I = PL1_5_KEY_I;
      KEY_M = PL1_6_KEY_M;
      KEY_P = PL1_7_KEY_P;
      KEY_Q = PL1_8_KEY_Q;
      KEY_R = PL1_9_KEY_R;
      KEY_T = PL1_10_KEY_T;
      SW_SA = PL1_11_SA;
      SW_REWIND = PL1_28_REWIND;
      SW_PUNCH = PL1_4_PUNCH;
      SW_GO = PL1_30_GO;
      SW_NO_GO = PL1_31_NO_GO;
      SW_BP = PL1_32_BP;
      TYPE1 = PL1_13_LEV1_OUT;
      TYPE2 = PL1_14_LEV2_OUT;
      TYPE3 = PL1_15_LEV3_OUT;
      TYPE4 = PL1_16_LEV4_OUT;
      TYPE5 = PL1_12_LEV5_OUT;
      KEY_FB = PL1_17_F_B;
    end

    timing timing_inst (.*);
    cpu_top cpu_top_inst (.*);
    mem_top mem_top_inst (.*);
    io_top io_top_inst (.*);

endmodule
