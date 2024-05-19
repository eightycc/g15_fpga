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
// Bendix G-15 Magnetic Tape Control (Page 15, 3D597)
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

module mag_tape_ctrl (
    input logic CX, CW,
    input logic DS,
    input logic S0, S1, S3, S7, SU, SV, SW,

    output logic CIR_1,
    output logic CIR_2,
    output logic CIR_3,
    output logic CIR_4,
    output logic MAG_TAPE_FWD,
    output logic MAG_TAPE_REV,
    output logic MAG6_OUT
);

    always_comb begin
      CIR_1 = CW & ~CX;
      CIR_2 = CX & ~CW;
      CIR_3 = CX & CW;
      CIR_4 = ~CX & ~CW;
      MAG_TAPE_FWD =   (DS & SV & S1)
                     | (DS & SV & S3)
                     | (DS & SW & S0);
      MAG_TAPE_REV =   (DS & SU & S1);
      MAG6_OUT = DS & SW & S7;
    end
endmodule
