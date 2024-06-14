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
// Bendix G-15 Magnetic Drum Track
// ----------------------------------------------------------------------------
`include "g15_config.vh"

module drum_track (
    input  logic clk,
    input  logic din,
    output logic dout
);
    
    parameter N = 29;
    parameter V = 0;
    
    logic [N-1:0] dreg = V;
    logic [N-1:0] dnext;
    
    always_ff @(posedge clk)
      begin
        dreg <= dnext;
      end
    
    always_comb begin
      dnext = {din, dreg[N-1:1]};
      dout = dreg[0];
    end
    
endmodule
