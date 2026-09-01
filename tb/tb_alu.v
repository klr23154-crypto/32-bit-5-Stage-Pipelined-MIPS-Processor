`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.05.2026 21:50:57
// Design Name: 
// Module Name: tb_alu
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


module tb_alu();

    // Inputs to the ALU are declared as 'reg' because we will drive them
    reg [31:0] A;
    reg [31:0] B;
    reg [3:0] ALU_Sel;

    // Outputs from the ALU are declared as 'wire'
    wire [31:0] ALU_Out;
    wire Zero;

    // Instantiate the ALU module and connect our testbench wires to its ports
    alu uut (
        .A(A), 
        .B(B), 
        .ALU_Sel(ALU_Sel), 
        .ALU_Out(ALU_Out), 
        .Zero(Zero)
    );

    // The initial block runs once at the very beginning of the simulation
    initial begin
        // Print a header to the console
        $display("Time | A  | B  | Sel | Out | Zero");
        
        // Test 1: Addition (10 + 15 = 25)
        A = 32'd10; B = 32'd15; ALU_Sel = 4'b0010; 
        #10; // Wait 10 nanoseconds
        $display("%0t | %0d | %0d | %b | %0d  | %b", $time, A, B, ALU_Sel, ALU_Out, Zero);
        
        // Test 2: Subtraction (20 - 20 = 0) -> Zero flag should go HIGH!
        A = 32'd20; B = 32'd20; ALU_Sel = 4'b0110; 
        #10;
        $display("%0t | %0d | %0d | %b | %0d  | %b", $time, A, B, ALU_Sel, ALU_Out, Zero);

        // Test 3: Bitwise AND (Binary 1100 & 1010 = 1000, which is 8)
        A = 32'd12; B = 32'd10; ALU_Sel = 4'b0000; 
        #10;
        $display("%0t | %0d | %0d | %b | %0d  | %b", $time, A, B, ALU_Sel, ALU_Out, Zero);
        
        // End the simulation
        $finish;
    end

endmodule
