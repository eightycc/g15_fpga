`timescale 1ns / 1ps


module delay #(
    parameter D = 1
    ) (
    input clk,
    input rst,
    input one_ms,
    input start,
    output logic pulse
    );
    
    localparam W = $clog2(D);
    
    logic [W-1:0] ctr;
    logic [1:0] state;
    
    always @(posedge clk) begin
      if (rst) begin
        ctr <= 0;
        state <= 0; // states are: 0(idle), 1(running)
      end else begin
        if (state == 0) begin
          if (start) begin
            ctr <= D;
            state <= 1;
          end
        end else begin
          if (ctr == 0) begin
            state <= 0;
          end else begin
            ctr <= ctr - 1;
          end
        end
      end
    end
    
    always @(posedge clk) begin
      if (rst) begin
        pulse <= 0;
      end else begin
        pulse <= (state == 1 && ctr == 0)? 1 : 0;
      end
    end
endmodule
