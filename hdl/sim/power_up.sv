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
// Bendix G-15 Simulated Power-Up Test
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

module power_up (
    );
    
    logic rst, CLOCK;
    
    // Typewriter Switches
    logic SW_GO;
    logic SW_NO_GO;
    logic SW_BP;
    logic SW_PUNCH;
    logic SW_REWIND;
    logic SW_SA;

    // Typewriter Keys
    logic KEY_A;
    logic KEY_B;
    logic KEY_C;
    logic KEY_E;
    logic KEY_F;
    logic KEY_FB;
    logic KEY_I;
    logic KEY_M;
    logic KEY_P;
    logic KEY_Q;
    logic KEY_R;
    logic KEY_CIR_S;
    logic KEY_T;

    // Typewriter I/O
    logic TYPE1, TYPE2, TYPE3, TYPE4, TYPE5;
    logic TYPE_PULSE;

    // Card Reader/Punch I/O
    logic CARD_INPUT1, CARD_INPUT2, CARD_INPUT3, CARD_INPUT4, CARD_INPUT5;
    logic CARD_SIGN;
    logic CARD_READ_PULSE;
    logic CARD_READ_SIGNAL;
    logic CARD_PUNCH_PULSE;
    logic CARD_PUNCH_SIGNAL;

    // Magnetic Tape I/O
    logic MAG1_IN, MAG2_IN, MAG3_IN, MAG4_IN, MAG5_IN;
    logic MAG1_OUT, MAG2_OUT, MAG3_OUT, MAG4_OUT, MAG5_OUT, MAG6_OUT;
    logic MAG_TAPE_STOP;
    logic MAG_TAPE_FWD;
    logic MAG_TAPE_REV;

    // Photoelectric Tape Reader I/O
    logic PL6_PHOTO1, PL6_PHOTO2, PL6_PHOTO3, PL6_PHOTO4, PL6_PHOTO5;
    logic PHOTO_READER_PERMIT;
    logic PL6_PHOTO_TAPE_FWD;
    logic PL6_PHOTO_TAPE_REV;
    logic PHOTO_READER_FWD;
    logic PHOTO_READER_REV;
    logic PL6_REMOTE_REWIND;
    logic PL6_WAIT_FOR_TAPE;
    logic PL6_TAPE_RUN_SW;
    logic SW1_REWIND;
    logic SW1_FORWARD;
    logic SW2;

    // Tape Punch I/O
    logic PUNCHED_TAPE1, PUNCHED_TAPE2, PUNCHED_TAPE3, PUNCHED_TAPE4, PUNCHED_TAPE5;
    logic PUNCH_SYNC;
    logic PUNCH_SIGNAL;
    
    // Maintenance Panel Keys
    logic MP_CLR_M19;
    logic MP_SET_M19;
    logic MP_CLR_M23;
    logic MP_CLR_NT;
    logic MP_SET_OP;
    logic MP_SET_NT;

    // Power cycle controls
    logic PWR_CLEAR;
    logic PWR_NO_CLEAR;
    logic PWR_OP;
    logic PWR_NO_OP;
    logic PWR_ATS;
    logic PWR_NT;

    // Card Adapter
    logic CRP_CQ_s;

    // DA-1
    logic GO;
    logic DA1_M17;
    logic DA_OVFLW;

    // Accessory interface on connectors PL19 and PL20
    logic PL19_INPUT;
    logic PL19_READY_IN;
    logic PL20_READY_OUT;
    logic PL19_SHIFT_CMD_M20;
    logic PL19_WRITE_PULSE;
    logic PL19_START_INPUT;
    logic PL19_STOP_INPUT;
    logic PL19_SHIFT_CMD;
    logic PL20_OUTPUT;
    logic PL20_OUTPUT_SHIFT;
    
    timer timer_uut (.*, .clk(CLOCK), .tick(tick_ms));
    tape_reader tape_reader_uut (.*, .clk(CLOCK));
    g15_top g15_top_uut (.*);
    
    
    // Initialize signals
    initial begin
        rst <= 1;
        CLOCK <= 0;
        // Typewriter Switches
        SW_GO <= 0;
        SW_NO_GO <= 0;
        SW_BP <= 0;
        SW_PUNCH <= 0;
        SW_REWIND <= 0;
        SW_SA <= 0;

        // Typewriter Keys
        KEY_A <= 0;
        KEY_B <= 0;
        KEY_C <= 0;
        KEY_E <= 0;
        KEY_F <= 0;
        KEY_FB <= 0;
        KEY_I <= 0;
        KEY_M <= 0;
        KEY_P <= 0;
        KEY_Q <= 0;
        KEY_R <= 0;
        KEY_CIR_S <= 0;
        KEY_T <= 0;

        // Typewriter I/O
        TYPE1 <= 0;
        TYPE2 <= 0;
        TYPE3 <= 0;
        TYPE4 <= 0;
        TYPE5 <= 0;
        //output TYPE_PULSE;

        // Card Reader/Punch I/O
        CARD_INPUT1 <= 0;
        CARD_INPUT2 <= 0;
        CARD_INPUT3 <= 0;
        CARD_INPUT4 <= 0;
        CARD_INPUT5 <= 0;
        CARD_SIGN <= 0;
        //output CARD_READ_PULSE;
        //output CARD_READ_SIGNAL;
        //output CARD_PUNCH_PULSE;
        //output CARD_PUNCH_SIGNAL

        // Magnetic Tape I/O
        MAG1_IN <= 0;
        MAG2_IN <= 0;
        MAG3_IN <= 0;
        MAG4_IN <= 0;
        MAG5_IN <= 0;
        //output MAG1_OUT, MAG2_OUT, MAG3_OUT, MAG4_OUT, MAG5_OUT, MAG6_OUT;
        //output MAG_TAPE_STOP;
        //output MAG_TAPE_FWD;
        //output MAG_TAPE_REV;

        // Photoelectric Tape Reader I/O
        PL6_PHOTO1 <= 0;
        PL6_PHOTO2 <= 0;
        PL6_PHOTO3 <= 0;
        PL6_PHOTO4 <= 0;
        PL6_PHOTO5 <= 0;
        PHOTO_READER_PERMIT <= 0;
        //output PHOTO_TAPE_FWD;
        //output PHOTO_TAPE_REV;
        //output PHOTO_READER_FWD;
        //output PHOTO_READER_REV;
        PL6_REMOTE_REWIND <= 0;
        SW1_REWIND <= 0;
        SW1_FORWARD <= 0;
        SW2 <= 1;

        // Tape Punch I/O
        PUNCHED_TAPE1 <= 0;
        PUNCHED_TAPE2 <= 0;
        PUNCHED_TAPE3 <= 0;
        PUNCHED_TAPE4 <= 0;
        PUNCHED_TAPE5 <= 0;
        PUNCH_SYNC <= 0;
        //output PUNCH_SIGNAL;
    
        // Maintenance Panel Keys
        MP_CLR_M19 <= 0;
        MP_SET_M19 <= 0;
        MP_CLR_M23 <= 0;
        MP_CLR_NT <= 0;
        MP_SET_OP <= 0;
        MP_SET_NT <= 0;

        // Power cycle controls
        PWR_CLEAR <= 0;
        PWR_NO_CLEAR <= 1;
        PWR_OP <= 0;
        PWR_NO_OP <= 1;
        PWR_ATS <= 0;
        PWR_NT <= 0;

        // Card Adapter
        CRP_CQ_s <= 0;

        // DA-1
        GO <= 0;
        DA1_M17 <= 0;
        DA_OVFLW <= 0;

        // Accessory interface on connectors PL19 and PL20
        PL19_INPUT <= 0;
        PL19_READY_IN <= 0;
        PL20_READY_OUT <= 0;
        //output PL19_SHIFT_CMD_M20;
        //output PL19_WRITE_PULSE;
        //output PL19_START_INPUT;
        //output PL19_STOP_INPUT;
        //output PL19_SHIFT_CMD;
        //output PL20_OUTPUT;
        //output PL20_OUTPUT_SHIFT;
    end
    
    initial begin
        // 9.3us 50% duty cycle clock
        forever #(4650) CLOCK <= ~CLOCK;
    end
    
    initial begin
        // wait 500 clocks then drop reset
        repeat (500) @(posedge CLOCK);
        rst <= 1'b0;
        
        // raise <CLEAR OC> for ~10 revs
        PWR_CLEAR <= 1;
        repeat (150) @(posedge tick_ms);
        PWR_CLEAR <= 0;
        
        // drop <~OP> for 2 revs
        PWR_NO_OP <= 0;
        repeat (30) @(posedge tick_ms);
        // raise <OP> for 4 revs
        PWR_OP <= 1;
        repeat (60) @(posedge tick_ms);
        PWR_OP <= 0;
        repeat (30) @(posedge tick_ms);
        PWR_NO_OP <= 1;
        
        // wait 4 revs
        repeat (120) @(posedge tick_ms);
        PWR_ATS <= 1;
        repeat (30) @(posedge tick_ms);
        PWR_ATS <= 0;
        
        // wait for timing track read-in to complete
        @(negedge PL6_WAIT_FOR_TAPE);
        // wait an additional 4 revs
        repeat (120) @(posedge tick_ms);
        // raise PWR_NT for 4 revs to xfer M19->number track
        PWR_NT <= 1;
        repeat (120) @(posedge tick_ms);
        PWR_NT <= 0;

        repeat (120) @(posedge tick_ms);
        PWR_ATS <= 1;
        repeat (30) @(posedge tick_ms);
        PWR_ATS <= 0;
        
        // wait for loader block read-in to complete
        @(negedge PL6_WAIT_FOR_TAPE);

        repeat (120) @(posedge tick_ms);
        SW_GO <= 1;
        // wait xx revs then end test
        repeat (3600) @(posedge tick_ms);
        $finish;
    end
    
endmodule
