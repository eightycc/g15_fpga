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
// Single-shot with configurable duration D in ticks.
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

module ss (
    input logic clk,
    input logic rst,
    input logic tick,
    input logic t,
    output logic s
);
    parameter D = 10;   // shot duration in ticks
    localparam W = $clog2(D);
    logic [W-1:0] ctr, next_ctr;

    always_ff @(posedge clk) begin
      if (rst) begin
        ctr <= D;
      end else begin
        if (tick) begin
            ctr <= t? D : next_ctr;
        end
      end
    end

    always_comb begin
      next_ctr = (ctr == 0)? 0 : ctr - 1;
      s = (ctr == 0)? 0 : 1;
    end
endmodule