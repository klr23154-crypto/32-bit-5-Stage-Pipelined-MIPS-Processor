`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.05.2026 22:32:26
// Design Name: 
// Module Name: tb_reg_file
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


module tb_reg_file();

    // Inputs to drive
    reg clk;
    reg RegWrite;
    reg [4:0] read_reg1;
    reg [4:0] read_reg2;
    reg [4:0] write_reg;
    reg [31:0] write_data;

    // Outputs to observe
    wire [31:0] read_data1;
    wire [31:0] read_data2;

    // Instantiate the Register File
    reg_file uut (
        .clk(clk),
        .RegWrite(RegWrite),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // ==========================================
    // CLOCK GENERATION
    // ==========================================
    // This creates a clock that toggles every 5 nanoseconds 
    // (giving a 10ns total clock period).
    always #5 clk = ~clk;

    // ==========================================
    // TEST SEQUENCE
    // ==========================================
    initial begin
        // 1. Initialize all inputs to 0
        clk = 0;
        RegWrite = 0;
        read_reg1 = 0;
        read_reg2 = 0;
        write_reg = 0;
        write_data = 0;
        
        $display("Time | RegWrite | W_Addr | W_Data | R_Addr1 | R_Data1 | R_Addr2 | R_Data2");

        // Wait a bit before starting
        #10; 

        // --------------------------------------------------------
        // TEST 1: Write a number (150) into Register 5
        // --------------------------------------------------------
        RegWrite = 1;              // Turn ON write permission
        write_reg = 5'd5;          // Target Register 5
        write_data = 32'd150;      // The number to save
        #10; // Wait for one clock cycle to pass so it actually saves
        
        // --------------------------------------------------------
        // TEST 2: Read it back out on Port 1
        // --------------------------------------------------------
        RegWrite = 0;              // Turn OFF write permission
        read_reg1 = 5'd5;          // Ask to read Register 5
        #10; 
        $display("%0t |    %b     |   %0d    |  %0d   |    %0d    |   %0d   |    %0d    |   %0d", 
                 $time, RegWrite, write_reg, write_data, read_reg1, read_data1, read_reg2, read_data2);

        // --------------------------------------------------------
        // TEST 3: Try to overwrite Register 0 (The Hardwired Zero)
        // --------------------------------------------------------
        RegWrite = 1;              // Turn ON write permission
        write_reg = 5'd0;          // Target Register 0
        write_data = 32'd999;      // Try to save 999 into it
        #10;
        
        // --------------------------------------------------------
        // TEST 4: Read Register 0 to prove it blocked the write
        // --------------------------------------------------------
        RegWrite = 0;
        read_reg2 = 5'd0;          // Ask to read Register 0 on Port 2
        #10;
        $display("%0t |    %b     |   %0d    |  %0d   |    %0d    |   %0d   |    %0d    |   %0d", 
                 $time, RegWrite, write_reg, write_data, read_reg1, read_data1, read_reg2, read_data2);

        // End simulation
        $finish;
    end

endmodule
