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
// Electromechanical Relay with Configurable Operating and Release Times
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

module relay #(
    parameter T1 = 20,   // operating time
    parameter T2 = 10    // release time
    ) (
    input logic clk,
    input logic rst,
    input logic tick_ms,
    input logic pick,
    output logic pulled
    );
    
    // size the counter
    localparam W = ($clog2(T1) > $clog2(T2))? $clog2(T1) : $clog2(T2);
    logic [W-1:0] ctr, next_ctr;
    
    enum {OPEN = 0, PULLED = 1, PULLING = 2, OPENING = 3} state_t;
    logic [3:0] state, next_state;
    
    always_ff @(posedge clk) begin
      if (rst) begin
        ctr <= 0;
        state <= 0;
        state[OPEN] <= 1;
      end else begin
        state <= next_state;
        ctr <= next_ctr;
      end
    end
    
    always_comb begin
      next_state = 4'b0;
      next_ctr = (tick_ms)? ctr - 1 : ctr;
      pulled = 0;
      
      unique case (1'b1)
        state[OPEN]: begin
          if (pick) begin
            next_ctr = T1;
            next_state[PULLING] = 1;
          end else begin
            next_state[OPEN] = 1;
          end
        end
        
        state[PULLING]: begin
          if (~pick) begin
            next_ctr = 0;
            next_state[OPEN] = 1;
          end else if (tick_ms && next_ctr == 0) begin
            next_state[PULLED] = 1;
          end else begin
            next_state[PULLING] = 1;
          end
        end
        
        state[PULLED]: begin
          pulled = 1;
          if (~pick) begin
            next_ctr = T2;
            next_state[OPENING] = 1;
          end else begin
            next_state[PULLED] = 1;
          end
        end
        
        state[OPENING]: begin
          pulled = 1;
          if (pick) begin
            next_ctr = 0;
            next_state[PULLED] = 1;
          end else if (tick_ms && next_ctr == 0) begin
            next_state[OPEN] = 1;
          end else begin
            next_state[OPENING] = 1;
          end
        end
        
      endcase
    end
    
endmodule
