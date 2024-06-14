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
// Set-Reset Flip-Flop with Clock-edge Triggering
// ----------------------------------------------------------------------------
`include "g15_config.vh"

module sr_ff (
    input  logic clk,
    input  logic rst,
    input  logic s,
    input  logic r,
    output logic q = 1'b0
    );
        
    always_ff @(posedge clk)
      if (rst) begin
        q <= 1'b0;
      end else begin
        case({s,r})
          2'b00: q <= q;
          2'b01: q <= 1'b0;
          2'b10: q <= 1'b1;
          2'b11: q <= 1'bx;
        endcase
      end
         
endmodule
