`timescale 1ns / 1ps


module timer_ut (
    );
    
    logic clk, rst;
    logic tick;
    
    timer timer_uut(.*);
    
    initial begin
        clk <= 1'b0;
        rst <= 1'b1;
                
        // 9.3us 50% duty cycle clock
        forever #(4650) clk <= ~clk;
    end
    
    initial begin
        repeat(10) @(posedge clk);
        rst = 1;
        repeat(10) @(posedge clk);
        rst = 0;
        
        repeat(5) @(posedge tick);
        $finish;
    end

endmodule
