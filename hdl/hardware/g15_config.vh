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
// Bendix G-15 Configuration
// ----------------------------------------------------------------------------
`ifndef _G15_CONFIG_VH_
`define _G15_CONFIG_VH_ 1

`timescale 1ns / 1ps

// G15 ECO Groups, see "G-15 Theory of Operations" page 2-66.
`define G15_GROUP_I 1
`define G15_GROUP_II 1
`define G15_GROUP_III 1
//`define G15_GROUP_IV 1
//`define G15_GROUP_V 1

`define G15_MTA_2 1             // Magnetic tape adapter model 2
`define G15_CA_2 1              // Punched card adapter model 2
`define G15_PR_1 1              // Additional phototape reader model 1
`define G15_ANC_2 1             // Typewriter alphanumeric coupler model 2

`endif // _G15_CONFIG_VH_
