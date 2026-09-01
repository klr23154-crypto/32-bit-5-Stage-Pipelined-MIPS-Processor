`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.05.2026 21:36:33
// Design Name: 
// Module Name: tb_data_mem
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

module tb_data_mem();

    // Inputs
    reg clk;
    reg MemRead;
    reg MemWrite;
    reg [31:0] address;
    reg [31:0] write_data;

    // Outputs
    wire [31:0] read_data;

    // Instantiate the Data Memory module
    data_mem uut (
        .clk(clk),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    // ==========================================
    // CLOCK GENERATION (10ns period)
    // ==========================================
    always #5 clk = ~clk;

    // ==========================================
    // TEST SEQUENCE
    // ==========================================
    initial begin
        // 1. Initialize all inputs to 0
        clk = 0;
        MemRead = 0;
        MemWrite = 0;
        address = 0;
        write_data = 0;
        
        $display("Time | MemWrite | MemRead | Address | W_Data (Hex) | R_Data (Hex)");
        $display("------------------------------------------------------------------");
        #10; // Wait a bit before starting

        // --------------------------------------------------------
        // TEST 1: Write a recognizable hex word to Address 12
        // --------------------------------------------------------
        MemWrite = 1;              // Turn ON write permission
        MemRead = 0;               
        address = 32'd12;          // Address 12 (Should save in array index 3)
        write_data = 32'hDEADBEEF; // A classic test word!
        #10; // Wait 1 clock cycle to let it save
        $display("%0t |    %b     |    %b    |   %0d    |  %h    |  %h", $time, MemWrite, MemRead, address, write_data, read_data);

        // --------------------------------------------------------
        // TEST 2: Read that exact word back out
        // --------------------------------------------------------
        MemWrite = 0;              // Turn OFF write permission
        MemRead = 1;               // Turn ON read permission
        address = 32'd12;          // Read Address 12
        #10; 
        $display("%0t |    %b     |    %b    |   %0d    |  %h    |  %h", $time, MemWrite, MemRead, address, write_data, read_data);

        // --------------------------------------------------------
        // TEST 3: Try to read an empty address (Address 16)
        // --------------------------------------------------------
        MemWrite = 0;              
        MemRead = 1;               
        address = 32'd16;          // Read an address we haven't touched
        #10;
        $display("%0t |    %b     |    %b    |   %0d    |  %h    |  %h", $time, MemWrite, MemRead, address, write_data, read_data);

        // End simulation
        $finish;
    end

endmodule
