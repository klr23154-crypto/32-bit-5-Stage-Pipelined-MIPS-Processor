`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.05.2026 23:14:13
// Design Name: 
// Module Name: pc
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


module pc(
    input clk,
    input reset,               // High when we want to restart the processor
    input [31:0] next_pc,      // The address we want to go to next
    output reg [31:0] current_pc // The address we are currently at
);

    // The PC only updates when the clock ticks (Sequential Logic)
    always @(posedge clk) begin
        if (reset == 1'b1) begin
            // If the reset button is held down, force the PC back to address 0
            current_pc <= 32'b0;
        end else begin
            // Otherwise, load the next address
            current_pc <= next_pc;
        end
    end

endmodule