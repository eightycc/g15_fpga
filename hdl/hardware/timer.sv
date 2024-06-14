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
// Monotonic Timer with Configurable Period
// ----------------------------------------------------------------------------
`include "g15_config.vh"

module timer #(
    parameter D = 108
) (
    input  logic clk,
    input  logic rst,
    output logic tick
);
    
    localparam W = $clog2(D-1);
    logic [W-1:0] ctr, next_ctr;
    
    always_ff @(posedge clk) begin
      if (rst) begin
        ctr <= D - 1;
      end else begin
        ctr <= next_ctr;
      end
    end
    
    always_comb begin
      next_ctr = (ctr == 0)? D - 1 : ctr - 1;
      tick = (ctr == 0)? 1 : 0;
    end
    
endmodule
