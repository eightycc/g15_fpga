`timescale 1ns / 1ps

module anc_2_ut (
);
    logic rst;
    logic clk;
    logic tick_ms;

    // PL1 connector to G-15
    logic PL1_18_AN;        // AS
    logic PL1_33_TYPE;      // TYPE
    logic PL1_29_EXC;       // TYPE_PULSE
    logic PL1_26_LEV1_IN;   // OB1
    logic PL1_25_LEV2_IN;   // OB2
    logic PL1_24_LEV3_IN;   // OB3
    logic PL1_23_LEV4_IN;   // OB4
    logic PL1_27_LEV5_IN;   // OB5 & (~AS | ~OY & OH)
    // Function key inputs. When a function key is pressed and the ENABLE switch
    // is on;the key signal will last ~40-60 ms. This is the total time that the
    // typewriter escapement keeps the key contacts closed.  
    logic PL1_2_KEY_CIR_S;  // <Ⓢ>
    logic PL1_1_KEY_A;      // <A>
    logic PL1_22_KEY_B;     // <B>
    logic PL1_21_KEY_C;     // <C>
    logic PL1_20_KEY_E;     // <E>
    logic PL1_3_KEY_F;      // <F>
    logic PL1_5_KEY_I;      // <I>
    logic PL1_6_KEY_M;      // <M>
    logic PL1_7_KEY_P;      // <P>
    logic PL1_8_KEY_Q;      // <Q>
    logic PL1_9_KEY_R;      // <R>
    logic PL1_10_KEY_T;     // <T>
    logic PL1_11_SA;        // <SA> = ~RY10(TYPE) & RY12(SA)
    logic PL1_28_REWIND;    // <REWIND>
    logic PL1_4_PUNCH;      // <PUNCH>
    logic PL1_30_GO;        // <GO>
    logic PL1_31_NO_GO;     // <~GO>
    logic PL1_32_BP;        // <BP>
    logic PL1_13_LEV1_OUT;  // LEV1
    logic PL1_14_LEV2_OUT;  // LEV2
    logic PL1_15_LEV3_OUT;  // LEV3 = TYPE? SP|CR|TAB|SA : encoder bit 3
                                    // (provides feedback for OUTPUT)
    logic PL1_16_LEV4_OUT;  // LEV4
    logic PL1_12_LEV5_OUT;  // LEV5
    logic PL1_17_F_B;       // <F-B>

    // PL2A connector to I/O Writer
    // Typebar magnets identified by their IBM magnet number
    logic PL2A_1_MAG_42;    // < >
    logic PL2A_2_MAG_40;    // / ⚬
    logic PL2A_3_MAG_38;    // : ;
    logic PL2A_4_MAG_36;    // . ?
    logic PL2A_5_MAG_34;    // l L
    logic PL2A_6_MAG_32;    // ;↑
    logic PL2A_7_MAG_30;    // k K
    logic PL2A_8_MAG_28;    // m M
    logic PL2A_9_MAG_26;    // j J
    logic PL2A_10_MAG_24;   // n N
    logic PL2A_11_MAG_22;   // h H
    logic PL2A_12_MAG_20;   // b B
    logic PL2A_13_MAG_18;   // g G
    logic PL2A_14_MAG_16;   // v V
    logic PL2A_15_MAG_14;   // f F
    logic PL2A_16_MAG_12;   // c C
    logic PL2A_17_MAG_10;   // d D
    logic PL2A_18_MAG_8;    // x X
    logic PL2A_19_MAG_6;    // s S
    logic PL2A_20_MAG_4;    // z Z
    logic PL2A_21_MAG_2;    // a A
    logic PL2A_22_MAG_0;    // Ⓢ Ⓢ
    logic PL2A_23_MAG_43;   // * -
    logic PL2A_24_MAG_41;   // ∧ ∨
    logic PL2A_25_MAG_39;   // 1 √
    logic PL2A_26_MAG_37;   // p P
    logic PL2A_27_MAG_35;   // 0 )
    logic PL2A_28_MAG_33;   // o O
    logic PL2A_29_MAG_31;   // 9 (
    logic PL2A_30_MAG_29;   // i I
    logic PL2A_31_MAG_27;   // 8 ]
    logic PL2A_32_MAG_25;   // u U
    logic PL2A_33_MAG_23;   // 7 [
    logic PL2A_34_MAG_21;   // y Y
    logic PL2A_35_MAG_19;   // 6 ≠
    logic PL2A_36_MAG_17;   // t T
    logic PL2A_37_MAG_15;   // 5 =
    logic PL2A_38_MAG_13;   // r R
    logic PL2A_39_MAG_11;   // 4 $
    logic PL2A_40_MAG_9;    // e E
    logic PL2A_41_MAG_7;    // 3 → 
    logic PL2A_42_MAG_5;    // w W
    logic PL2A_43_MAG_3;    // 2 +
    logic PL2A_44_MAG_1;    // q Q
    // Control magnets:
    logic PL2A_45_MAG_CR;
    logic PL2A_46_MAG_SHIFT;
    logic PL2A_47_MAG_TAB;
    logic PL2A_48_MAG_SPACE;
    // Interlock contacts:
    //logic PL2A_53_ILK;     // Ribbon interlock input
    //logic PL2A_52_ILK_O;   // Ribbon interlock output
    logic PL2A_55_ILK;     // Space;CR;TAB interlock input
    logic PL2A_54_ILK_O;   // Space;CR;TAB interlock output
    //logic PL2A_57_ILK;     // Character interlock input
    //logic PL2A_56_ILK_O;   // Character interlock output
    // Shift basket position:
    logic PL2A_58_SHIFT_O; // Shift common contact
    logic PL2A_59_SHIFT_UP;     // Shift up
    //logic PL2A_60_SHIFT_DOWN;   // Shift down

    // PLM_2A connector to I/O Writer
    // Signals are identified by their IBM contact number
    logic PL1A_1_CNT_101;  // Ⓢ Ⓢ
    logic PL1A_2_CNT_102;  // q Q
    logic PL1A_3_CNT_103;  // a A
    logic PL1A_4_CNT_104;  // 2 +
    logic PL1A_5_CNT_105;  // z Z
    logic PL1A_6_CNT_106;  // w W
    logic PL1A_7_CNT_107;  // s S
    logic PL1A_8_CNT_108;  // 3 →
    logic PL1A_9_CNT_109;  // x X
    logic PL1A_10_CNT_110; // e E
    logic PL1A_11_CNT_111; // d D
    logic PL1A_12_CNT_112; // 4 $
    logic PL1A_13_CNT_113; // c C
    logic PL1A_14_CNT_114; // r R
    logic PL1A_15_CNT_115; // f F
    logic PL1A_16_CNT_116; // 5 =
    logic PL1A_17_CNT_117; // v V
    logic PL1A_18_CNT_118; // t T
    logic PL1A_19_CNT_119; // g G
    logic PL1A_20_CNT_120; // 6 ≠
    logic PL1A_21_CNT_121; // b B
    logic PL1A_22_CNT_122; // y Y
    logic PL1A_23_CNT_123; // h H
    logic PL1A_24_CNT_124; // 7 [
    logic PL1A_25_CNT_125; // n N
    logic PL1A_26_CNT_126; // u U
    logic PL1A_27_CNT_127; // j J
    logic PL1A_28_CNT_128; // 8 ]
    logic PL1A_29_CNT_129; // m M
    logic PL1A_30_CNT_130; // i I
    logic PL1A_31_CNT_131; // k K
    logic PL1A_32_CNT_132; // 9 (
    logic PL1A_33_CNT_133; // ;↑
    logic PL1A_34_CNT_134; // o O
    logic PL1A_35_CNT_135; // l L
    logic PL1A_36_CNT_136; // 0 )
    logic PL1A_37_CNT_137; // . ?
    logic PL1A_38_CNT_138; // p P
    logic PL1A_39_CNT_139; // ; :
    logic PL1A_40_CNT_140; // 1 √
    logic PL1A_41_CNT_141; // / ⚬
    logic PL1A_42_CNT_142; // ∧ ∨
    logic PL1A_43_CNT_143; // < >
    logic PL1A_44_CNT_144; // * -
    logic PL1A_72_KB_SCAN; // Keyboard contact common scan

    logic PL1A_48_CNT_CR;    // CR contact
    //logic PL1A_49_CNT_SHIFT; // SHIFT contact
    logic PL1A_46_CNT_TAB;   // TAB contact
    logic PL1A_47_CNT_SPACE; // SPACE contact
    logic PL1A_70_CNT_COMMON;// Ribbon cam driven key common contact
    //logic PL1A_52_CNT_TAB_FB;// TAB feedback contact
    logic PL1A_45_CTRL_SCAN; // Control contact common scan

    logic PL1A_61_SA;        // ENABLE SW-1 SA contact
    logic PL1A_64_REWIND;    // PAPERTAPE SW-2 REWIND contact
    logic PL1A_59_PUNCH;     // PAPERTAPE SW-3 PUNCH contact
    logic PL1A_51_GO;        // COMPUTE SW-4 GO contact
    logic PL1A_53_BP;        // COMPUTE SW-4 BP contact
    logic PL1A_55_NO_GO;     // COMPUTE SW-4 NO GO contact

    timer timer_uut(.*, .tick(tick_ms));
    anc_2 anc_2_uut (.*, .CLOCK(clk));

    initial begin
        rst = 1;
        clk = 0;
        tick_ms = 0;
        // 9.3us 50% duty cycle clock
        forever #(4650) clk = ~clk;
    end

    initial begin
        PL1_18_AN = 0;
        PL1_33_TYPE = 0;
        PL1_29_EXC = 0;
        PL1_26_LEV1_IN = 0;
        PL1_25_LEV2_IN = 0;
        PL1_24_LEV3_IN = 0;
        PL1_23_LEV4_IN = 0;
        PL1_27_LEV5_IN = 0;

        PL2A_55_ILK = 0;
        PL2A_59_SHIFT_UP = 0;

        PL1A_1_CNT_101 = 0;
        PL1A_2_CNT_102 = 0;
        PL1A_3_CNT_103 = 0;
        PL1A_4_CNT_104 = 0;
        PL1A_5_CNT_105 = 0;
        PL1A_6_CNT_106 = 0;
        PL1A_7_CNT_107 = 0;
        PL1A_8_CNT_108 = 0;
        PL1A_9_CNT_109 = 0;
        PL1A_10_CNT_110 = 0;
        PL1A_11_CNT_111 = 0;
        PL1A_12_CNT_112 = 0;
        PL1A_13_CNT_113 = 0;
        PL1A_14_CNT_114 = 0;
        PL1A_15_CNT_115 = 0;
        PL1A_16_CNT_116 = 0;
        PL1A_17_CNT_117 = 0;
        PL1A_18_CNT_118 = 0;
        PL1A_19_CNT_119 = 0;
        PL1A_20_CNT_120 = 0;
        PL1A_21_CNT_121 = 0;
        PL1A_22_CNT_122 = 0;
        PL1A_23_CNT_123 = 0;
        PL1A_24_CNT_124 = 0;
        PL1A_25_CNT_125 = 0;
        PL1A_26_CNT_126 = 0;
        PL1A_27_CNT_127 = 0;
        PL1A_28_CNT_128 = 0;
        PL1A_29_CNT_129 = 0;
        PL1A_30_CNT_130 = 0;
        PL1A_31_CNT_131 = 0;
        PL1A_32_CNT_132 = 0;
        PL1A_33_CNT_133 = 0;
        PL1A_34_CNT_134 = 0;
        PL1A_35_CNT_135 = 0;
        PL1A_36_CNT_136 = 0;
        PL1A_37_CNT_137 = 0;
        PL1A_38_CNT_138 = 0;
        PL1A_39_CNT_139 = 0;
        PL1A_40_CNT_140 = 0;
        PL1A_41_CNT_141 = 0;
        PL1A_42_CNT_142 = 0;
        PL1A_43_CNT_143 = 0;
        PL1A_44_CNT_144 = 0;
        PL1A_48_CNT_CR = 0;
        //PL1A_49_CNT_SHIFT = 0;
        PL1A_46_CNT_TAB = 0;
        PL1A_47_CNT_SPACE = 0;
        PL1A_70_CNT_COMMON = 0;
        //PL1A_52_CNT_TAB_FB = 0;
        PL1A_61_SA = 0;
        PL1A_64_REWIND = 0;
        PL1A_59_PUNCH = 0;
        PL1A_51_GO = 0;
        PL1A_53_BP = 0;
        PL1A_55_NO_GO = 0;
    end

    initial begin
        repeat(10) @(posedge clk);
        rst = 0;

        // throw ENABLE switch on
        repeat(10) @(posedge tick_ms);
        PL1A_61_SA = 1;
        repeat(100) @(posedge tick_ms);

        // press A key
        PL1A_3_CNT_103 = 1;
        repeat(10) @(posedge tick_ms);
        PL1A_70_CNT_COMMON = 1;
        repeat(30) @(posedge tick_ms);
        PL1A_70_CNT_COMMON = 0;
        repeat(50) @(posedge tick_ms);
        PL1A_3_CNT_103 = 0;

        // throw ENABLE switch off
        PL1A_61_SA = 0;
        repeat(100) @(posedge tick_ms);

        // press A key
        PL1A_3_CNT_103 = 1;
        repeat(10) @(posedge tick_ms);
        PL1A_70_CNT_COMMON = 1;
        repeat(30) @(posedge tick_ms);
        PL1A_70_CNT_COMMON = 0;
        repeat(50) @(posedge tick_ms);
        PL1A_3_CNT_103 = 0;

        // put coupler in alphnumeric mode
        PL1_18_AN = 1;
        repeat(50) @(posedge tick_ms);

        // press A key
        PL1A_3_CNT_103 = 1;
        repeat(10) @(posedge tick_ms);
        PL1A_70_CNT_COMMON = 1;
        repeat(30) @(posedge tick_ms);
        PL1A_70_CNT_COMMON = 0;
        repeat(50) @(posedge tick_ms);
        PL1A_3_CNT_103 = 0;
        repeat(100) @(posedge tick_ms);

        // ---------------------------------------------------------

        // put coupler into numeric mode
        PL1_18_AN = 0;

        // throw ENABLE switch on
        repeat(100) @(posedge tick_ms);
        PL1A_61_SA = 1;
        repeat(100) @(posedge tick_ms);

        // press B key
        PL1A_21_CNT_121 = 1;
        repeat(10) @(posedge tick_ms);
        PL1A_70_CNT_COMMON = 1;
        repeat(30) @(posedge tick_ms);
        PL1A_70_CNT_COMMON = 0;
        repeat(50) @(posedge tick_ms);
        PL1A_21_CNT_121 = 0;

        // throw ENABLE switch off
        PL1A_61_SA = 0;
        repeat(100) @(posedge tick_ms);

        // press B key
        PL1A_21_CNT_121 = 1;
        repeat(10) @(posedge tick_ms);
        PL1A_70_CNT_COMMON = 1;
        repeat(30) @(posedge tick_ms);
        PL1A_70_CNT_COMMON = 0;
        repeat(50) @(posedge tick_ms);
        PL1A_21_CNT_121 = 0;

        // put coupler in alphnumeric mode
        PL1_18_AN = 1;
        repeat(50) @(posedge tick_ms);

        // press B key
        PL1A_21_CNT_121 = 1;
        repeat(10) @(posedge tick_ms);
        PL1A_70_CNT_COMMON = 1;
        repeat(30) @(posedge tick_ms);
        PL1A_70_CNT_COMMON = 0;
        repeat(50) @(posedge tick_ms);
        PL1A_21_CNT_121 = 0;


        repeat(100) @(posedge tick_ms);
        $finish;
    end

endmodule