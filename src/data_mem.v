`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.05.2026 21:26:41
// Design Name: 
// Module Name: data_mem
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


module data_mem(
    input clk,
    input MemRead,               // Control signal: 1 = Allow reading
    input MemWrite,              // Control signal: 1 = Allow writing
    input [31:0] address,        // Where to save/read (comes from the ALU)
    input [31:0] write_data,     // The number to save (comes from Register File)
    output reg [31:0] read_data  // The number retrieved (goes back to Register File)
);

    // Create an array of 256 memory slots, each 32 bits wide.
    // This gives your processor a massive... 1 Kilobyte of RAM!
    reg [31:0] memory_array [0:255];

    // Initialize all RAM to 0 when the FPGA turns on
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            memory_array[i] = 32'b0;
        end
    end

    // ==========================================
    // READ LOGIC (Combinational - happens instantly)
    // ==========================================
    always @(*) begin
        if (MemRead == 1'b1) begin
            // Divide address by 4 by slicing the bits
            read_data = memory_array[address[31:2]];
        end else begin
            // Output 0 if we aren't trying to read memory
            read_data = 32'b0; 
        end
    end

    // ==========================================
    // WRITE LOGIC (Sequential - happens on clock edge)
    // ==========================================
    always @(posedge clk) begin
        if (MemWrite == 1'b1) begin
            // Divide address by 4 and save the data
            memory_array[address[31:2]] <= write_data;
        end
    end

endmodule
