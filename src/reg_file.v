`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.05.2026 22:25:20
// Design Name: 
// Module Name: reg_file
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

module reg_file(
    input clk,                      // The system clock
    input RegWrite,                 // Control signal: 1 = Write enable, 0 = Write disable
    
    input [4:0] read_reg1,          // 5-bit address for Register A (0 to 31)
    input [4:0] read_reg2,          // 5-bit address for Register B (0 to 31)
    input [4:0] write_reg,          // 5-bit address for the Destination Register
    input [31:0] write_data,        // 32-bit data to save into the destination
    
    output [31:0] read_data1,       // 32-bit output data from Register A
    output [31:0] read_data2        // 32-bit output data from Register B
);

    // This creates an array of 32 registers, each 32 bits wide. 
    // This is the actual memory of the module!
    reg [31:0] registers [31:0];

    // Initial block to set all registers to 0 when the FPGA first boots up
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
    end

    // ==========================================
    // READ LOGIC (Combinational - happens instantly)
    // ==========================================
    // If we ask to read Register 0, always output 0. 
    // Otherwise, output whatever is stored in the requested register.
    assign read_data1 = (read_reg1 == 5'b0) ? 32'b0 : registers[read_reg1];
    assign read_data2 = (read_reg2 == 5'b0) ? 32'b0 : registers[read_reg2];


    // ==========================================
    // WRITE LOGIC (Sequential - happens on clock edge)
    // ==========================================
    always @(posedge clk) begin
        // We only write if the Control Unit says 'RegWrite' is 1
        // AND we make sure we never overwrite Register 0!
        if (RegWrite == 1'b1 && write_reg != 5'b0) begin
            registers[write_reg] <= write_data;
        end
    end

endmodule