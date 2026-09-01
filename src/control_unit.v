`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.05.2026 21:44:28
// Design Name: 
// Module Name: control_unit
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

module control_unit(
    input [5:0] opcode,          
    input [5:0] funct,           // <-- NEW INPUT: The bottom 6 bits!
    
    output reg RegWrite, MemRead, MemWrite, ALUSrc, MemtoReg, Branch,
    output reg [3:0] ALU_Sel
);

    always @(*) begin
        // Default safe values
        RegWrite = 0; MemRead = 0; MemWrite = 0; ALUSrc = 0; 
        MemtoReg = 0; Branch = 0; ALU_Sel = 4'b0000;

        case(opcode)
            // ----------------------------------------------------
            // R-TYPE INSTRUCTIONS (ADD, SUB, AND, OR)
            // ----------------------------------------------------
            6'b000000: begin
                RegWrite = 1;        
                ALUSrc   = 0;        
                MemtoReg = 0;        
                
                // Nested case to look at the funct code!
                case(funct)
                    6'b100000: ALU_Sel = 4'b0010; // ADD
                    6'b100010: ALU_Sel = 4'b0110; // SUBTRACT
                    6'b100100: ALU_Sel = 4'b0000; // AND
                    6'b100101: ALU_Sel = 4'b0001; // OR
                    default:   ALU_Sel = 4'b0000; 
                endcase
            end

            // (The rest of your instructions stay exactly the same)
            6'b001000: begin // ADDI
                RegWrite = 1; ALUSrc = 1; MemtoReg = 0; ALU_Sel = 4'b0010; 
            end
            6'b100011: begin // LW
                RegWrite = 1; MemRead = 1; ALUSrc = 1; MemtoReg = 1; ALU_Sel = 4'b0010; 
            end
            6'b101011: begin // SW
                MemWrite = 1; ALUSrc = 1; ALU_Sel = 4'b0010; 
            end
            6'b000100: begin // BEQ
                Branch = 1; ALUSrc = 0; ALU_Sel = 4'b0110; 
            end
        endcase
    end
endmodule
