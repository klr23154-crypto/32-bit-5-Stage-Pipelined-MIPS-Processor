`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.05.2026 22:42:52
// Design Name: 
// Module Name: fpga_wrapper
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


module fpga_wrapper(
    input clk_100MHz,          // Physical Pin: E3 (100MHz clock)
    input reset_btn,           // Physical Pin: CPU Reset Button
    output [15:0] led          // Physical Pins: The 16 LEDs
);

    wire slow_clk;
    wire [31:0] alu_out;

    // 1. Slow down the clock
    clock_divider my_clock (
        .clk_in(clk_100MHz),
        .clk_out(slow_clk)
    );

    // 2. Instantiate the NEW PIPELINED processor!
    mips_pipeline_top my_cpu (
        .clk(slow_clk),
        .reset(~reset_btn),    // Invert the button signal
        .alu_result(alu_out)
    );

    // 3. Connect the bottom 16 bits of the ALU to the 16 physical LEDs
    assign led = alu_out[15:0];

endmodule
