`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.05.2026 21:47:07
// Design Name: 
// Module Name: alu
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


module alu(
    input [31:0] A,          // 32-bit Input A (from Register 1)
    input [31:0] B,          // 32-bit Input B (from Register 2 or Immediate)
    input [3:0] ALU_Sel,     // 4-bit Control Signal (tells ALU what to do)
    output reg [31:0] ALU_Out, // 32-bit Output Result
    output Zero              // 1-bit Zero Flag (True if ALU_Out is 0)
);

    // The Case statement acts like a giant Multiplexer
    always @(*) begin
        case(ALU_Sel)
            4'b0000: ALU_Out = A & B;      // Bitwise AND
            4'b0001: ALU_Out = A | B;      // Bitwise OR
            4'b0010: ALU_Out = A + B;      // Addition
            4'b0110: ALU_Out = A - B;      // Subtraction
            default: ALU_Out = 32'b0;      // Default case (output 0)
        endcase
    end

    // The Zero flag is set to 1 if the entire 32-bit output is exactly 0.
    // This is crucial for Branch instructions (like BEQ - Branch if Equal).
    assign Zero = (ALU_Out == 32'b0) ? 1'b1 : 1'b0;

endmodule
