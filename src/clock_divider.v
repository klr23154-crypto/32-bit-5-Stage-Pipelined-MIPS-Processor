`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.05.2026 22:36:00
// Design Name: 
// Module Name: clock_divider
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


module clock_divider(
    input clk_in,      // 100MHz clock from the Nexys A7 board
    output reg clk_out // 1Hz slow clock to your processor
);
    // We need a counter big enough to reach 50,000,000
    reg [25:0] count; 

    initial begin
        count = 0;
        clk_out = 0;
    end

    always @(posedge clk_in) begin
        if (count == 26'd49_999_999) begin
            count <= 0;
            clk_out <= ~clk_out; // Flip the clock every 0.5 seconds
        end else begin
            count <= count + 1;
        end
    end
endmodule
