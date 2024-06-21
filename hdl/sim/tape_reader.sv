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
// Bendix G-15 Photo Tape Reader
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

module tape_reader (
    input  logic clk,
    input  logic rst,
    
    input  logic tick_ms,
    
    output logic PL6_1_PHOTO1, PL6_2_PHOTO2, PL6_4_PHOTO3, PL6_5_PHOTO4, PL6_7_PHOTO5,
    input  logic PL6_9_PHOTO_TAPE_FWD,      // PL6-9  to relay RY-A
    input  logic PL6_10_PHOTO_TAPE_REV,     // PL6-10 to relay RY-B
    input  logic PL6_11_REMOTE_REWIND,      // connects to SW_REWIND on the typewriter adapter. When
    // closed, it energizes R4-C, starting the reverse motor and disabling the
    // REWIND position of SWITCH_1 on the photo reader.
    output logic PL6_18_WAIT_FOR_TAPE,      // PL6-18 when RY-A or RY-B is energized
    output logic PL6_17_TAPE_RUN_SW,        // PL6-17 to punch
    input  logic SW1_REWIND,
    input  logic SW1_FORWARD,
    input  logic SW2
    );
    
    logic ry_a_pick, ry_a_pulled;   // forward motor control
    logic ry_b_pick, ry_b_pulled;   // reverse motor control
    logic r4_c_pick, r4_c_pulled;   // remote resind control
    
    logic top_motor_running, top_motor_run;
    logic bot_motor_running, bot_motor_run;

    localparam B = 16384; // 2^14 papertape buffer size in bytes
    localparam W = $clog2(B); 
    logic [W-1:0] buf_addr;
    logic [7:0] buf_mem [0:B-1];
    logic [7:0] buf_data;
    logic [2:0] ms_ctr;
    logic ms_ctr_running;
    
    // Load number track and box test start-up papertape by default
    parameter string tape_fn = "bxtst.mem";
    initial begin
      // fill buffer with 0x00
      for (int i = 0; i < B; i = i + 1) begin
        buf_mem[i] = 8'h00;
      end
      // load papertape buffer from hex file
      $readmemh(tape_fn, buf_mem);
    end

    always_ff @(posedge clk) begin
      if (rst) begin
        buf_addr <= 0;
        buf_data <= 0;
        ms_ctr <= 4;
        ms_ctr_running <= 0;
        PL6_1_PHOTO1 <= 0;
        PL6_2_PHOTO2 <= 0;
        PL6_4_PHOTO3 <= 0;
        PL6_5_PHOTO4 <= 0;
        PL6_7_PHOTO5 <= 0;
      end else begin
        if (tick_ms & PL6_18_WAIT_FOR_TAPE & ~ms_ctr_running) begin
          // tape moving, read next byte and start clocking it out
          ms_ctr <= 4;
          ms_ctr_running <= 1;
          buf_data <= buf_mem[buf_addr];
          // inc/dec buffer address depending on motor direction
          // tape stalls on first or last byte of buffer (cannot
          // read past buffer limits).
          if (top_motor_running) begin
            buf_addr <= (buf_addr == B-1)? buf_addr : buf_addr + 1;
          end else begin
            buf_addr <= (buf_addr == 0)? buf_addr : buf_addr - 1;
          end
        end else if (tick_ms & PL6_18_WAIT_FOR_TAPE & ms_ctr_running) begin
          // tape is moving, we are clocking out a character
          if (ms_ctr > 1) begin
            PL6_1_PHOTO1 <= buf_data[4];
            PL6_2_PHOTO2 <= buf_data[3];
            PL6_4_PHOTO3 <= buf_data[2];
            PL6_5_PHOTO4 <= buf_data[1];
            PL6_7_PHOTO5 <= buf_data[0];
          end else begin
            PL6_1_PHOTO1 <= 0;
            PL6_2_PHOTO2 <= 0;
            PL6_4_PHOTO3 <= 0;
            PL6_5_PHOTO4 <= 0;
            PL6_7_PHOTO5 <= 0;
          end
          if (ms_ctr == 0) begin
            // final ms of a character, read next character
            buf_data <= buf_mem[buf_addr];
            if (top_motor_running) begin
              buf_addr <= (buf_addr == B-1) ? buf_addr : buf_addr + 1;
            end else begin
              buf_addr <= (buf_addr == 0)? buf_addr : buf_addr - 1;
            end
          end
          ms_ctr <= (ms_ctr == 0) ? 4 : ms_ctr - 1;
        end else if (tick_ms & ~PL6_18_WAIT_FOR_TAPE) begin
          ms_ctr_running <= 0;
          PL6_1_PHOTO1 <= 0;
          PL6_2_PHOTO2 <= 0;
          PL6_4_PHOTO3 <= 0;
          PL6_5_PHOTO4 <= 0;
          PL6_7_PHOTO5 <= 0;
        end
      end
    end
    
    always_ff @(posedge clk) begin
      if (rst) begin
        top_motor_running <= 0;
        bot_motor_running <= 0;
      end else begin
        top_motor_running <= top_motor_run;
        bot_motor_running <= bot_motor_run;
      end
    end
    
    always_comb begin
      ry_a_pick = PL6_9_PHOTO_TAPE_FWD & ~SW1_REWIND;
      ry_b_pick = PL6_10_PHOTO_TAPE_REV & ~SW1_FORWARD;
      top_motor_run = ry_a_pulled;
      bot_motor_run = ry_b_pulled;
      PL6_18_WAIT_FOR_TAPE = ry_a_pulled | ry_b_pulled;
      PL6_17_TAPE_RUN_SW = SW2;
      r4_c_pick = PL6_11_REMOTE_REWIND;
    end
    
    relay relay_ry_a (.*, .tick(tick_ms), .e(ry_a_pick), .c(ry_a_pulled), .ar(0));
    relay relay_ry_b (.*, .tick(tick_ms), .e(ry_b_pick), .c(ry_b_pulled), .ar(0));
    relay relay_r4_c (.*, .tick(tick_ms), .e(r4_c_pick), .c(r4_c_pulled), .ar(0));
endmodule
