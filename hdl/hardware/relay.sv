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
//
// This is a crude model of an electromechanical relay. Pull-in and release
// times are configurable. An alternate release time is also provided.
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

module relay #(
    parameter T1 = 10,   // operating time
    parameter T2 = 10,   // release time
    parameter T3 = 20    // alternate release time
    ) (
    input logic clk,
    input logic rst,
    input logic tick,
    input logic e,
    input logic ar,
    output logic c
    );
    
    // size the counter
    localparam W1 = ($clog2(T1) > $clog2(T2))? $clog2(T1) : $clog2(T2);
    localparam W  = (W1 > $clog2(T3))? W1 : $clog2(T3);
    logic [W-1:0] ctr, next_ctr;
    
    // state machine
    typedef enum logic [1:0] {OPEN, PULLED, PULLING, OPENING} state_t;
    state_t state, next_state;
    
    always_ff @(posedge clk) begin
      if (rst) begin
        ctr <= '0;
        state <= OPEN;
      end else begin
        ctr <= next_ctr;
        state <= next_state;
      end
    end
    
    always_comb begin
      next_ctr = (tick)? ctr - 1 : ctr;
      c = 0;
      
      case (state)
        OPEN: begin
          if (e) begin
            next_ctr = T1;
            next_state = PULLING;
          end else begin
            next_state = OPEN;
          end
        end
        
        PULLING: begin
          if (~e) begin
            // if e drops before pull-in completes, release immediately
            //next_ctr = 0;
            next_state = OPEN;
          end else if (tick && next_ctr == 0) begin
            next_state = PULLED;
          end else begin
            next_state = PULLING;
          end
        end
        
        PULLED: begin
          c = 1;
          if (~e) begin
            next_ctr = ar? T3 : T2;
            next_state = OPENING;
          end else begin
            next_state = PULLED;
          end
        end
        
        OPENING: begin
          c = 1;
          if (e) begin
            // if e is asserted before release completes, pull-in immediately
            //next_ctr = 0;
            next_state = PULLED;
          end else if (tick && next_ctr == 0) begin
            next_state = OPEN;
          end else begin
            next_state = OPENING;
          end
        end
        
      endcase
    end
    
endmodule
