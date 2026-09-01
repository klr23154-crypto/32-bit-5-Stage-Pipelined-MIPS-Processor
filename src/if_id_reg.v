`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.05.2026 23:08:57
// Design Name: 
// Module Name: if_id_reg
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

module if_id_reg(
    input clk,
    input reset,
    input en, // <-- NEW: The Brakes!
    
    // Inputs coming from the IF Stage 
    input [31:0] if_pc_plus_4,
    input [31:0] if_instruction,
    
    // Outputs going into the ID Stage 
    output reg [31:0] id_pc_plus_4,
    output reg [31:0] id_instruction
);

    always @(posedge clk) begin
        if (reset) begin
            id_pc_plus_4   <= 32'b0;
            id_instruction <= 32'b0;
        end else if (en) begin     // <-- NEW: Only catch data if brakes are OFF
            id_pc_plus_4   <= if_pc_plus_4;
            id_instruction <= if_instruction;
        end
    end

endmodule
