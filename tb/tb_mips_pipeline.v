`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.05.2026 23:49:11
// Design Name: 
// Module Name: tb_mips_pipeline
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


module tb_mips_pipeline();

    // Inputs
    reg clk;
    reg reset;

    // Outputs
    wire [31:0] alu_result;

    // Instantiate the Unit Under Test (UUT) - THE PIPELINE ENGINE
    mips_pipeline_top uut (
        .clk(clk), 
        .reset(reset), 
        .alu_result(alu_result)
    );

    // Generate a clock (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 1;

        // Hold reset for a few cycles to flush all pipeline registers to zero
        #20;
        reset = 0;

        // Let the pipeline run. 
        // 4 instructions + 5 stages + 1 stall bubble = ~10 cycles needed.
        // We will run for 200ns (20 cycles) just to be safe.
        #200; 
        
        $display("Simulation Finished. Check the waveforms!");
        $finish;
    end
endmodule