`timescale 1ns / 1ps

module tape_reader_ut (
    );
    
    logic clk;
    logic rst;
    
    logic tick_ms;
    
    logic PL6_PHOTO1, PL6_PHOTO2, PL6_PHOTO3, PL6_PHOTO4, PL6_PHOTO5;
    logic PL6_PHOTO_TAPE_FWD;      // PL6-9  to relay RY-A
    logic PL6_PHOTO_TAPE_REV;      // PL6-10 to relay RY-B
    logic PL6_REMOTE_REWIND;       // connects to SW_REWIND on the typewriter adapter. When
    // closed, it energizes R4-C, starting the reverse motor and disabling the
    // REWIND position of SWITCH_1 on the photo reader.
    logic PL6_WAIT_FOR_TAPE;        // PL6-18 when RY-A or RY-B is energized
    logic PL6_TAPE_RUN_SW;          // PL6-17 to punch
    logic SW1_REWIND;
    logic SW1_FORWARD;
    logic SW2;
    
    timer timer_uut(.*, .tick(tick_ms));
    tape_reader tape_reader_uut(.*); 
    
    initial begin
        clk <= 1'b0;
        rst <= 1'b1;
        PL6_PHOTO_TAPE_FWD <= 0;
        PL6_PHOTO_TAPE_REV <= 0;
        PL6_REMOTE_REWIND <= 0;
        SW1_REWIND <= 0;
        SW1_FORWARD <= 0;
        SW2 <= 0;
                
        // 9.3us 50% duty cycle clock
        forever #(4650) clk <= ~clk;
    end
    
    initial begin
      repeat(500) @(posedge clk);
      rst <= 0;
      repeat(10) @(posedge tick_ms);
      PL6_PHOTO_TAPE_FWD <= 1;
      repeat(10000) @(posedge tick_ms);
      PL6_PHOTO_TAPE_FWD <= 0;
      repeat(100) @(posedge tick_ms);
      $finish;
    end
      
endmodule
