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
// Bendix ANC-2 Alphanumeric Coupler
//
// Source: 
//  http://bitsavers.org/pdf/bendix/g-15/AET-05611_ANC-2_Service_Man_May61.pdf
//
// The IBM I/O Writer used by the G-15 is a 44-key model with special Bendix
// typebars and keytops. 
// ----------------------------------------------------------------------------
`timescale 1ns / 1ps

module anc_2 (
    input  logic rst,
    input  logic CLOCK,
    input  logic tick_ms,

    // PL1 connector to G-15
    input  logic PL1_18_AN,         // AS
    input  logic PL1_33_TYPE,       // TYPE
    input  logic PL1_29_EXC,        // TYPE_PULSE
    input  logic PL1_26_LEV1_IN,    // OB1
    input  logic PL1_25_LEV2_IN,    // OB2
    input  logic PL1_24_LEV3_IN,    // OB3
    input  logic PL1_23_LEV4_IN,    // OB4
    input  logic PL1_27_LEV5_IN,    // OB5 & (~AS | ~OY & OH)
    // Function key inputs. When a function key is pressed and the ENABLE switch
    // is on, the key signal will last ~40-60 ms. This is the total time that the
    // typewriter escapement keeps the key contacts closed.  
    output logic PL1_2_KEY_CIR_S,   // <Ⓢ>
    output logic PL1_1_KEY_A,       // <A>
    output logic PL1_22_KEY_B,      // <B>
    output logic PL1_21_KEY_C,      // <C>
    output logic PL1_20_KEY_E,      // <E>
    output logic PL1_3_KEY_F,       // <F>
    output logic PL1_5_KEY_I,       // <I>
    output logic PL1_6_KEY_M,       // <M>
    output logic PL1_7_KEY_P,       // <P>
    output logic PL1_8_KEY_Q,       // <Q>
    output logic PL1_9_KEY_R,       // <R>
    output logic PL1_10_KEY_T,      // <T>
    output logic PL1_11_SA,         // <SA> = ~RY10(TYPE) & RY12(SA)
    output logic PL1_28_REWIND,     // <REWIND>
    output logic PL1_4_PUNCH,       // <PUNCH>
    output logic PL1_30_GO,         // <GO>
    output logic PL1_31_NO_GO,      // <~GO>
    output logic PL1_32_BP,         // <BP>
    output logic PL1_13_LEV1_OUT,   // LEV1
    output logic PL1_14_LEV2_OUT,   // LEV2
    output logic PL1_15_LEV3_OUT,   // LEV3 = TYPE? SP|CR|TAB|SA : encoder bit 3
                                    // (provides feedback for OUTPUT)
    output logic PL1_16_LEV4_OUT,   // LEV4
    output logic PL1_12_LEV5_OUT,   // LEV5
    output logic PL1_17_F_B,        // <F-B>

    // PL2A connector to I/O Writer
    // Typebar magnets identified by their IBM magnet number
    output logic PL2A_1_MAG_42,     // < >
    output logic PL2A_2_MAG_40,     // / ⚬
    output logic PL2A_3_MAG_38,     // : ;
    output logic PL2A_4_MAG_36,     // . ?
    output logic PL2A_5_MAG_34,     // l L
    output logic PL2A_6_MAG_32,     // , ↑
    output logic PL2A_7_MAG_30,     // k K
    output logic PL2A_8_MAG_28,     // m M
    output logic PL2A_9_MAG_26,     // j J
    output logic PL2A_10_MAG_24,    // n N
    output logic PL2A_11_MAG_22,    // h H
    output logic PL2A_12_MAG_20,    // b B
    output logic PL2A_13_MAG_18,    // g G
    output logic PL2A_14_MAG_16,    // v V
    output logic PL2A_15_MAG_14,    // f F
    output logic PL2A_16_MAG_12,    // c C
    output logic PL2A_17_MAG_10,    // d D
    output logic PL2A_18_MAG_8,     // x X
    output logic PL2A_19_MAG_6,     // s S
    output logic PL2A_20_MAG_4,     // z Z
    output logic PL2A_21_MAG_2,     // a A
    output logic PL2A_22_MAG_0,     // Ⓢ Ⓢ
    output logic PL2A_23_MAG_43,    // * -
    output logic PL2A_24_MAG_41,    // ∧ ∨
    output logic PL2A_25_MAG_39,    // 1 √
    output logic PL2A_26_MAG_37,    // p P
    output logic PL2A_27_MAG_35,    // 0 )
    output logic PL2A_28_MAG_33,    // o O
    output logic PL2A_29_MAG_31,    // 9 (
    output logic PL2A_30_MAG_29,    // i I
    output logic PL2A_31_MAG_27,    // 8 ]
    output logic PL2A_32_MAG_25,    // u U
    output logic PL2A_33_MAG_23,    // 7 [
    output logic PL2A_34_MAG_21,    // y Y
    output logic PL2A_35_MAG_19,    // 6 ≠
    output logic PL2A_36_MAG_17,    // t T
    output logic PL2A_37_MAG_15,    // 5 =
    output logic PL2A_38_MAG_13,    // r R
    output logic PL2A_39_MAG_11,    // 4 $
    output logic PL2A_40_MAG_9,     // e E
    output logic PL2A_41_MAG_7,     // 3 → 
    output logic PL2A_42_MAG_5,     // w W
    output logic PL2A_43_MAG_3,     // 2 +
    output logic PL2A_44_MAG_1,     // q Q
    // Control magnets:
    output logic PL2A_45_MAG_CR,
    output logic PL2A_46_MAG_SHIFT,
    output logic PL2A_47_MAG_TAB,
    output logic PL2A_48_MAG_SPACE,
    // Interlock contacts:
    input  logic PL2A_52_ILK,      // Ribbon interlock input
    output logic PL2A_53_ILK,      // Ribbon interlock output
    input  logic PL2A_54_ILK,      // Space, CR, TAB interlock input
    output logic PL2A_55_ILK,      // Space, CR, TAB interlock output
    input  logic PL2A_56_ILK,      // Character interlock input
    output logic PL2A_57_ILK,      // Character interlock output
    output logic PL2A_58_SHIFT,    // Shift common contact
    input  logic PL2A_59_SHIFT_UP,      // Shift up
    input  logic PL2A_60_SHIFT_DOWN,    // Shift down

    // PLM_2A connector to I/O Writer
    // Signals are identified by their IBM contact number
    input  logic PL1A_1_CNT_101,   // Ⓢ Ⓢ
    input  logic PL1A_2_CNT_102,   // q Q
    input  logic PL1A_3_CNT_103,   // a A
    input  logic PL1A_4_CNT_104,   // 2 +
    input  logic PL1A_5_CNT_105,   // z Z
    input  logic PL1A_6_CNT_106,   // w W
    input  logic PL1A_7_CNT_107,   // s S
    input  logic PL1A_8_CNT_108,   // 3 →
    input  logic PL1A_9_CNT_109,   // x X
    input  logic PL1A_10_CNT_110,  // e E
    input  logic PL1A_11_CNT_111,  // d D
    input  logic PL1A_12_CNT_112,  // 4 $
    input  logic PL1A_13_CNT_113,  // c C
    input  logic PL1A_14_CNT_114,  // r R
    input  logic PL1A_15_CNT_115,  // f F
    input  logic PL1A_16_CNT_116,  // 5 =
    input  logic PL1A_17_CNT_117,  // v V
    input  logic PL1A_18_CNT_118,  // t T
    input  logic PL1A_19_CNT_119,  // g G
    input  logic PL1A_20_CNT_120,  // 6 ≠
    input  logic PL1A_21_CNT_121,  // b B
    input  logic PL1A_22_CNT_122,  // y Y
    input  logic PL1A_23_CNT_123,  // h H
    input  logic PL1A_24_CNT_124,  // 7 [
    input  logic PL1A_25_CNT_125,  // n N
    input  logic PL1A_26_CNT_126,  // u U
    input  logic PL1A_27_CNT_127,  // j J
    input  logic PL1A_28_CNT_128,  // 8 ]
    input  logic PL1A_29_CNT_129,  // m M
    input  logic PL1A_30_CNT_130,  // i I
    input  logic PL1A_31_CNT_131,  // k K
    input  logic PL1A_32_CNT_132,  // 9 (
    input  logic PL1A_33_CNT_133,  // , ↑
    input  logic PL1A_34_CNT_134,  // o O
    input  logic PL1A_35_CNT_135,  // l L
    input  logic PL1A_36_CNT_136,  // 0 )
    input  logic PL1A_37_CNT_137,  // . ?
    input  logic PL1A_38_CNT_138,  // p P
    input  logic PL1A_39_CNT_139,  // ; :
    input  logic PL1A_40_CNT_140,  // 1 √
    input  logic PL1A_41_CNT_141,  // / ⚬
    input  logic PL1A_42_CNT_142,  // ∧ ∨
    input  logic PL1A_43_CNT_143,  // < >
    input  logic PL1A_44_CNT_144,  // * -
    output logic PL1A_72_KB_SCAN,  // Keyboard contact common scan

    input  logic PL1A_48_CNT_CR,     // CR contact
    input  logic PL1A_49_CNT_SHIFT,  // SHIFT contact
    input  logic PL1A_46_CNT_TAB,    // TAB contact
    input  logic PL1A_47_CNT_SPACE,  // SPACE contact
    input  logic PL1A_70_CNT_COMMON, // Ribbon cam driven key common contact
    input  logic PL1A_52_CNT_TAB_FB, // TAB feedback contact
    output logic PL1A_45_CTRL_SCAN,  // Control contact common scan

    input  logic PL1A_61_SA,         // ENABLE SW-1 SA contact
    input  logic PL1A_64_REWIND,     // PAPERTAPE SW-2 REWIND contact
    input  logic PL1A_59_PUNCH,      // PAPERTAPE SW-3 PUNCH contact
    input  logic PL1A_51_GO,         // COMPUTE SW-4 GO contact
    input  logic PL1A_53_BP,         // COMPUTE SW-4 BP contact
    input  logic PL1A_55_NO_GO       // COMPUTE SW-4 NO GO contact
);

    // Relays. All relays make/break in ~10ms unless otherwise noted.
    logic RY1_LEV1,       RY1_LEV1_e;
    logic RY2_LEV2,       RY2_LEV2_e;
    logic RY3_LEV3,       RY3_LEV3_e;
    logic RY4_LEV4,       RY4_LEV4_e;
    logic RY5_LEV5,       RY5_LEV5_e;

    logic RY6_ALPHA5,     RY6_ALPHA5_e;     // RY5 & RY1 | ~RY5 & RY6
    logic RY7_ALPHA6,     RY7_ALPHA6_e;     // RY5 & RY2 | ~RY5 & RY7
    logic RY8_AN,         RY8_AN_e;
    logic RY9_EXC,        RY9_EXC_e;
    logic RY10_TYPE,      RY10_TYPE_e;

    logic RY11A_SHIFT,    RY11A_SHIFT_e;
    logic RY11B_INT,      RY11B_INT_e;

    logic RY12_SA,        RY12_SA_e;
    logic RY13_AN_NOT_SA, RY13_AN_NOT_SA_e;
    logic RY14_UP,        RY14_UP_e;
    logic RY15_SP,        RY15_SP_e;
    logic RY16_TAB,       RY16_TAB_e;
    logic RY17_CR,        RY17_CR_e;
    logic RY18,           RY18_e;
    logic RY19,           RY19_e;
    logic RY20_XFER,      RY20_XFER_e;

    // Special output shift cases:
    logic SPECIAL_2;  // /
    logic SPECIAL_37; // =
    logic SPECIAL_39; // $
    logic SPECIAL_29; // (
    logic SPECIAL_43; // +
    logic SPECIAL_27; // )
    logic SPECIAL_23; // *
    logic SPECIAL_COMMON;

    // Output writer.
    always_comb begin
      // Inputs from G-15 are buffered by relays
      RY1_LEV1_e = RY10_TYPE & PL1_26_LEV1_IN;
      RY2_LEV2_e = RY10_TYPE & PL1_25_LEV2_IN;
      RY3_LEV3_e = RY10_TYPE & PL1_24_LEV3_IN;
      RY4_LEV4_e = RY10_TYPE & PL1_23_LEV4_IN;
      RY5_LEV5_e = ~RY8_AN & PL1_27_LEV5_IN;        // TODO: get this right!
      RY8_AN_e = PL1_18_AN;
      RY9_EXC_e = RY10_TYPE & PL1_29_EXC;
      RY10_TYPE_e = PL1_33_TYPE;

      // Buffer bits 5 and 6 of an alphanumeric character in RY6 and RY7
      RY6_ALPHA5_e =   (RY8_AN & RY1_LEV1 & RY5_LEV5)         // pick for first extraction
                     | (RY10_TYPE & RY6_ALPHA5 & ~RY5_LEV5);  // hold for second extraction
      RY7_ALPHA6_e =   (RY8_AN & RY2_LEV2 & RY5_LEV5)
                     | (RY10_TYPE & RY7_ALPHA6 & ~RY5_LEV5);

      // Default off to all typewriter magnets
      PL2A_1_MAG_42 = 0;
      PL2A_2_MAG_40 = 0;
      PL2A_3_MAG_38 = 0;
      PL2A_4_MAG_36 = 0;
      PL2A_5_MAG_34 = 0;
      PL2A_6_MAG_32 = 0;
      PL2A_7_MAG_30 = 0;
      PL2A_8_MAG_28 = 0;
      PL2A_9_MAG_26 = 0;
      PL2A_10_MAG_24 = 0;
      PL2A_11_MAG_22 = 0;
      PL2A_12_MAG_20 = 0;
      PL2A_13_MAG_18 = 0;
      PL2A_14_MAG_16 = 0;
      PL2A_15_MAG_14 = 0;
      PL2A_16_MAG_12 = 0;
      PL2A_17_MAG_10 = 0;
      PL2A_18_MAG_8 = 0;
      PL2A_19_MAG_6 = 0;
      PL2A_20_MAG_4 = 0;
      PL2A_21_MAG_2 = 0;
      PL2A_22_MAG_0 = 0;
      PL2A_23_MAG_43 = 0;
      PL2A_24_MAG_41 = 0;
      PL2A_25_MAG_39 = 0;
      PL2A_26_MAG_37 = 0;
      PL2A_27_MAG_35 = 0;
      PL2A_28_MAG_33 = 0;
      PL2A_29_MAG_31 = 0;
      PL2A_30_MAG_29 = 0;
      PL2A_31_MAG_27 = 0;
      PL2A_32_MAG_25 = 0;
      PL2A_33_MAG_23 = 0;
      PL2A_34_MAG_21 = 0;
      PL2A_35_MAG_19 = 0;
      PL2A_36_MAG_17 = 0;
      PL2A_37_MAG_15 = 0;
      PL2A_38_MAG_13 = 0;
      PL2A_39_MAG_11 = 0;
      PL2A_40_MAG_9 = 0;
      PL2A_41_MAG_7 = 0; 
      PL2A_42_MAG_5 = 0;
      PL2A_43_MAG_3 = 0;
      PL2A_44_MAG_1 = 0;
      PL2A_45_MAG_CR = 0;
      PL2A_46_MAG_SHIFT = 0;
      PL2A_47_MAG_TAB = 0;
      PL2A_48_MAG_SPACE = 0;
      SPECIAL_2 = 0;
      SPECIAL_37 = 0;
      SPECIAL_39 = 0;
      SPECIAL_29 = 0;
      SPECIAL_43 = 0;
      SPECIAL_27 = 0;
      SPECIAL_23 = 0;

      // G-15 encoded character to typewriter magnet decoder
      if (RY9_EXC & ~RY8_AN) begin
        // Hex numeric character decodes
        unique0 casez ({RY5_LEV5, RY4_LEV4, RY3_LEV3, RY2_LEV2, RY1_LEV1})
          5'b0?000: PL2A_48_MAG_SPACE = 1;  // Space
          5'b0?001: PL2A_23_MAG_43    = 1;  // - *
          5'b0?010: PL2A_45_MAG_CR    = 1;  // CR
          5'b0?011: PL2A_47_MAG_TAB   = 1;  // TAB
          5'b0?110: PL2A_4_MAG_36     = 1;  // . ?
          5'b10000: PL2A_37_MAG_15    = 1;  // 0 )
          5'b10001: PL2A_25_MAG_39    = 1;  // 1 √
          5'b10010: PL2A_43_MAG_3     = 1;  // 2 +
          5'b10011: PL2A_41_MAG_7     = 1;  // 3 →
          5'b10100: PL2A_39_MAG_11    = 1;  // 4 $
          5'b10101: PL2A_37_MAG_15    = 1;  // 5 =
          5'b10110: PL2A_35_MAG_19    = 1;  // 6 ≠
          5'b10111: PL2A_33_MAG_23    = 1;  // 7 [
          5'b11000: PL2A_31_MAG_27    = 1;  // 8 ]
          5'b11001: PL2A_29_MAG_31    = 1;  // 9 (
          5'b11010: PL2A_32_MAG_25    = 1;  // u U
          5'b11011: PL2A_14_MAG_16    = 1;  // v V
          5'b11100: PL2A_42_MAG_5     = 1;  // w W
          5'b11101: PL2A_18_MAG_8     = 1;  // x X
          5'b11110: PL2A_34_MAG_21    = 1;  // y Y
          5'b11111: PL2A_20_MAG_4     = 1;  // z Z
          default:;
        endcase
      end else if (RY9_EXC & RY8_AN) begin
        // Alphabetic character decodes
        unique0 casez ({RY7_ALPHA6, RY6_ALPHA5,
                        RY4_LEV4, RY3_LEV3, RY2_LEV2, RY1_LEV1})
          6'b000000: PL2A_37_MAG_15  = 1;  // 0 )
          6'b000001: PL2A_25_MAG_39  = 1;  // 1 √
          6'b000010: PL2A_43_MAG_3   = 1;  // 2 +
          6'b000011: PL2A_41_MAG_7   = 1;  // 3 →
          6'b000100: PL2A_39_MAG_11  = 1;  // 4 $
          6'b000101: PL2A_37_MAG_15  = 1;  // 5 =
          6'b000110: PL2A_35_MAG_19  = 1;  // 6 ≠
          6'b000111: PL2A_33_MAG_23  = 1;  // 7 [
          6'b001000: PL2A_31_MAG_27  = 1;  // 8 ]
          6'b001001: PL2A_29_MAG_31  = 1;  // 9 (
          6'b001011: SPECIAL_37      = 1;  // =
          6'b010000: SPECIAL_43      = 1;  // +
          6'b010001: PL2A_21_MAG_2   = 1;  // a A
          6'b010010: PL2A_12_MAG_20  = 1;  // b B
          6'b010011: PL2A_16_MAG_12  = 1;  // c C
          6'b010100: PL2A_17_MAG_10  = 1;  // d D
          6'b010101: PL2A_40_MAG_9   = 1;  // e E
          6'b010110: PL2A_15_MAG_14  = 1;  // f F
          6'b010111: PL2A_13_MAG_18  = 1;  // g G
          6'b011000: PL2A_11_MAG_22  = 1;  // h H
          6'b011001: PL2A_30_MAG_29  = 1;  // i I
          6'b011010: PL2A_1_MAG_42   = 1;  // < >
          6'b011011: PL2A_4_MAG_36   = 1;  // . ?
          6'b011100: SPECIAL_27      = 1;  // )
          6'b011101: PL2A_3_MAG_38   = 1;  // : ;
          6'b011110: PL2A_24_MAG_41  = 1;  // ∧ ∨
          6'b100000: PL2A_23_MAG_43  = 1;  // * -
          6'b100001: PL2A_9_MAG_26   = 1;  // j J
          6'b100010: PL2A_7_MAG_30   = 1;  // k K
          6'b100011: PL2A_5_MAG_34   = 1;  // l L
          6'b100100: PL2A_8_MAG_28   = 1;  // m M
          6'b100101: PL2A_10_MAG_24  = 1;  // n N
          6'b100110: PL2A_28_MAG_33  = 1;  // o O
          6'b100111: PL2A_26_MAG_37  = 1;  // p P
          6'b101000: PL2A_44_MAG_1   = 1;  // q Q
          6'b101001: PL2A_38_MAG_13  = 1;  // r R
          6'b101010: PL2A_45_MAG_CR  = 1;  // CR
          6'b101011: SPECIAL_39      = 1;  // $
          6'b101100: SPECIAL_23      = 1;  // *
          6'b101101: PL2A_47_MAG_TAB = 1;  // TAB
          6'b110001: SPECIAL_2       = 1;  // /
          6'b110010: PL2A_19_MAG_6   = 1;  // s S
          6'b110011: PL2A_36_MAG_17  = 1;  // t T
          6'b110100: PL2A_32_MAG_25  = 1;  // u U
          6'b110101: PL2A_14_MAG_16  = 1;  // v V
          6'b110110: PL2A_42_MAG_5   = 1;  // w W
          6'b111000: PL2A_34_MAG_21  = 1;  // y Y
          6'b111001: PL2A_20_MAG_4   = 1;  // z Z
          6'b111011: PL2A_6_MAG_32   = 1;  // , ↑
          6'b111100: SPECIAL_29      = 1;  // (
          6'b111101: PL2A_48_MAG_SPACE = 1;  // Space
          default:;
        endcase
      end

      // Carriage shift magnet control.
      SPECIAL_COMMON =  SPECIAL_2  | SPECIAL_37 | SPECIAL_39 | SPECIAL_29 
                      | SPECIAL_43 | SPECIAL_27 | SPECIAL_23;
      RY11A_SHIFT_e =   ((RY8_AN & RY5_LEV5) | (RY10_TYPE & RY11A_SHIFT) | (SPECIAL_COMMON & ~RY11B_INT))
                      & (~RY5_LEV5 | ~RY3_LEV3);
      RY11B_INT_e = RY11A_SHIFT;
      PL2A_46_MAG_SHIFT = RY11A_SHIFT;

      // Special character magnet control.
      if (RY11B_INT) begin
        PL2A_2_MAG_40  = SPECIAL_2?  1 : PL2A_2_MAG_40;
        PL2A_23_MAG_43 = SPECIAL_23? 1 : PL2A_23_MAG_43;
        PL2A_27_MAG_35 = SPECIAL_27? 1 : PL2A_27_MAG_35;
        PL2A_29_MAG_31 = SPECIAL_29? 1 : PL2A_29_MAG_31;
        PL2A_37_MAG_15 = SPECIAL_37? 1 : PL2A_37_MAG_15;
        PL2A_39_MAG_11 = SPECIAL_39? 1 : PL2A_39_MAG_11;
        PL2A_43_MAG_3  = SPECIAL_43? 1 : PL2A_43_MAG_3;
      end
    end

    // -----------------------------------------------------------------------
    // Input writer. Typewriter->Coupler->G-15
    // -----------------------------------------------------------------------
    logic COMM;
    logic KEY_PROBE;
    logic CTL_PROBE;
    logic T1, T2;
    logic SHIFTING_UP, SHIFTING_DOWN;
    logic LOWER_CASE;
    logic [3:1] ENC_AN_T1;
    logic [4:1] ENC_AN_T2;
    logic [5:1] ENC_HEX;

    always_comb begin
      RY12_SA_e        = PL1A_61_SA;
      RY13_AN_NOT_SA_e = RY8_AN & ~RY12_SA;
      RY14_UP_e        = RY8_AN & PL2A_59_SHIFT_UP;
      RY15_SP_e        = ~RY12_SA & PL1A_47_CNT_SPACE;
      RY16_TAB_e       = ~RY12_SA & PL1A_46_CNT_TAB;
      RY17_CR_e        = ~RY12_SA & PL1A_48_CNT_CR;
      COMM             = ~RY12_SA & PL1A_70_CNT_COMMON | PL1A_48_CNT_CR | PL1A_46_CNT_TAB | PL1A_47_CNT_SPACE;
      RY18_e           = COMM & ~RY19;
      RY19_e           = COMM & RY19 | RY18;
      RY20_XFER_e      = RY19;

      // Keyboard scanner and encoder.
      T1 = RY18 & ~RY19;
      T2 = ~RY18 & RY19;
      KEY_PROBE = T1 | T2 | RY12_SA;
      CTL_PROBE = T1 | T2;
      SHIFTING_UP = RY10_TYPE & RY11A_SHIFT & ~RY14_UP;
      SHIFTING_DOWN = RY10_TYPE & ~RY11A_SHIFT & RY14_UP;
      LOWER_CASE =   (~RY10_TYPE & (T1 | T2) & ~RY14_UP)
                   | (RY10_TYPE & RY11A_SHIFT);
      // The ANC-2 encoder is a diode matrix, so instead of a case statement
      // we use a series of if statements.
      PL1A_72_KB_SCAN = KEY_PROBE;
      ENC_AN_T1 = '0;
      ENC_AN_T2 = '0;
      ENC_HEX = '0;
      // Note that shifted number key contacts that are not special characters
      // will generate a hex output while those that are special characters
      // will not. For example, shift+3 will generate a hex b10011 code while 
      // shift+2 will generate a hex b00000.
      if (PL1A_2_CNT_102) begin   // q Q   x10_1000_xxxxx
        ENC_AN_T1[2] = 1;
        ENC_AN_T2[4] = 1;
      end
      if (PL1A_3_CNT_103) begin   // a A   x01_0001_xxxxx
        ENC_AN_T1[1] = 1;
        ENC_AN_T2[1] = 1;
      end
      if (PL1A_4_CNT_104) begin   // 2 +
        if (~RY14_UP) begin       // 2     x00_0010_10010
          ENC_AN_T2[2] = 1;
          ENC_HEX[2] = 1;
          ENC_HEX[5] = 1;
        end else begin            // +     101_0000_xxxxx
          ENC_AN_T1[3] = 1;
          ENC_AN_T2[1] = 1;
        end
        ENC_HEX[5] = 1;
      end
      if (PL1A_5_CNT_105) begin   // z Z   x11_1001_11111
        ENC_AN_T1[1] = 1;
        ENC_AN_T1[2] = 1;
        ENC_AN_T2[1] = 1;
        ENC_AN_T2[4] = 1;
        ENC_HEX[5] = 1;
        ENC_HEX[4] = 1;
        ENC_HEX[3] = 1;
        ENC_HEX[2] = 1;
        ENC_HEX[1] = 1;
      end
      if (PL1A_6_CNT_106) begin   // w W   x11_0110_11100
        ENC_AN_T1[1] = 1;
        ENC_AN_T1[2] = 1;
        ENC_AN_T2[2] = 1;
        ENC_AN_T2[3] = 1;
        ENC_HEX[5] = 1;
        ENC_HEX[4] = 1;
        ENC_HEX[3] = 1;
        ENC_HEX[2] = 0;
        ENC_HEX[1] = 0;
      end
      if (PL1A_7_CNT_107) begin   // s S   x11_0010_xxxxx
        ENC_AN_T1[1] = 1;
        ENC_AN_T1[2] = 1;
        ENC_AN_T2[2] = 1;
      end
      if (PL1A_8_CNT_108) begin   // 3 →   x00_0011_10011
        ENC_AN_T2[1] = 1;
        ENC_AN_T2[2] = 1;
        ENC_HEX[1] = 1;
        ENC_HEX[2] = 1;
        ENC_HEX[5] = 1;
      end
      if (PL1A_9_CNT_109) begin   // x X   x11_0001_11101
        ENC_AN_T1[1] = 1;
        ENC_AN_T1[2] = 1;
        ENC_AN_T2[1] = 1;
        ENC_HEX[5] = 1;
        ENC_HEX[3] = 1;
        ENC_HEX[2] = 1;
        ENC_HEX[1] = 1;
      end
      if (PL1A_10_CNT_110) begin  // e E   x01_0101_xxxxx
        ENC_AN_T1[1] = 1;
        ENC_AN_T2[1] = 1;
        ENC_AN_T2[3] = 1;
      end
      if (PL1A_11_CNT_111) begin  // d D   x01_0100_xxxxx
        ENC_AN_T1[1] = 1;
        ENC_AN_T2[3] = 1;
      end
      if (PL1A_12_CNT_112) begin  // 4 $
        if (~RY14_UP) begin       // 4     x00_0100_10100
          ENC_AN_T2[2] = 1;
          ENC_HEX[3] = 1;
          ENC_HEX[5] = 1;
        end else begin            // $     110_1011_xxxxx
          ENC_AN_T1[2] = 1;
          ENC_AN_T1[3] = 1;
          ENC_AN_T2[1] = 1;
          ENC_AN_T2[2] = 1;
          ENC_AN_T2[4] = 1;
        end
      end
      if (PL1A_13_CNT_113) begin  // c C   x01_0011_xxxxx
        ENC_AN_T1[1] = 1;
        ENC_AN_T2[1] = 1;
        ENC_AN_T2[2] = 1;
      end
      if (PL1A_14_CNT_114) begin  // r R   x10_1001_xxxxx
        ENC_AN_T1[2] = 1;
        ENC_AN_T2[1] = 1;
        ENC_AN_T2[4] = 1;
      end
      if (PL1A_15_CNT_115) begin  // f F   x01_0110_xxxxx
        ENC_AN_T1[1] = 1;
        ENC_AN_T2[2] = 1;
        ENC_AN_T2[3] = 1;
      end
      if (PL1A_16_CNT_116) begin  // 5 =
        if (~RY14_UP) begin       // 5     x00_0101_10101
          ENC_AN_T2[1] = 1;
          ENC_AN_T2[3] = 1;
          ENC_HEX[1] = 1;
          ENC_HEX[3] = 1;
          ENC_HEX[5] = 1;
        end else begin            // =     100_1011_xxxxx
          ENC_AN_T1[3] = 1;
          ENC_AN_T2[1] = 1;
          ENC_AN_T2[2] = 1;
          ENC_AN_T2[4] = 1;
        end
      end
      if (PL1A_17_CNT_117) begin  // v V   x11_0101_11011
        ENC_AN_T1[1] = 1;
        ENC_AN_T1[2] = 1;
        ENC_AN_T2[1] = 1;
        ENC_AN_T2[3] = 1;
        ENC_HEX[1] = 1;
        ENC_HEX[2] = 1;
        ENC_HEX[4] = 1;
        ENC_HEX[5] = 1;
      end
      if (PL1A_18_CNT_118) begin  // t T   x11_0011_xxxxx
        ENC_AN_T1[1] = 1;
        ENC_AN_T1[2] = 1;
        ENC_AN_T2[1] = 1;
        ENC_AN_T2[2] = 1;
      end
      if (PL1A_19_CNT_119) begin  // g G   x01_0111_xxxxx
        ENC_AN_T1[1] = 1;
        ENC_AN_T2[1] = 1;
        ENC_AN_T2[2] = 1;
        ENC_AN_T2[3] = 1;
      end
      if (PL1A_20_CNT_120) begin  // 6 ≠   x00_0110_10110
        ENC_AN_T2[2] = 1;
        ENC_AN_T2[3] = 1;
        ENC_HEX[2] = 1;
        ENC_HEX[3] = 1;
        ENC_HEX[5] = 1;
      end
      if (PL1A_21_CNT_121) begin  // b B   x01_0010_xxxxx
        ENC_AN_T1[1] = 1;
        ENC_AN_T2[2] = 1;
      end
      if (PL1A_22_CNT_122) begin  // y Y   x11_1000_11110
        ENC_AN_T1[1] = 1;
        ENC_AN_T1[2] = 1;
        ENC_AN_T2[4] = 1;
        ENC_HEX[2] = 1;
        ENC_HEX[3] = 1;
        ENC_HEX[4] = 1;
        ENC_HEX[5] = 1;
      end
      if (PL1A_23_CNT_123) begin  // h H   x01_1000_xxxxx
        ENC_AN_T1[1] = 1;
        ENC_AN_T2[4] = 1;
      end
      if (PL1A_24_CNT_124) begin  // 7 [   x00_0111_10111
        ENC_AN_T2[1] = 1;
        ENC_AN_T2[2] = 1;
        ENC_AN_T2[3] = 1;
        ENC_HEX[1] = 1;
        ENC_HEX[2] = 1;
        ENC_HEX[3] = 1;
        ENC_HEX[5] = 1;
      end
      if (PL1A_25_CNT_125) begin  // n N   x10_0101_xxxxx
        ENC_AN_T1[2] = 1;
        ENC_AN_T2[1] = 1;
        ENC_AN_T2[3] = 1;
      end
      if (PL1A_26_CNT_126) begin  // u U   x11_0100_11010
        ENC_AN_T1[1] = 1;
        ENC_AN_T1[2] = 1;
        ENC_AN_T2[3] = 1;
        ENC_HEX[2] = 1;
        ENC_HEX[4] = 1;
        ENC_HEX[5] = 1;
      end
      if (PL1A_27_CNT_127) begin  // j J   x10_0001_xxxxx
        ENC_AN_T1[2] = 1;
        ENC_AN_T2[1] = 1;
      end
      if (PL1A_28_CNT_128) begin  // 8 ]   x00_1000_11000
        ENC_AN_T2[4] = 1;
        ENC_HEX[4] = 1;
        ENC_HEX[5] = 1;
      end
      if (PL1A_29_CNT_129) begin  // m M   x10_0100_xxxxx
        ENC_AN_T1[2] = 1;
        ENC_AN_T2[3] = 1;
      end
      if (PL1A_30_CNT_130) begin  // i I   x01_1001_xxxxx
        ENC_AN_T1[1] = 1;
        ENC_AN_T2[1] = 1;
        ENC_AN_T2[4] = 1;
      end
      if (PL1A_31_CNT_131) begin  // k K   x10_0010_xxxxx
        ENC_AN_T1[2] = 1;
        ENC_AN_T2[2] = 1;
      end
      if (PL1A_32_CNT_132) begin  // 9 (
        if (~RY14_UP) begin       // 9     x00_1001_11001
          ENC_AN_T2[1] = 1;
          ENC_AN_T2[4] = 1;
        end else begin            // (     x11_1100_11001
          ENC_AN_T1[1] = 1;
          ENC_AN_T1[2] = 1;
          ENC_AN_T2[3] = 1;
          ENC_AN_T2[4] = 1;
        end
        ENC_HEX[1] = 1;
        ENC_HEX[4] = 1;
        ENC_HEX[5] = 1;
      end
      if (PL1A_33_CNT_133) begin  // , ↑   x11_1011_xxxxx
        ENC_AN_T1[1] = 1;
        ENC_AN_T1[2] = 1;
        ENC_AN_T2[1] = 1;
        ENC_AN_T2[2] = 1;
        ENC_AN_T2[4] = 1;
      end
      if (PL1A_34_CNT_134) begin  // o O   x10_0110_xxxxx
        ENC_AN_T1[2] = 1;
        ENC_AN_T2[2] = 1;
        ENC_AN_T2[3] = 1;   
      end
      if (PL1A_35_CNT_135) begin  // l L   x10_0011_xxxxx
        ENC_AN_T1[2] = 1;
        ENC_AN_T2[1] = 1;
        ENC_AN_T2[2] = 1;
      end
      if (PL1A_36_CNT_136) begin  // 0 )
        if (~RY14_UP) begin       // 0     x00_0000_10000
        end else begin            // )     101_1100_10000
          ENC_AN_T1[1] = 1;
          ENC_AN_T1[3] = 1;
          ENC_AN_T2[3] = 1;
          ENC_AN_T2[4] = 1;
        end
        ENC_HEX[5] = 1;
      end
      if (PL1A_37_CNT_137) begin  // . ?   x01_1011_0x110   ***
      end
      if (PL1A_38_CNT_138) begin  // p P   x10_0111_xxxxx
        ENC_AN_T1[2] = 1;
        ENC_AN_T2[1] = 1;
        ENC_AN_T2[2] = 1;
        ENC_AN_T2[3] = 1;
      end
      if (PL1A_39_CNT_139) begin  // ; :   x01_1101_xxxxx
        ENC_AN_T1[1] = 1;
        ENC_AN_T2[1] = 1;
        ENC_AN_T2[3] = 1;
        ENC_AN_T2[4] = 1;
      end
      if (PL1A_40_CNT_140) begin  // 1 √   x00_0001_10001
        ENC_AN_T2[1] = 1;
        ENC_HEX[1] = 1;
        ENC_HEX[5] = 1;
      end
      if (PL1A_41_CNT_141) begin  // / ⚬
        if (~RY14_UP) begin       // /     x11_0001_xxxxx
        end else begin            // ⚬     x11_0000_xxxxx
        end
      end
      if (PL1A_42_CNT_142) begin  // ∧ ∨   x01_1110_xxxxx
        ENC_AN_T1[1] = 1;
        ENC_AN_T2[2] = 1;
        ENC_AN_T2[3] = 1;
        ENC_AN_T2[4] = 1;
      end
      if (PL1A_43_CNT_143) begin  // < >   x01_1010_xxxxx
        ENC_AN_T1[1] = 1;
        ENC_AN_T2[2] = 1;
        ENC_AN_T2[4] = 1;
      end
      if (PL1A_44_CNT_144) begin  // * -
        if (~RY14_UP) begin       // *     110_1100_00001
          ENC_AN_T1[2] = 1;
          ENC_AN_T1[3] = 1;
          ENC_AN_T2[3] = 1;
          ENC_AN_T2[4] = 1;
        end else begin            // -     010_0000_00001
          ENC_AN_T1[2] = 1;
        end
        ENC_HEX[1] = 1;
      end
      if (RY16_TAB) begin         // TAB   x10_1101_00011
        ENC_AN_T1[2] = 1;
        ENC_AN_T2[1] = 1;
        ENC_AN_T2[3] = 1;
        ENC_AN_T2[4] = 1;
        ENC_HEX[1] = 1;
        ENC_HEX[2] = 1;
      end
      if (RY17_CR) begin          // CR    x10_1010_00010
        ENC_AN_T1[2] = 1;
        ENC_AN_T2[2] = 1;
        ENC_AN_T2[4] = 1;
        ENC_HEX[2] = 1;
      end
      if (RY15_SP) begin          // Space x11_1101_00000
        ENC_AN_T1[1] = 1;
        ENC_AN_T1[2] = 1;
        ENC_AN_T2[1] = 1;
        ENC_AN_T2[3] = 1;
        ENC_AN_T2[4] = 1;
      end
      if (LOWER_CASE) begin
        ENC_AN_T1[3] = 1;
      end

      // Level code mux.
      PL1_13_LEV1_OUT = ~RY13_AN_NOT_SA? ENC_HEX[1] : RY20_XFER? ENC_AN_T2[1] : ENC_AN_T1[1];
      PL1_14_LEV2_OUT = ~RY13_AN_NOT_SA? ENC_HEX[2] : RY20_XFER? ENC_AN_T2[2] : ENC_AN_T1[2];
      //PL1_15_LEV3_OUT = 
      PL1_16_LEV4_OUT = ~RY13_AN_NOT_SA? ENC_HEX[4] : RY20_XFER? ENC_AN_T2[4] : ENC_AN_T1[4];
      PL1_12_LEV5_OUT = (T1 | T2) & RY13_AN_NOT_SA;

      // Function key contacts are wired directly to G-15 logic via PL1
      PL1_2_KEY_CIR_S = PL1A_1_CNT_101;
      PL1_1_KEY_A     = PL1A_3_CNT_103;
      PL1_22_KEY_B    = PL1A_21_CNT_121;
      PL1_21_KEY_C    = PL1A_13_CNT_113;
      PL1_20_KEY_E    = PL1A_10_CNT_110;
      PL1_3_KEY_F     = PL1A_15_CNT_115;
      PL1_5_KEY_I     = PL1A_30_CNT_130;
      PL1_6_KEY_M     = PL1A_29_CNT_129;
      PL1_7_KEY_P     = PL1A_38_CNT_138;
      PL1_8_KEY_Q     = PL1A_2_CNT_102;
      PL1_9_KEY_R     = PL1A_14_CNT_114;
      PL1_10_KEY_T    = PL1A_18_CNT_118;
    end

    // Relays have a typical 10ms pull-in and pull-out time.
    relay #(.T1(10), .T2(10)) ry1   (.*, .clk(CLOCK), .pick(RY1_LEV1_e),       .pulled(RY1_LEV1));
    relay #(.T1(10), .T2(10)) ry2   (.*, .clk(CLOCK), .pick(RY2_LEV2_e),       .pulled(RY2_LEV2));
    relay #(.T1(10), .T2(10)) ry3   (.*, .clk(CLOCK), .pick(RY3_LEV3_e),       .pulled(RY3_LEV3));
    relay #(.T1(10), .T2(10)) ry4   (.*, .clk(CLOCK), .pick(RY4_LEV4_e),       .pulled(RY4_LEV4));
    relay #(.T1(10), .T2(10)) ry5   (.*, .clk(CLOCK), .pick(RY5_LEV5_e),       .pulled(RY5_LEV5));
    relay #(.T1(10), .T2(10)) ry6   (.*, .clk(CLOCK), .pick(RY6_ALPHA5_e),     .pulled(RY6_ALPHA5));
    relay #(.T1(10), .T2(10)) ry7   (.*, .clk(CLOCK), .pick(RY7_ALPHA6_e),     .pulled(RY7_ALPHA6));
    relay #(.T1(10), .T2(10)) ry8   (.*, .clk(CLOCK), .pick(RY8_AN_e),         .pulled(RY8_AN));
    relay #(.T1(10), .T2(10)) ry9   (.*, .clk(CLOCK), .pick(RY9_EXC_e),        .pulled(RY9_EXC));
    relay #(.T1(10), .T2(10)) ry10  (.*, .clk(CLOCK), .pick(RY10_TYPE_e),      .pulled(RY10_TYPE));
    relay #(.T1(10), .T2(10)) ry11a (.*, .clk(CLOCK), .pick(RY11A_SHIFT_e),    .pulled(RY11A_SHIFT));
    relay #(.T1(15), .T2(10)) ry11b (.*, .clk(CLOCK), .pick(RY11B_INT_e),      .pulled(RY11B_INT));
    relay #(.T1(10), .T2(10)) ry12  (.*, .clk(CLOCK), .pick(RY12_SA_e),        .pulled(RY12_SA));
    relay #(.T1(10), .T2(10)) ry13  (.*, .clk(CLOCK), .pick(RY13_AN_NOT_SA_e), .pulled(RY13_AN_NOT_SA));
    relay #(.T1(10), .T2(10)) ry14  (.*, .clk(CLOCK), .pick(RY14_UP_e),        .pulled(RY14_UP));
    relay #(.T1(10), .T2(10)) ry15  (.*, .clk(CLOCK), .pick(RY15_SP_e),        .pulled(RY15_SP));
    relay #(.T1(10), .T2(10)) ry16  (.*, .clk(CLOCK), .pick(RY16_TAB_e),       .pulled(RY16_TAB));
    relay #(.T1(10), .T2(10)) ry17  (.*, .clk(CLOCK), .pick(RY17_CR_e),        .pulled(RY17_CR));
    relay #(.T1(10), .T2(10)) ry18  (.*, .clk(CLOCK), .pick(RY18_e),           .pulled(RY18));
    relay #(.T1(10), .T2(10)) ry19  (.*, .clk(CLOCK), .pick(RY19_e),           .pulled(RY19));
    relay #(.T1(10), .T2(10)) ry20  (.*, .clk(CLOCK), .pick(RY20_XFER_e),      .pulled(RY20_XFER));

endmodule
