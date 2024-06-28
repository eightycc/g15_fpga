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
`include "g15_config.vh"

module g15_top (
    input  logic rst,
    input  logic CLOCK,
    input  logic tick_ms,

    // Front Panel
    input  logic SW_DC_RESET,
    input  logic SW_DC_OFF,
    output logic LITE_DC_ON,
    output logic LITE_READY,

    // Remote Neon Panel Connector PL-14
    output logic PL14_1_CQ,
    output logic PL14_2_C7,
    output logic PL14_3_C8,
    output logic PL14_4_C9,
    output logic PL14_5_CU,
    output logic PL14_6_CV,
    output logic PL14_7_CG,
    output logic PL14_8_C2,
    output logic PL14_9_C3,
    output logic PL14_10_C4,
    output logic PL14_11_C5,
    output logic PL14_12_C6,
    output logic PL14_13_CD1,
    output logic PL14_14_CW,
    output logic PL14_15_CX,
    output logic PL14_16_C1,
    output logic PL14_17_FO,
    output logic PL14_18_CH,
    output logic PL14_19_OC1,
    output logic PL14_20_OC2,
    output logic PL14_21_READY,
    output logic PL14_22_OC3,
    output logic PL14_23_IP,
    output logic PL14_24_OC4,
    output logic PL14_28_CD2,
    output logic PL14_29_CD3,
    output logic PL14_30_GO,
`ifdef G15_GROUP_III
    output logic PL14_32_AS,
`endif

    // IBM I/O Writer Connector PL1 to NC-1, ANC-1, or ANC-2 Typewriter Coupler
`ifdef G15_GROUP_III
    output logic PL1_18_AN,         // AS
`endif
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
`ifdef G15_GROUP_III
    input  logic PL1_20_KEY_E,      // <E>
`endif
`ifdef G15_GROUP_I
    input  logic PL1_3_KEY_F,       // <F>
`endif
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

    // Built-in Photoelectric Tape Reader I/O Connector PL6
    input  logic PL6_1_PHOTO1,
    input  logic PL6_2_PHOTO2,
    input  logic PL6_4_PHOTO3,
    input  logic PL6_5_PHOTO4,
    input  logic PL6_7_PHOTO5,
    output logic PL6_9_PHOTO_TAPE_FWD,      // PL6-9  to relay RY-A
    output logic PL6_10_PHOTO_TAPE_REV,     // PL6-10 to relay RY-B
    // PL6_11_REMOTE_REWIND connects to  on the typewriter adapter. When
    // closed, it energizes R4-C, starting the reverse motor and disabling the
    // REWIND position of SWITCH_1 on the photo reader.
    output logic PL6_11_REMOTE_REWIND,      // PL6-11 to relay RY-B
    input  logic PL6_18_WAIT_FOR_TAPE,      // PL6-18 when RY-A or RY-B is energized
    input  logic PL6_17_TAPE_RUN_SW,        // PL6-17 to punch

    // Card Reader/Punch I/O
    input  logic CARD_INPUT1, CARD_INPUT2, CARD_INPUT3, CARD_INPUT4, CARD_INPUT5,
    input  logic CARD_SIGN,
    output logic CARD_READ_PULSE,
    output logic CARD_READ_SIGNAL,
    output logic CARD_PUNCH_PULSE,
    output logic CARD_PUNCH_SIGNAL,

    // Magnetic Tape I/O
    input  logic MAG1_IN, MAG2_IN, MAG3_IN, MAG4_IN, MAG5_IN,
    output logic MAG1_OUT, MAG2_OUT, MAG3_OUT, MAG4_OUT, MAG5_OUT, MAG6_OUT,
    output logic MAG_TAPE_STOP,
    output logic MAG_TAPE_FWD,
    output logic MAG_TAPE_REV,

    // Additional Photoelectric Tape Reader I/O
`ifdef G15_PR_1
    input  logic PHOTO_READER_PERMIT,
`endif
    output logic PHOTO_READER_FWD,
    output logic PHOTO_READER_REV,

    // Tape Punch I/O
    input  logic PUNCHED_TAPE1, PUNCHED_TAPE2, PUNCHED_TAPE3, PUNCHED_TAPE4, PUNCHED_TAPE5,
    input  logic PUNCH_SYNC,
    output logic PUNCH_SIGNAL,
    
    // Maintenance Panel Keys
    input  logic MP_CLR_M19,
    input  logic MP_SET_M19,
    input  logic MP_CLR_M23,
    input  logic MP_CLR_NT,
    input  logic MP_SET_OP,
    input  logic MP_SET_NT,

`ifdef G15_CA_2
    // Card Adapter
    input  logic CRP_CQ_s,
