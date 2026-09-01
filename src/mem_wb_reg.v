`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.05.2026 23:14:16
// Design Name: 
// Module Name: mem_wb_reg
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

module mem_wb_reg(
    input clk,
    input reset,
    
    // 1. Control Signals (The last remaining items in the backpack)
    input mem_RegWrite, mem_MemtoReg,
    
    // 2. Data from Memory Stage
    input [31:0] mem_read_data,   // Data pulled out of RAM
    input [31:0] mem_alu_result,  // The math answer that bypassed RAM
    input [4:0]  mem_write_reg,   // The destination register

    // ------------------------------------------------------------
    // OUTPUTS to the Writeback Stage
    // ------------------------------------------------------------
    output reg wb_RegWrite, wb_MemtoReg,
    
    output reg [31:0] wb_read_data,
    output reg [31:0] wb_alu_result,
    output reg [4:0]  wb_write_reg
);

    always @(posedge clk) begin
        if (reset) begin
            wb_RegWrite <= 0; 
            wb_MemtoReg <= 0;
            wb_read_data <= 0; 
            wb_alu_result <= 0;
            wb_write_reg <= 0;
        end else begin
            wb_RegWrite   <= mem_RegWrite; 
            wb_MemtoReg   <= mem_MemtoReg;
            wb_read_data  <= mem_read_data; 
            wb_alu_result <= mem_alu_result;
            wb_write_reg  <= mem_write_reg;
        end
    end

endmodule
