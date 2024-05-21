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
// Bendix G-15 CPU Top Level Module
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

module cpu_top (
    input logic rst,
    input logic CLOCK,
    input logic CR,
    
    // Timing
    input logic T0, T1, T2, T13, T21, T28, T29,
    input logic TE,
    input logic TF,
    input logic TS,
    
    // Memory
    input logic M0,
    input logic M1,
    input logic M2,
    input logic M19,
    input logic M20,
    input logic MC_not,
    
    // Typewriter Switches
    input logic SW_GO,
    input logic SW_NO_GO,
    input logic SW_BP,
    input logic SW_PUNCH,
    input logic SW_SA,
    
    // Typewriter Keys
    input logic KEY_F,
    input logic KEY_I,
    input logic KEY_M,
    input logic KEY_R,

    // Maintenance Panel
    input logic MP_CLR_NT,
    input logic MP_SET_OP,
    input logic MP_SET_NT,
    
    // Power Sequencing
    input logic PWR_CLEAR,
    input logic PWR_NO_CLEAR,
    input logic PWR_OP,
    input logic PWR_NO_OP,
    input logic PWR_ATS,
    input logic PWR_NT,
    
    // Punch Card Adapter
    input logic CRP_CQ_s,
    
    // DA-1
    input logic GO,
    input logic DA_OVFLW,
    
    // Magnetic Tape Adapter
    input logic CIR_1, CIR_2, CIR_3, CIR_4,
    
    // I/O
    input logic CIR_ALPHA,
    input logic CIR_BETA,
    input logic CIR_EPSILON,
    input logic CIR_GAMMA,
    input logic CIR_DELTA,
    input logic CIR_V,
    input logic READY,
    input logic EB19,
    input logic EB23,
    
    // Memory
    input logic EB0, EB1, EB2, EB3, EB4, EB5, EB6, EB7, EB8, EB9,
    input logic EB10, EB11, EB12, EB13, EB14, EB15, EB16, EB17, EB18,
    input logic EB21, EB22, EB25, EB26, EB27, EB31,
    //output logic EB,

    // Accumulator Register
    output logic AR,
    output logic LB,
    
    // Control Gate
    output logic CC,
    output logic CE,
    output logic CF,
    output logic CJ,
    output logic CM,
    output logic CN,
    output logic RC,
    output logic TR,
    output logic KEY_MARK,
    
    // Control Switch
    output logic C1, C7, C8, C9, CU, CV, CW, CX,
    output logic D0, D1, D2, D3, D4, D5, DU, DV, DW, DX,
    output logic S0, S1, S2, S3, S4, S5, S6, S7, SU, SV, SW, SX,
    output logic DS,

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
    
    // Accumulator Register
    logic AA;
    logic AC;
    logic AC_s;
    logic EB32;

    // Control Switch
    logic C3, C5, C6;
    logic D6, D7;
    logic EB29;

    // Control Gate            
    logic CI;
    logic CS;
    
    logic CQ;    
    logic FO;
    logic IB;
    logic IC;
    logic IS;
    logic TR_r;
    logic KEY_RETURN;

    // Product Gate
    logic PA;
    logic PC;
    logic PG_CLEAR;
    logic PJ;
    logic PM;
    logic PP;
    logic CIR_X;
    logic EB28_29, EB30_31;

    // Invert Gate EB
    //logic EB;
        
    acc_reg acc_reg_inst (.*);
    control_gate control_gate_inst (.*);
    control_switch control_switch_inst (.*);
    invert_gate_eb invert_gate_eb_inst (.*);
    prod_gate prod_gate_inst (.*);

endmodule