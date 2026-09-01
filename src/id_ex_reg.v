`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.05.2026 23:11:24
// Design Name: 
// Module Name: id_ex_reg
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

module id_ex_reg(
    input clk,
    input reset,
    
    // 1. Control Signals 
    input id_RegWrite, id_MemtoReg, id_Branch, 
    input id_MemRead, id_MemWrite, id_ALUSrc,
    input [3:0] id_ALU_Sel,
    
    // 2. Data from Decode Stage
    input [31:0] id_pc_plus_4,
    input [31:0] id_read_data1,  
    input [31:0] id_read_data2,   
    input [31:0] id_imm_ext,      
    input [4:0]  id_write_reg,    
    
    // 3. Forwarding Unit Data <-- NEW
    input [4:0]  id_rs,           // Source Register A address
    input [4:0]  id_rt,           // Source Register B address

    // ------------------------------------------------------------
    // OUTPUTS to the Execute Stage
    // ------------------------------------------------------------
    output reg ex_RegWrite, ex_MemtoReg, ex_Branch, 
    output reg ex_MemRead, ex_MemWrite, ex_ALUSrc,
    output reg [3:0] ex_ALU_Sel,
    
    output reg [31:0] ex_pc_plus_4,
    output reg [31:0] ex_read_data1,
    output reg [31:0] ex_read_data2,
    output reg [31:0] ex_imm_ext,
    output reg [4:0]  ex_write_reg,
    
    // Forwarding Unit Outputs <-- NEW
    output reg [4:0]  ex_rs,
    output reg [4:0]  ex_rt
);

    always @(posedge clk) begin
        if (reset) begin
            ex_RegWrite <= 0; ex_MemtoReg <= 0; ex_Branch <= 0;
            ex_MemRead <= 0; ex_MemWrite <= 0; ex_ALUSrc <= 0;
            ex_ALU_Sel <= 0; ex_write_reg <= 0;
            ex_pc_plus_4 <= 0; ex_read_data1 <= 0; 
            ex_read_data2 <= 0; ex_imm_ext <= 0;
            
            ex_rs <= 0;  // <-- NEW
            ex_rt <= 0;  // <-- NEW
        end else begin
            ex_RegWrite   <= id_RegWrite; 
            ex_MemtoReg   <= id_MemtoReg; 
            ex_Branch     <= id_Branch;
            ex_MemRead    <= id_MemRead; 
            ex_MemWrite   <= id_MemWrite; 
            ex_ALUSrc     <= id_ALUSrc;
            ex_ALU_Sel    <= id_ALU_Sel; 
            ex_write_reg  <= id_write_reg;
            ex_pc_plus_4  <= id_pc_plus_4; 
            ex_read_data1 <= id_read_data1;
            ex_read_data2 <= id_read_data2; 
            ex_imm_ext    <= id_imm_ext;
            
            ex_rs         <= id_rs;  // <-- NEW
            ex_rt         <= id_rt;  // <-- NEW
        end
    end

endmodule