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
// Bendix G-15 Alphanumeric with ANC2 Unit Test
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

`define G15_GROUP_I 1
`define G15_GROUP_II 1
`define G15_GROUP_III 1
`define G15_PR_1 1
`define G15_CA_2 1

module g15_alpha_ut (
);

    logic rst;
    logic CLOCK;
    logic tick_ms;

    // Front Panel
    logic SW_DC_RESET;
    logic SW_DC_OFF;
    logic LITE_DC_ON;
    logic LITE_READY;

    // Remote Neon Panel Connector PL-14
    logic PL14_1_CQ;
    logic PL14_2_C7;
    logic PL14_3_C8;
    logic PL14_4_C9;
    logic PL14_5_CU;
    logic PL14_6_CV;
    logic PL14_7_CG;
    logic PL14_8_C2;
    logic PL14_9_C3;
    logic PL14_10_C4;
    logic PL14_11_C5;
    logic PL14_12_C6;
    logic PL14_13_CD1;
    logic PL14_14_CW;
    logic PL14_15_CX;
    logic PL14_16_C1;
    logic PL14_17_FO;
    logic PL14_18_CH;
    logic PL14_19_OC1;
    logic PL14_20_OC2;
    logic PL14_21_READY;
    logic PL14_22_OC3;
    logic PL14_23_IP;
    logic PL14_24_OC4;
    logic PL14_28_CD2;
    logic PL14_29_CD3;
    logic PL14_30_GO;
`ifdef G15_GROUP_III
    logic PL14_32_AS;
`endif

    // IBM I/O Writer Connector PL1 to NC-1, ANC-1, or ANC-2 Typewriter Coupler
`ifdef G15_GROUP_III
    logic PL1_18_AN;
`endif
    logic PL1_33_TYPE;
    logic PL1_29_EXC;
    logic PL1_26_LEV1_IN;
    logic PL1_25_LEV2_IN;
    logic PL1_24_LEV3_IN;
    logic PL1_23_LEV4_IN;
    logic PL1_27_LEV5_IN;
    logic PL1_2_KEY_CIR_S;
    logic PL1_1_KEY_A;
    logic PL1_22_KEY_B;
    logic PL1_21_KEY_C;
`ifdef G15_GROUP_III
    logic PL1_20_KEY_E;
`endif
`ifdef G15_GROUP_I
    logic PL1_3_KEY_F;
`endif
    logic PL1_5_KEY_I;
    logic PL1_6_KEY_M;
    logic PL1_7_KEY_P;
    logic PL1_8_KEY_Q;
    logic PL1_9_KEY_R;
    logic PL1_10_KEY_T;
    logic PL1_11_SA;
    logic PL1_28_REWIND;
    logic PL1_4_PUNCH;
    logic PL1_30_GO;
    logic PL1_31_NO_GO;
    logic PL1_32_BP;
    logic PL1_13_LEV1_OUT;
    logic PL1_14_LEV2_OUT;
    logic PL1_15_LEV3_OUT;
    logic PL1_16_LEV4_OUT;
    logic PL1_12_LEV5_OUT;
    logic PL1_17_F_B;

    // Built-in Photoelectric Tape Reader I/O Connector PL6
    logic PL6_1_PHOTO1;
    logic PL6_2_PHOTO2;
    logic PL6_4_PHOTO3;
    logic PL6_5_PHOTO4;
    logic PL6_7_PHOTO5;
    logic PL6_9_PHOTO_TAPE_FWD;
    logic PL6_10_PHOTO_TAPE_REV;
    logic PL6_11_REMOTE_REWIND;
    logic PL6_18_WAIT_FOR_TAPE;
    logic PL6_17_TAPE_RUN_SW;
    logic SW1_REWIND;
    logic SW1_FORWARD;
    logic SW2;

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

    // Additional Photoelectric Tape Reader I/O
`ifdef G15_PR_1
    logic PHOTO_READER_PERMIT;
