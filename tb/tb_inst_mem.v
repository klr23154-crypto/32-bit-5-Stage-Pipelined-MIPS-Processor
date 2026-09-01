`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.05.2026 21:20:14
// Design Name: 
// Module Name: tb_inst_mem
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

module tb_inst_mem();

    // Input
    reg [31:0] read_addr;

    // Output
    wire [31:0] instruction;

    // Instantiate the module
    inst_mem uut (
        .read_addr(read_addr),
        .instruction(instruction)
    );

    initial begin
        $display("Time | PC Address | Instruction Fetched (Hex)");
        $display("-------------------------------------------");
        
        // Test 1: Address 0 (Should grab the 1st line of your file)
        read_addr = 32'd0;
        #10;
        $display("%0t | %0d          | %h", $time, read_addr, instruction);
        
        // Test 2: Address 4 (Should grab the 2nd line of your file)
        read_addr = 32'd4;
        #10;
        $display("%0t | %0d          | %h", $time, read_addr, instruction);

        // Test 3: Address 8 (Should grab the 3rd line of your file)
        read_addr = 32'd8;
        #10;
        $display("%0t | %0d          | %h", $time, read_addr, instruction);
        
        $finish;
    end

endmodule
