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
// Bendix G-15 Turn-on Cycle Sequencer Unit Test
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

module turn_on_ut (
);

    logic rst;
    logic CLOCK;
    logic tick_ms;

    logic SW_DC_RESET;
    logic SW_DC_OFF;
    logic WAIT_FOR_TAPE;
    logic LITE_DC_ON;
    logic LITE_READY;
    logic PWR_AUTO_TAPE_START;
    logic PWR_NT;
    logic PWR_NO_CLEAR;
    logic PWR_CLEAR;
    logic PWR_NO_OP;
    logic PWR_OP;

    timer timer_uut(.*, .clk(CLOCK), .tick(tick_ms));
    turn_on turn_on_uut(.*);

    initial begin
      CLOCK = 1'b0;
      rst = 1'b1;
      SW_DC_RESET = 0;
      SW_DC_OFF = 0;
      WAIT_FOR_TAPE = 0;
                
      // 9.3us 50% duty cycle clock
      forever #(4650) CLOCK = ~CLOCK;
    end

    initial begin
      // FPGA reset line released after 500 clock cycles
      repeat(500) @(posedge CLOCK);
      rst = 0;

      // Wait 10 ms
      repeat(10) @(posedge tick_ms);

      // -----------------------------------------------------------------------
      // First Turn-on Cycle
      // -----------------------------------------------------------------------
      // Press D.C. reset button and hold until D.C. on lamp illuminates
      SW_DC_RESET = 1;
      @(posedge LITE_DC_ON);
      SW_DC_RESET = 0;
      // Pretend to load number track block from phototape
      @(posedge PWR_AUTO_TAPE_START);
      repeat(100) @(posedge tick_ms);
      WAIT_FOR_TAPE = 1;
      repeat(10000) @(posedge tick_ms);
      WAIT_FOR_TAPE = 0;
      // Likewise load box test start-up block
      @(posedge PWR_AUTO_TAPE_START);
      repeat(100) @(posedge tick_ms);
      WAIT_FOR_TAPE = 1;
      repeat(10000) @(posedge tick_ms);
      WAIT_FOR_TAPE = 0;
      // Wait for READY lamp to illuminate
      @(posedge LITE_READY);

      // -----------------------------------------------------------------------
      // Power-off DC
      // -----------------------------------------------------------------------
      // Wait 1 second
      repeat(1000) @(posedge tick_ms);
      // Press D.C. off button and hold until D.C. on lamp extinguishes
      SW_DC_OFF = 1;
      @(negedge LITE_DC_ON);
      SW_DC_OFF = 0;


      // -----------------------------------------------------------------------
      // Second Turn-on Cycle
      // -----------------------------------------------------------------------
      // Wait 1 second
      repeat(1000) @(posedge tick_ms);
      // Press D.C. reset button and hold until D.C. on lamp illuminates
      SW_DC_RESET = 1;
      @(posedge LITE_DC_ON);
      SW_DC_RESET = 0;
      // Pretend to load number track block from phototape
      @(posedge PWR_AUTO_TAPE_START);
      repeat(100) @(posedge tick_ms);
      WAIT_FOR_TAPE = 1;
      repeat(10000) @(posedge tick_ms);
      WAIT_FOR_TAPE = 0;
      // Likewise load box test start-up block
      @(posedge PWR_AUTO_TAPE_START);
      repeat(100) @(posedge tick_ms);
      WAIT_FOR_TAPE = 1;
      repeat(10000) @(posedge tick_ms);
      WAIT_FOR_TAPE = 0;
      // Wait for READY lamp to illuminate
      @(posedge LITE_READY);
      
      // Wait 1 second
      repeat(1000) @(posedge tick_ms);
      $finish;
    end

    
endmodule