`endif
    logic PHOTO_READER_FWD;
    logic PHOTO_READER_REV;

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

`ifdef G15_CA_2
    // Card Adapter
    logic CRP_CQ_s;
`endif

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

    // Debugging Assists
    //   Timing
    logic T0, T1, T29;
    //   CPU
    logic C1, C2, C3, C4, C5, C6, C7, C8, C9, CU, CV, CW, CX;
    logic CM;

    // PL2A connector to I/O Writer
    logic PL2A_1_MAG_42;     // < >
    logic PL2A_2_MAG_40;     // / ⚬
    logic PL2A_3_MAG_38;     // : ;
    logic PL2A_4_MAG_36;     // . ?
    logic PL2A_5_MAG_34;     // l L
    logic PL2A_6_MAG_32;     // , ↑
    logic PL2A_7_MAG_30;     // k K
    logic PL2A_8_MAG_28;     // m M
    logic PL2A_9_MAG_26;     // j J
    logic PL2A_10_MAG_24;    // n N
    logic PL2A_11_MAG_22;    // h H
    logic PL2A_12_MAG_20;    // b B
    logic PL2A_13_MAG_18;    // g G
    logic PL2A_14_MAG_16;    // v V
    logic PL2A_15_MAG_14;    // f F
    logic PL2A_16_MAG_12;    // c C
    logic PL2A_17_MAG_10;    // d D
    logic PL2A_18_MAG_8;     // x X
    logic PL2A_19_MAG_6;     // s S
    logic PL2A_20_MAG_4;     // z Z
    logic PL2A_21_MAG_2;     // a A
    logic PL2A_22_MAG_0;     // Ⓢ Ⓢ
    logic PL2A_23_MAG_43;    // * -
    logic PL2A_24_MAG_41;    // ∧ ∨
    logic PL2A_25_MAG_39;    // 1 √
    logic PL2A_26_MAG_37;    // p P
    logic PL2A_27_MAG_35;    // 0 )
    logic PL2A_28_MAG_33;    // o O
    logic PL2A_29_MAG_31;    // 9 (
    logic PL2A_30_MAG_29;    // i I
    logic PL2A_31_MAG_27;    // 8 ]
    logic PL2A_32_MAG_25;    // u U
    logic PL2A_33_MAG_23;    // 7 [
    logic PL2A_34_MAG_21;    // y Y
    logic PL2A_35_MAG_19;    // 6 ≠
    logic PL2A_36_MAG_17;    // t T
    logic PL2A_37_MAG_15;    // 5 =
    logic PL2A_38_MAG_13;    // r R
    logic PL2A_39_MAG_11;    // 4 $
    logic PL2A_40_MAG_9;     // e E
    logic PL2A_41_MAG_7;     // 3 → 
    logic PL2A_42_MAG_5;     // w W
    logic PL2A_43_MAG_3;     // 2 +
    logic PL2A_44_MAG_1;     // q Q
    // Control magnets:
    logic PL2A_45_MAG_CR;
    logic PL2A_46_MAG_SHIFT;
    logic PL2A_47_MAG_TAB;
    logic PL2A_48_MAG_SPACE;
    // Interlock contacts:
    //input  logic PL2A_53_ILK,      // Ribbon interlock input
    //output logic PL2A_52_ILK_O,    // Ribbon interlock output
    logic PL2A_55_ILK;      // Space, CR, TAB interlock input
    logic PL2A_54_ILK_O;    // Space, CR, TAB interlock output
    //input  logic PL2A_57_ILK,      // Character interlock input
    //output logic PL2A_56_ILK_O,    // Character interlock output
    // Shift basket position:
    logic PL2A_58_SHIFT_O;  // Shift common contact
    logic PL2A_59_SHIFT_UP;      // Shift up
    //input  logic PL2A_60_SHIFT_DOWN,    // Shift down

    // PLM_2A connector to I/O Writer
    // Signals are identified by their IBM contact number
    logic PL1A_1_CNT_101;   // Ⓢ Ⓢ
    logic PL1A_2_CNT_102;   // q Q
    logic PL1A_3_CNT_103;   // a A
    logic PL1A_4_CNT_104;   // 2 +
    logic PL1A_5_CNT_105;   // z Z
    logic PL1A_6_CNT_106;   // w W
    logic PL1A_7_CNT_107;   // s S
    logic PL1A_8_CNT_108;   // 3 →
    logic PL1A_9_CNT_109;   // x X
    logic PL1A_10_CNT_110;  // e E
    logic PL1A_11_CNT_111;  // d D
    logic PL1A_12_CNT_112;  // 4 $
    logic PL1A_13_CNT_113;  // c C
    logic PL1A_14_CNT_114;  // r R
    logic PL1A_15_CNT_115;  // f F
    logic PL1A_16_CNT_116;  // 5 =
    logic PL1A_17_CNT_117;  // v V
    logic PL1A_18_CNT_118;  // t T
    logic PL1A_19_CNT_119;  // g G
    logic PL1A_20_CNT_120;  // 6 ≠
    logic PL1A_21_CNT_121;  // b B
    logic PL1A_22_CNT_122;  // y Y
    logic PL1A_23_CNT_123;  // h H
    logic PL1A_24_CNT_124;  // 7 [
    logic PL1A_25_CNT_125;  // n N
    logic PL1A_26_CNT_126;  // u U
    logic PL1A_27_CNT_127;  // j J
    logic PL1A_28_CNT_128;  // 8 ]
    logic PL1A_29_CNT_129;  // m M
    logic PL1A_30_CNT_130;  // i I
    logic PL1A_31_CNT_131;  // k K
    logic PL1A_32_CNT_132;  // 9 (
    logic PL1A_33_CNT_133;  // , ↑
    logic PL1A_34_CNT_134;  // o O
    logic PL1A_35_CNT_135;  // l L
    logic PL1A_36_CNT_136;  // 0 )
    logic PL1A_37_CNT_137;  // . ?
    logic PL1A_38_CNT_138;  // p P
    logic PL1A_39_CNT_139;  // ; :
    logic PL1A_40_CNT_140;  // 1 √
    logic PL1A_41_CNT_141;  // / ⚬
    logic PL1A_42_CNT_142;  // ∧ ∨
    logic PL1A_43_CNT_143;  // < >
    logic PL1A_44_CNT_144;  // * -
    logic PL1A_72_KB_SCAN;  // Keyboard contact common scan

    logic PL1A_48_CNT_CR;     // CR contact
    //input  logic PL1A_49_CNT_SHIFT,  // SHIFT contact
    logic PL1A_46_CNT_TAB;    // TAB contact
    logic PL1A_47_CNT_SPACE;  // SPACE contact
    logic PL1A_70_CNT_COMMON; // Ribbon cam driven key common contact
    //input  logic PL1A_52_CNT_TAB_FB, // TAB feedback contact
    logic PL1A_45_CTRL_SCAN;  // Control contact common scan

    logic PL1A_61_SA;         // ENABLE SW-1 SA contact
    logic PL1A_64_REWIND;     // PAPERTAPE SW-2 REWIND contact
    logic PL1A_59_PUNCH;      // PAPERTAPE SW-3 PUNCH contact
    logic PL1A_51_GO;         // COMPUTE SW-4 GO contact
    logic PL1A_53_BP;         // COMPUTE SW-4 BP contact
    logic PL1A_55_NO_GO;      // COMPUTE SW-4 NO GO contact


    timer       timer_uut(.*, .clk(CLOCK), .tick(tick_ms));
    g15_top     g15_top_uut(.*);
    tape_reader tape_reader_uut(.*, .clk(CLOCK));
    anc_2       anc_2_uut(.*);

    initial begin
      rst = 1;
      CLOCK = 0;

      // Front Panel
      SW_DC_RESET = 0;
      SW_DC_OFF = 0;

      // IBM I/O Writer Connector PL1 to NC-1, ANC-1, or ANC-2 Typewriter Coupler
      //PL1_2_KEY_CIR_S = 0;
      //PL1_1_KEY_A = 0;
      //PL1_22_KEY_B = 0;
      //PL1_21_KEY_C = 0;
`ifdef G15_GROUP_III
      //PL1_20_KEY_E = 0;
