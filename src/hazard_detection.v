`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.05.2026 23:40:26
// Design Name: 
// Module Name: hazard_detection
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

module hazard_detection(
    // Looking ahead at the Execute Stage
    input ex_MemRead,             // Is the instruction in front of us a Load Word?
    input [4:0] ex_write_reg,     // What register is that Load Word saving to?
    
    // Looking at the current instruction in the Decode Stage
    input [4:0] id_rs,            // Register A we want to use
    input [4:0] id_rt,            // Register B we want to use
    
    // Outputs (The Brakes)
    output reg PCWrite,           // 1 = Run, 0 = Freeze PC
    output reg Control_Mux        // 1 = Run, 0 = Inject Bubble (0s)
);

    always @(*) begin
        // Default: No hazard, run normally
        PCWrite = 1'b1;
        Control_Mux = 1'b1;

        // LOAD-USE HAZARD CONDITION:
        // If the instruction in Execute is reading RAM, AND it is writing to 
        // a register that our CURRENT instruction needs to do math with...
        if (ex_MemRead == 1'b1 && (ex_write_reg != 0) &&
           (ex_write_reg == id_rs || ex_write_reg == id_rt)) begin
            
            // STALL! Hit the brakes!
            PCWrite = 1'b0;       // Freeze the PC (don't fetch next instruction)
            Control_Mux = 1'b0;   // Turn all control signals to 0 (Injects a NOP)
            
        end
    end

endmodule
