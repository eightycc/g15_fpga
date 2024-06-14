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
// Bendix G-15 Memory Lines top level module
// ----------------------------------------------------------------------------
`include "g15_config.vh"

module mem_top (
    input  logic rst,
    input  logic CLOCK,

    input  logic C1, C8, CU, CV, CW, CX,
    input  logic D0, D1, D2, D3, D4, D5, DU, DV, DW, DX,
    input  logic S0, S1, S2, S3, S4, S5, S6, S7, SU, SV, SW, SX,
    input  logic DS,

    input  logic AR,
    input  logic CN,
    input  logic CM,
    input  logic TR,
    input  logic LB,
    input  logic KEY_MARK,
    
    input  logic GO,
    input  logic DA1_M17,

    input  logic SW_SA,
    input  logic KEY_C,

    input  logic CIR_1,
`ifdef G15_CA_2
    input  logic CIR_2,
`endif
    input  logic M19, M23,
    input  logic READY,
    input  logic TAPE_START,
    input  logic TYPE1, TYPE2, TYPE3,

    output logic CD1, CD2, CD3,

    output logic M0, M1, M2, M3, M20,
    
    output logic EB0, EB1, EB2, EB3, EB4, EB5, EB6,
    output logic EB7, EB8, EB9, EB10, EB11, EB12, EB13, EB14,
    output logic EB15, EB16, EB17, EB18,
    output logic EB21, EB22, EB25, EB26, EB27, EB31,
    output logic MC_not
);

`ifdef G15_CA_2
    logic M18;
`endif

    mem_0_6 mem_0_6_inst (.*);
    mem_7_18 mem_7_18_inst (.*);
    mem_20_21_22 mem_20_21_22_inst (.*);
endmodule