`endif
`ifdef G15_GROUP_I
      //PL1_3_KEY_F = 0;
`endif
      //PL1_5_KEY_I = 0;
      //PL1_6_KEY_M = 0;
      //PL1_7_KEY_P = 0;
      //PL1_8_KEY_Q = 0;
      //PL1_9_KEY_R = 0;
      //PL1_10_KEY_T = 0;
      //PL1_11_SA = 0;
      //PL1_28_REWIND = 0;
      //PL1_4_PUNCH = 0;
      //PL1_30_GO = 0;
      //PL1_31_NO_GO = 0;
      //PL1_32_BP = 0;
      //PL1_13_LEV1_OUT = 0;
      //PL1_14_LEV2_OUT = 0;
      //PL1_15_LEV3_OUT = 0;
      //PL1_16_LEV4_OUT = 0;
      //PL1_12_LEV5_OUT = 0;
      //PL1_17_F_B = 0;

      // Built-in Photoelectric Tape Reader I/O Connector PL6
      //PL6_1_PHOTO1 = 0;
      //PL6_2_PHOTO2 = 0;
      //PL6_4_PHOTO3 = 0;
      //PL6_5_PHOTO4 = 0;
      //PL6_7_PHOTO5 = 0;
      //PL6_18_WAIT_FOR_TAPE = 0;
      //PL6_17_TAPE_RUN_SW = 0;
      SW1_REWIND = 0;
      SW1_FORWARD = 0;
      SW2 = 0;
      
      // Card Reader/Punch I/O
      CARD_INPUT1 = 0;
      CARD_INPUT2 = 0;
      CARD_INPUT3 = 0;
      CARD_INPUT4 = 0; 
      CARD_INPUT5 = 0;
      CARD_SIGN = 0;
      
      // Magnetic Tape I/O
      MAG1_IN = 0;
      MAG2_IN = 0;
      MAG3_IN = 0;
      MAG4_IN = 0;
      MAG5_IN = 0;

      // Additional Photoelectric Tape Reader I/O
`ifdef G15_PR_1
      PHOTO_READER_PERMIT = 0;
