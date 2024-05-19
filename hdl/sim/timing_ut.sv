`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/18/2024 08:29:45 AM
// Design Name: 
// Module Name: timing_ut
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module timing_ut (

    );
    
    logic clk, rst;
    
    logic CJ;   // Read Command FF (Control Gate)
    logic CN;   // Number Line FF
    
    logic RC;   // Read Command (Control Gate)
    
    logic CL;  // G15 clock
    logic CR;  // G15 shift clock
    
    logic T0;
    logic T1;
    logic T2;
    logic T13;
    logic T21;
    logic T28;
    logic T29;
    
    timing timing_uut (.*);
    
    initial begin
        clk <= 1'b0;
        rst <= 1'b1;
        
        CJ <= 1'b0;
        CN <= 1'b0;
        RC <= 1'b0;
        
        // 50% duty cycle clock
        forever #(5) clk <= ~clk;
    end
    
    initial begin
        // wait 10 clocks then drop reset
        repeat (10) @(posedge clk);
        rst <= 1'b0;
        
        // wait 200 clocks then end test
        repeat (200) @(posedge clk);
        $finish;
    end

endmodule
