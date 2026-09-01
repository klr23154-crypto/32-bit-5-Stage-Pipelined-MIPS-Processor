`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.05.2026 23:09:03
// Design Name: 
// Module Name: imm_gen
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

module imm_gen(
    input  [31:0] instruction,  // The full 32-bit machine code
    output reg [31:0] imm_ext   // The extracted, 32-bit stretched number
);

    // In MIPS, the opcode is the top 6 bits [31:26]
    wire [5:0] opcode = instruction[31:26];

    always @(*) begin
        // For MIPS, the Immediate is ALWAYS the bottom 16 bits [15:0].
        // We look at bit 15 (the sign bit). We make 16 copies of it to pad the front,
        // and then attach the original 16 bits to the back.
        
        imm_ext = { {16{instruction[15]}}, instruction[15:0] };
    end

endmodule
