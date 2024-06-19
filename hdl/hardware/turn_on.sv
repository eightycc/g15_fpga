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
// Bendix G-15 Turn-on Cycle Sequencer
//
// The G-15 turn-on cycle consists of two parts: Tube warm-up and D.C. reset.
//
// This implementation assumes that tubes are warmed up. It begins D.C. reset
// as soon as the D.C. reset button is pressed.
//
// D.C. reset entails several steps that are sequenced by a motor-driven
// multiple section wafer switch 7. D.C. reset concludes by illuminating the
// READY lamp. At this point, the G-15 is fully initialized with a program
// block loaded and ready to execute.
// ----------------------------------------------------------------------------
`include "g15_config.vh"

module turn_on (
    input  logic rst,
    input  logic CLOCK,
    input  logic tick_ms,

    input  logic SW_DC_RESET,           // Front panel D.C. reset button
    input  logic SW_DC_OFF,             // Front panel D.C. off button
    input  logic WAIT_FOR_TAPE,         // Wait signal from phototape reader
    output logic LITE_DC_ON,            // Front panel D.C. on lamp
    output logic LITE_READY,            // Front panel READY lamp
    output logic PWR_AUTO_TAPE_START,   // <AUTO TAPE START>
    output logic PWR_NT,                // <NT>
    output logic PWR_NO_CLEAR,          // ~<CLEAR>
    output logic PWR_CLEAR,             // <CLEAR>
    output logic PWR_NO_OP,             // ~<OP>
    output logic PWR_OP                 // <OP>
);
    // TM2 motor-driven multiple section wafer switch 7
    localparam TM2_MS = 9996;
    localparam TM2_CTR_W = $clog2(TM2_MS);
    logic [TM2_CTR_W-1:0] tm2_ctr, tm2_ctr_next;
    logic tm2_run;
    // Wafer switch 7 contacts
    logic sw7_1_6, sw7_1_9;
    logic sw7_2_1, sw7_2_12;
    logic sw7_3a_3, sw7_3a_4;
    logic sw7_3b_1, sw7_3b_2, sw7_3b_5, sw7_3b_6, sw7_3b_8, sw7_3b_9;

    logic K3_e, K3;
    logic K4_e, K4;

    always_ff @(posedge CLOCK) begin
      if (rst) begin
        tm2_ctr <= '0;
      end else if (tick_ms) begin
        tm2_ctr <= tm2_ctr_next;
      end
    end

    // 1 rotation of wafer switch 7 is divided into 12 parts of 833 ms each.
    // Section 3a is out of phase with other switch sections by -1 part (833 ms).
    always_comb begin
      sw7_1_6 = (tm2_ctr >= 4998) & (tm2_ctr < 5831);   // 833 ms @ 6
      sw7_1_9 = (tm2_ctr >= 7497) & (tm2_ctr < 8330);   // 833 ms @ 9

      sw7_2_1 = (tm2_ctr >= 899) & (tm2_ctr < 1600);    // 701 ms @ 1 + 66 ms
      sw7_2_12 = (tm2_ctr >= 66) & (tm2_ctr < 767);     // 701 ms @ 12 + 66 ms

      sw7_3a_3 = ~((tm2_ctr >= 3332) & (tm2_ctr < 4165));
      sw7_3a_4 = ~((tm2_ctr >= 4165) & (tm2_ctr < 4998));

      sw7_3b_1 = (tm2_ctr >= 899) & (tm2_ctr < 1600);   // 701 ms @ 1 + 66 ms
      sw7_3b_2 = (tm2_ctr >= 1732) & (tm2_ctr < 2433);  // 701 ms @ 2 + 66 ms
      sw7_3b_5 = (tm2_ctr >= 4231) & (tm2_ctr < 4932);  // 701 ms @ 5 + 66 ms
      sw7_3b_6 = (tm2_ctr >= 5064) & (tm2_ctr < 5765);  // 701 ms @ 6 + 66 ms
      sw7_3b_8 = (tm2_ctr >= 6730) & (tm2_ctr < 7431);  // 701 ms @ 8 + 66 ms
      sw7_3b_9 = (tm2_ctr >= 7563) & (tm2_ctr < 8264);  // 701 ms @ 9 + 66 ms

      tm2_run =   (SW_DC_RESET | (~SW_DC_RESET & K3))
                & (sw7_1_6 | sw7_1_9 | ~WAIT_FOR_TAPE)
                & ~K4;

      tm2_ctr_next = tm2_run? ((tm2_ctr + 1) == TM2_MS)? '0 : tm2_ctr + 1 : tm2_ctr;   

      K3_e = sw7_2_1 | (K3 & ~SW_DC_OFF);
      K4_e = K3 & (sw7_2_12 | K4);

      LITE_DC_ON = K3;
      LITE_READY = K3 & K4;
      PWR_AUTO_TAPE_START = sw7_3b_6 | sw7_3b_9;
      PWR_NT = sw7_3b_8;
      PWR_NO_CLEAR = sw7_3a_3;
      PWR_NO_OP = sw7_3a_4;
      PWR_CLEAR = sw7_3b_1 | sw7_3b_2;
      PWR_OP = sw7_3b_5;

    end

    relay #(.T1(25), .T2(25)) RY_K3 (.*, .clk(CLOCK), .tick(tick_ms), .e(K3_e), .c(K3), .ar(0));
    relay #(.T1(25), .T2(25)) RY_K4 (.*, .clk(CLOCK), .tick(tick_ms), .e(K4_e), .c(K4), .ar(0));

endmodule