`endif

    // DA-1
    input  logic GO,
    input  logic DA1_M17,
    input  logic DA_OVFLW,

    // Accessory interface on connectors PL19 and PL20
    input  logic PL19_INPUT,
    input  logic PL19_READY_IN,
    input  logic PL20_READY_OUT,
    output logic PL19_SHIFT_CMD_M20,
    output logic PL19_WRITE_PULSE,
    output logic PL19_START_INPUT,
    output logic PL19_STOP_INPUT,
    output logic PL19_SHIFT_CMD,
    output logic PL20_OUTPUT,
    output logic PL20_OUTPUT_SHIFT,

    // Debugging Assists
    //   Timing
    output logic T0, T1, T29,
    output logic TE, TF,
    //   CPU
    output logic C1, C2, C3, C4, C5, C6, C7, C8, C9, CU, CV, CW, CX,
    //   Drum Memory Tracks
    output logic AA,
    output logic CN_in,
    output logic CM_in,
    output logic MZ_in,
    output logic ID_in,
    output logic MQ_in,
    output logic PN_in,
    output logic M0_in, M1_in, M2_in, M3_in, M4_in, M5_in, M6_in,
    output logic M7_in, M8_in, M9_in, M10_in, M11_in,
    output logic M12_in, M13_in, M14_in, M15_in, M16_in, M17_in, M18_in,
    output logic M19_in, M20_in, M21_in, M22_in, M23_in,
    //   Buses
    output logic EB,
    output logic IB,
    output logic LB
);
    // Turn-on Cycle Controls
    logic PWR_CLEAR;
    logic PWR_NO_CLEAR;
    logic PWR_OP;
    logic PWR_NO_OP;
    logic PWR_AUTO_TAPE_START;
    logic PWR_NT;
    logic WAIT_FOR_TAPE;

    // Timing
    logic T2, T13, T21, T28;
    logic TS;

    // CPU
    logic D0, D1, D2, D3, D4, D5, DU, DV, DW, DX;
    logic S0, S1, S2, S3, S4, S5, S6, S7, SU, SV, SW, SX;

    logic AR;
    logic CC, CE, CF, CG, CH, CM, CN, CQ;
    logic DS;
    logic FO;
    logic IP;
    //logic LB;
    logic TR;
    logic KEY_MARK;

    // Memory
    logic M0, M1, M2, M3, M19, M20, M23, MC_not;
    logic CD1, CD2, CD3;

    // I/O
`ifdef G15_GROUP_III
    logic AS;
`endif
    logic TYPE;
    logic TYPE1, TYPE2, TYPE3, TYPE4, TYPE5;
    logic TYPE_PULSE;
    logic CIR_1, CIR_2, CIR_3, CIR_4;
    logic CIR_ALPHA, CIR_BETA, CIR_EPSILON, CIR_GAMMA, CIR_DELTA;
    logic CIR_V;
    logic OB1, OB2, OB3, OB4, OB5;
    logic OC1, OC2, OC3, OC4;
`ifdef G15_GROUP_III
    logic OH;
    logic OY;
`endif
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
`ifdef G15_GROUP_III
    logic KEY_E;
`endif
`ifdef G15_GROUP_I
    logic KEY_F;
`endif
    logic KEY_FB;
    logic KEY_I;
    logic KEY_M;
    logic KEY_P;
    logic KEY_Q;
    logic KEY_R;
    logic KEY_CIR_S;
    logic KEY_T;

    // Built-in Phototape Reader
    logic PHOTO1, PHOTO2, PHOTO3, PHOTO4, PHOTO5;
    logic PHOTO_TAPE_FWD;
    logic PHOTO_TAPE_REV;

    always_comb begin
      WAIT_FOR_TAPE = PL6_18_WAIT_FOR_TAPE;
    end

    always_comb begin
      PL14_1_CQ = CQ;
      PL14_2_C7 = C7;
      PL14_3_C8 = C8;
      PL14_4_C9 = C9;
      PL14_5_CU = CU;
      PL14_6_CV = CV;
      PL14_7_CG = CG;
      PL14_8_C2 = C2;
      PL14_9_C3 = C3;
      PL14_10_C4 = C4;
      PL14_11_C5 = C5;
      PL14_12_C6 = C6;
      PL14_13_CD1 = CD1;
      PL14_14_CW = CW;
      PL14_15_CX = CX;
      PL14_16_C1 = C1;
      PL14_17_FO = FO;
      PL14_18_CH = CH;
      PL14_19_OC1 = OC1;
      PL14_20_OC2 = OC2;
      PL14_21_READY = READY;
      PL14_22_OC3 = OC3;
      PL14_23_IP = IP;
      PL14_24_OC4 = OC4;
      PL14_28_CD2 = CD2;
      PL14_29_CD3 = CD3;
      PL14_30_GO = GO;
`ifdef G15_GROUP_III
      PL14_32_AS = AS;
`endif
    end

    always_comb begin
`ifdef G15_GROUP_III
      PL1_18_AN = AS;
`endif
      PL1_33_TYPE = TYPE;
      PL1_29_EXC = TYPE_PULSE;
      PL1_26_LEV1_IN = OB1;
      PL1_25_LEV2_IN = OB2;
      PL1_24_LEV3_IN = OB3;
      PL1_23_LEV4_IN = OB4;
`ifdef G15_GROUP_III
      PL1_27_LEV5_IN = OB5 & (~AS | ~OY & OH);
`else
      PL1_27_LEV5_IN = OB5;
`endif
      KEY_CIR_S = PL1_2_KEY_CIR_S;
      KEY_A = PL1_1_KEY_A;
      KEY_B = PL1_22_KEY_B;
      KEY_C = PL1_21_KEY_C;
`ifdef G15_GROUP_III
      KEY_E = PL1_20_KEY_E;
`endif
`ifdef G15_GROUP_I
      KEY_F = PL1_3_KEY_F;
`endif
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

    always_comb begin
      PHOTO1 = PL6_1_PHOTO1;
      PHOTO2 = PL6_2_PHOTO2;
      PHOTO3 = PL6_4_PHOTO3;
      PHOTO4 = PL6_5_PHOTO4;
      PHOTO5 = PL6_7_PHOTO5;
      PL6_9_PHOTO_TAPE_FWD = PHOTO_TAPE_FWD;
      PL6_10_PHOTO_TAPE_REV = PHOTO_TAPE_REV;
      PL6_11_REMOTE_REWIND = SW_REWIND;
    end

    turn_on turn_on_inst (.*);
    timing timing_inst (.*);
    cpu_top cpu_top_inst (.*);
    mem_top mem_top_inst (.*);
    io_top io_top_inst (.*);

endmodule
