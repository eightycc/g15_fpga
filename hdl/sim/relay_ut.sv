`timescale 1ns / 1ps

module relay_ut( );

  logic clk, rst;
  
  logic tick_ms;
  
  logic pick;
  logic pulled;
  
  timer timer_uut(.*, .tick(tick_ms));
  relay relay_uut(.*);
  
  initial begin
    clk <= 0;
    rst <= 1;
    pick <= 0;
                
    // 9.3us 50% duty cycle clock
    forever #(4650) clk <= ~clk;
  end
  
  initial begin
    repeat(10) @(posedge clk);
    rst <= 0;
    
    repeat(100) @(posedge clk);
    pick <= 1;
    repeat(5) @(posedge tick_ms);
    pick <= 0;
    repeat(50) @(posedge tick_ms);
    pick <= 1;
    repeat(40) @(posedge tick_ms);
    pick <= 0;
    repeat(50) @(posedge tick_ms);
    $finish;
  end
  
endmodule
