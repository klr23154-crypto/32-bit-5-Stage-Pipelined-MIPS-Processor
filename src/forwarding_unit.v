`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.05.2026 23:28:11
// Design Name: 
// Module Name: forwarding_unit
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

module forwarding_unit(
    // The registers currently being used in the ALU (Execute Stage)
    input [4:0] ex_rs,
    input [4:0] ex_rt,
    
    // The destination register from the Memory Stage (Instruction 1 ahead)
    input mem_RegWrite,
    input [4:0] mem_write_reg,
    
    // The destination register from the Writeback Stage (Instruction 2 ahead)
    input wb_RegWrite,
    input [4:0] wb_write_reg,
    
    // The Mux Controls for the ALU inputs
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);

    always @(*) begin
        // Default: 00 = No hazards, use normal Register File data
        ForwardA = 2'b00;
        ForwardB = 2'b00;
        
        // ---------------------------------------------------------
        // EX HAZARD (Instruction exactly 1 step ahead)
        // ---------------------------------------------------------
        // Does the MEM stage want to write to the rs register we are using right now?
        if (mem_RegWrite && (mem_write_reg != 0) && (mem_write_reg == ex_rs)) begin
            ForwardA = 2'b10; // Forward from EX/MEM register
        end
        // Does the MEM stage want to write to the rt register we are using right now?
        if (mem_RegWrite && (mem_write_reg != 0) && (mem_write_reg == ex_rt)) begin
            ForwardB = 2'b10; // Forward from EX/MEM register
        end

        // ---------------------------------------------------------
        // MEM HAZARD (Instruction exactly 2 steps ahead)
        // ---------------------------------------------------------
        // Does the WB stage want to write to our rs register? 
        // (And make sure we aren't ALREADY forwarding from the EX stage, which is more recent!)
        if (wb_RegWrite && (wb_write_reg != 0) && (wb_write_reg == ex_rs) &&
            !(mem_RegWrite && (mem_write_reg != 0) && (mem_write_reg == ex_rs))) begin
            ForwardA = 2'b01; // Forward from MEM/WB register
        end
        
        if (wb_RegWrite && (wb_write_reg != 0) && (wb_write_reg == ex_rt) &&
            !(mem_RegWrite && (mem_write_reg != 0) && (mem_write_reg == ex_rt))) begin
            ForwardB = 2'b01; // Forward from MEM/WB register
        end
    end

endmodule