`endif

      // Tape Punch I/O
      PUNCHED_TAPE1 = 0;
      PUNCHED_TAPE2 = 0;
      PUNCHED_TAPE3 = 0;
      PUNCHED_TAPE4 = 0;
      PUNCHED_TAPE5 = 0;
      PUNCH_SYNC = 0;

    
      // Maintenance Panel Keys
      MP_CLR_M19 = 0;
      MP_SET_M19 = 0;
      MP_CLR_M23 = 0;
      MP_CLR_NT = 0;
      MP_SET_OP = 0;
      MP_SET_NT = 0;

`ifdef G15_CA_2
      // Card Adapter
      CRP_CQ_s = 0;
`endif

      // DA-1
      GO = 0;
      DA1_M17 = 0;
      DA_OVFLW = 0;

      // Accessory interface on connectors PL19 and PL20
      PL19_INPUT = 0;
      PL19_READY_IN = 0;
      PL20_READY_OUT = 0;

      // Typewriter I/O
      PL2A_55_ILK = 0;      // Space, CR, TAB interlock input
      PL2A_59_SHIFT_UP = 0; // Shift basket up
      PL1A_1_CNT_101 = 0;   // Ⓢ Ⓢ
      PL1A_2_CNT_102 = 0;   // q Q
      PL1A_3_CNT_103 = 0;   // a A
      PL1A_4_CNT_104 = 0;   // 2 +
      PL1A_5_CNT_105 = 0;   // z Z
      PL1A_6_CNT_106 = 0;   // w W
      PL1A_7_CNT_107 = 0;   // s S
      PL1A_8_CNT_108 = 0;   // 3 →
      PL1A_9_CNT_109 = 0;   // x X
      PL1A_10_CNT_110 = 0;  // e E
      PL1A_11_CNT_111 = 0;  // d D
      PL1A_12_CNT_112 = 0;  // 4 $
      PL1A_13_CNT_113 = 0;  // c C
      PL1A_14_CNT_114 = 0;  // r R
      PL1A_15_CNT_115 = 0;  // f F
      PL1A_16_CNT_116 = 0;  // 5 =
      PL1A_17_CNT_117 = 0;  // v V
      PL1A_18_CNT_118 = 0;  // t T
      PL1A_19_CNT_119 = 0;  // g G
      PL1A_20_CNT_120 = 0;  // 6 ≠
      PL1A_21_CNT_121 = 0;  // b B
      PL1A_22_CNT_122 = 0;  // y Y
      PL1A_23_CNT_123 = 0;  // h H
      PL1A_24_CNT_124 = 0;  // 7 [
      PL1A_25_CNT_125 = 0;  // n N
      PL1A_26_CNT_126 = 0;  // u U
      PL1A_27_CNT_127 = 0;  // j J
      PL1A_28_CNT_128 = 0;  // 8 ]
      PL1A_29_CNT_129 = 0;  // m M
      PL1A_30_CNT_130 = 0;  // i I
      PL1A_31_CNT_131 = 0;  // k K
      PL1A_32_CNT_132 = 0;  // 9 (
      PL1A_33_CNT_133 = 0;  // , ↑
      PL1A_34_CNT_134 = 0;  // o O
      PL1A_35_CNT_135 = 0;  // l L
      PL1A_36_CNT_136 = 0;  // 0 )
      PL1A_37_CNT_137 = 0;  // . ?
      PL1A_38_CNT_138 = 0;  // p P
      PL1A_39_CNT_139 = 0;  // ; :
      PL1A_40_CNT_140 = 0;  // 1 √
      PL1A_41_CNT_141 = 0;  // / ⚬
      PL1A_42_CNT_142 = 0;  // ∧ ∨
      PL1A_43_CNT_143 = 0;  // < >
      PL1A_44_CNT_144 = 0;  // * -
      PL1A_48_CNT_CR = 0;     // CR contact
      PL1A_46_CNT_TAB = 0;    // TAB contact
      PL1A_47_CNT_SPACE = 0;  // SPACE contact
      PL1A_70_CNT_COMMON = 0; // Ribbon cam driven key common contact
      PL1A_61_SA = 0;         // ENABLE SW-1 SA contact
      PL1A_64_REWIND = 0;     // PAPERTAPE SW-2 REWIND contact
      PL1A_59_PUNCH = 0;      // PAPERTAPE SW-3 PUNCH contact
      PL1A_51_GO = 0;         // COMPUTE SW-4 GO contact
      PL1A_53_BP = 0;         // COMPUTE SW-4 BP contact
      PL1A_55_NO_GO = 0;      // COMPUTE SW-4 NO GO contact

      // 9.3 us 50% duty cycle clock
      forever #(4650) CLOCK = ~CLOCK;
    end

    initial begin
      // FPGA reset line released after 500 clock cycles
      repeat(500) @(posedge CLOCK);
      rst = 0;

      // Wait 10 ms
      repeat(10) @(posedge tick_ms);

      // Press D.C. reset button and hold until D.C. on lamp illuminates
      SW_DC_RESET = 1;
      @(posedge LITE_DC_ON);
      SW_DC_RESET = 0;

      // Wait for READY lamp to illuminate
      @(posedge LITE_READY);

      // Wait 1 second
      repeat(1000) @(posedge tick_ms);

      // Run ops for 5 seconds
      PL1A_51_GO = 1;
      repeat (5000) @(posedge tick_ms);

      $finish;
    end


endmodule
