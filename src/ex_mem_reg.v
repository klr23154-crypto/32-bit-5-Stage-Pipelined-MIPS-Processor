`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.05.2026 23:12:59
// Design Name: 
// Module Name: ex_mem_reg
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

module ex_mem_reg(
    input clk,
    input reset,
    
    // 1. Control Signals (Backpack going to MEM and WB)
    input ex_RegWrite, ex_MemtoReg, ex_Branch, 
    input ex_MemRead, ex_MemWrite,
    
    // 2. Data from Execute Stage
    input [31:0] ex_branch_target, // Calculated PC jump address
    input ex_zero_flag,            // Did the ALU output exactly zero?
    input [31:0] ex_alu_result,    // The math answer (or RAM address)
    input [31:0] ex_read_data2,    // The data to save to RAM (for Store Word)
    input [4:0]  ex_write_reg,     // The destination register

    // ------------------------------------------------------------
    // OUTPUTS to the Memory Stage
    // ------------------------------------------------------------
    output reg mem_RegWrite, mem_MemtoReg, mem_Branch, 
    output reg mem_MemRead, mem_MemWrite,
    
    output reg [31:0] mem_branch_target,
    output reg mem_zero_flag,
    output reg [31:0] mem_alu_result,
    output reg [31:0] mem_write_data, // Renamed to write_data for clarity in RAM
    output reg [4:0]  mem_write_reg
);

    always @(posedge clk) begin
        if (reset) begin
            mem_RegWrite <= 0; mem_MemtoReg <= 0; mem_Branch <= 0;
            mem_MemRead <= 0; mem_MemWrite <= 0;
            mem_branch_target <= 0; mem_zero_flag <= 0;
            mem_alu_result <= 0; mem_write_data <= 0;
            mem_write_reg <= 0;
        end else begin
            mem_RegWrite      <= ex_RegWrite; 
            mem_MemtoReg      <= ex_MemtoReg; 
            mem_Branch        <= ex_Branch;
            mem_MemRead       <= ex_MemRead; 
            mem_MemWrite      <= ex_MemWrite;
            mem_branch_target <= ex_branch_target;
            mem_zero_flag     <= ex_zero_flag;
            mem_alu_result    <= ex_alu_result;
            mem_write_data    <= ex_read_data2; 
            mem_write_reg     <= ex_write_reg;
        end
    end

endmodule
