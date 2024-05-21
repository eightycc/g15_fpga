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
    input logic rst,
    input logic CLOCK,

    // Typewriter Switches
    input logic SW_GO,
    input logic SW_NO_GO,
    input logic SW_BP,
    input logic SW_PUNCH,
    //input logic SW_REWIND,
    input logic SW_SA,

    // Typewriter Keys
    input logic KEY_A,
    input logic KEY_B,
    input logic KEY_C,
    input logic KEY_E,
    input logic KEY_F,
    input logic KEY_FB,
    input logic KEY_I,
    input logic KEY_M,
    input logic KEY_P,
    input logic KEY_Q,
    input logic KEY_R,
    input logic KEY_CIR_S,
    input logic KEY_T,

    // Typewriter I/O
    input logic TYPE1, TYPE2, TYPE3, TYPE4, TYPE5,
    output logic TYPE_PULSE,

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

    // Power cycle controls
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
    output logic PL20_OUTPUT_SHIFT
);

    // Timing
    logic T0, T1, T2, T13, T21, T28, T29;
    logic TE, TF, TS;

    // Gated command register shift clock
    logic CR;

    // CPU
    logic C1, C7, C8, C9, CU, CV, CW, CX;
    logic D0, D1, D2, D3, D4, D5, DU, DV, DW, DX;
    logic S0, S1, S2, S3, S4, S5, S6, S7, SU, SV, SW, SX;

    logic AR;
    logic CC, CE, CF, CJ, CM, CN;
    logic DS;
    //logic EB;
    logic LB;
    logic RC;
    logic TR;
    logic KEY_MARK;

    // Memory
    logic M0, M1, M2, M3, M19, M20, M23, MC_not;

    // I/O
    logic CIR_1, CIR_2, CIR_3, CIR_4;
    logic CIR_ALPHA, CIR_BETA, CIR_EPSILON, CIR_GAMMA, CIR_DELTA;
    logic CIR_V;
    logic READY;
    logic EB0, EB1, EB2, EB3, EB4, EB5, EB6, EB7, EB8, EB9;
    logic EB10, EB11, EB12, EB13, EB14, EB15, EB16, EB17, EB18, EB19;
    logic EB21, EB22, EB23, EB25, EB26, EB27, EB31;

    // Gated command register shift clock
    always_comb begin
      CR = RC & CJ & CLOCK;
    end

    timing timing_inst (.*);
    cpu_top cpu_top_inst (.*);
    mem_top mem_top_inst (.*);
    io_top io_top_inst (.*);

endmodule
