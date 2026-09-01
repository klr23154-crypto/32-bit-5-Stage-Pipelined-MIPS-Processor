`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.05.2026 23:23:26
// Design Name: 
// Module Name: mips_pipeline_top
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

module mips_pipeline_top(
    input clk,
    input reset,
    output [31:0] alu_result // Output for the physical FPGA LEDs
);

    // ==========================================
    // 1. FETCH STAGE (IF)
    // ==========================================
    wire [31:0] if_pc, if_pc_plus_4, if_instruction, next_pc;
    wire PCWrite; // Controlled by the Hazard Detection Unit!
    
    // If PCWrite is 1, use next_pc. If 0, loop if_pc back into itself to freeze!
    pc my_pc (.clk(clk), .reset(reset), .next_pc(PCWrite ? next_pc : if_pc), .current_pc(if_pc));
    
    assign if_pc_plus_4 = if_pc + 32'd4;
    inst_mem my_inst_mem (.read_addr(if_pc), .instruction(if_instruction));

    // ==========================================
    // IF/ID PIPELINE REGISTER
    // ==========================================
    wire [31:0] id_pc_plus_4, id_instruction;
    
    if_id_reg pipe1_if_id (
        .clk(clk), .reset(reset),
        .en(PCWrite),
        .if_pc_plus_4(if_pc_plus_4), .if_instruction(if_instruction),
        .id_pc_plus_4(id_pc_plus_4), .id_instruction(id_instruction)
    );

    // ==========================================
    // 2. DECODE STAGE (ID)
    // ==========================================
    wire id_RegWrite, id_MemRead, id_MemWrite, id_ALUSrc, id_MemtoReg, id_Branch;
    wire [3:0] id_ALU_Sel;
    wire [5:0] opcode = id_instruction[31:26];
    wire [5:0] funct  = id_instruction[5:0];
    
    control_unit my_control (
        .opcode(opcode), .funct(funct),
        .RegWrite(id_RegWrite), .MemRead(id_MemRead), .MemWrite(id_MemWrite),
        .ALUSrc(id_ALUSrc), .MemtoReg(id_MemtoReg), .Branch(id_Branch),
        .ALU_Sel(id_ALU_Sel)
    );

    wire [31:0] id_read_data1, id_read_data2, id_imm_ext;
    wire [4:0]  id_write_reg;
    
    // Wires coming backwards from the final WB stage
    wire wb_RegWrite;
    wire [4:0] wb_write_reg;
    wire [31:0] wb_final_data;

    reg_file my_reg_file (
        .clk(clk), .RegWrite(wb_RegWrite),
        .read_reg1(id_instruction[25:21]), .read_reg2(id_instruction[20:16]),
        .write_reg(wb_write_reg),          .write_data(wb_final_data), 
        .read_data1(id_read_data1),        .read_data2(id_read_data2)
    );

    imm_gen my_imm_gen (.instruction(id_instruction), .imm_ext(id_imm_ext));

    // Destination Register Mux 
    assign id_write_reg = (opcode == 6'b000000) ? id_instruction[15:11] : id_instruction[20:16];

    // ==========================================
    // HAZARD DETECTION & CONTROL MUX (THE BRAKES)
    // ==========================================
    wire Control_Mux;
    wire ex_MemRead;
    wire [4:0] ex_write_reg;
    
    hazard_detection my_hazard (
        .ex_MemRead(ex_MemRead),         
        .ex_write_reg(ex_write_reg),     
        .id_rs(id_instruction[25:21]),
        .id_rt(id_instruction[20:16]),
        .PCWrite(PCWrite),               
        .Control_Mux(Control_Mux)
    );

    // The Bubble Injector: If Control_Mux is 0, all signals become 0 (NOP).
    wire safe_RegWrite = id_RegWrite & Control_Mux;
    wire safe_MemtoReg = id_MemtoReg & Control_Mux;
    wire safe_Branch   = id_Branch   & Control_Mux;
    wire safe_MemRead  = id_MemRead  & Control_Mux;
    wire safe_MemWrite = id_MemWrite & Control_Mux;
    wire safe_ALUSrc   = id_ALUSrc   & Control_Mux;
    wire [3:0] safe_ALU_Sel = (Control_Mux) ? id_ALU_Sel : 4'b0000;

    // ==========================================
    // ID/EX PIPELINE REGISTER
    // ==========================================
    wire ex_RegWrite, ex_MemtoReg, ex_Branch, ex_MemWrite, ex_ALUSrc;
    wire [3:0] ex_ALU_Sel;
    wire [31:0] ex_pc_plus_4, ex_read_data1, ex_read_data2, ex_imm_ext;
    wire [4:0] ex_rs, ex_rt;

    id_ex_reg pipe2_id_ex (
        .clk(clk), .reset(reset),
        // Control In (USING THE SAFE WIRES!)
        .id_RegWrite(safe_RegWrite), .id_MemtoReg(safe_MemtoReg), .id_Branch(safe_Branch),
        .id_MemRead(safe_MemRead), .id_MemWrite(safe_MemWrite), .id_ALUSrc(safe_ALUSrc),
        .id_ALU_Sel(safe_ALU_Sel),
        // Data In
        .id_pc_plus_4(id_pc_plus_4), .id_read_data1(id_read_data1), 
        .id_read_data2(id_read_data2), .id_imm_ext(id_imm_ext), .id_write_reg(id_write_reg),
        .id_rs(id_instruction[25:21]), .id_rt(id_instruction[20:16]),
        
        // Control Out
        .ex_RegWrite(ex_RegWrite), .ex_MemtoReg(ex_MemtoReg), .ex_Branch(ex_Branch),
        .ex_MemRead(ex_MemRead), .ex_MemWrite(ex_MemWrite), .ex_ALUSrc(ex_ALUSrc),
        .ex_ALU_Sel(ex_ALU_Sel),
        // Data Out
        .ex_pc_plus_4(ex_pc_plus_4), .ex_read_data1(ex_read_data1),
        .ex_read_data2(ex_read_data2), .ex_imm_ext(ex_imm_ext), .ex_write_reg(ex_write_reg),
        .ex_rs(ex_rs), .ex_rt(ex_rt)
    );

    // ==========================================
    // 3. EXECUTE STAGE (EX) & FORWARDING LOGIC
    // ==========================================
    wire [1:0] ForwardA, ForwardB;
    wire [31:0] alu_in1, forwarded_B, alu_in2;
    wire [31:0] ex_alu_result, ex_branch_target;
    wire ex_zero_flag;
    
    // Wires coming backwards from the MEM stage
    wire mem_RegWrite;
    wire [4:0] mem_write_reg;
    wire [31:0] mem_alu_result;
    
    forwarding_unit my_forwarding (
        .ex_rs(ex_rs), .ex_rt(ex_rt),
        .mem_RegWrite(mem_RegWrite), .mem_write_reg(mem_write_reg),
        .wb_RegWrite(wb_RegWrite),   .wb_write_reg(wb_write_reg),
        .ForwardA(ForwardA),         .ForwardB(ForwardB)
    );

    assign alu_in1 = (ForwardA == 2'b10) ? mem_alu_result :   
                     (ForwardA == 2'b01) ? wb_final_data  :   
                     ex_read_data1;                           

    assign forwarded_B = (ForwardB == 2'b10) ? mem_alu_result : 
                         (ForwardB == 2'b01) ? wb_final_data  : 
                         ex_read_data2;

    assign alu_in2 = (ex_ALUSrc == 1'b1) ? ex_imm_ext : forwarded_B;
    assign ex_branch_target = ex_pc_plus_4 + (ex_imm_ext << 2);

    alu my_alu (
        .A(alu_in1), .B(alu_in2), 
        .ALU_Sel(ex_ALU_Sel), .ALU_Out(ex_alu_result), .Zero(ex_zero_flag)
    );

    // ==========================================
    // EX/MEM PIPELINE REGISTER
    // ==========================================
    wire mem_MemtoReg, mem_Branch, mem_MemRead, mem_MemWrite, mem_zero_flag;
    wire [31:0] mem_branch_target, mem_write_data;

    ex_mem_reg pipe3_ex_mem (
        .clk(clk), .reset(reset),
        .ex_RegWrite(ex_RegWrite), .ex_MemtoReg(ex_MemtoReg), .ex_Branch(ex_Branch),
        .ex_MemRead(ex_MemRead), .ex_MemWrite(ex_MemWrite),
        .ex_branch_target(ex_branch_target), .ex_zero_flag(ex_zero_flag),
        .ex_alu_result(ex_alu_result), .ex_read_data2(forwarded_B), 
        .ex_write_reg(ex_write_reg),
        
        .mem_RegWrite(mem_RegWrite), .mem_MemtoReg(mem_MemtoReg), .mem_Branch(mem_Branch),
        .mem_MemRead(mem_MemRead), .mem_MemWrite(mem_MemWrite),
        .mem_branch_target(mem_branch_target), .mem_zero_flag(mem_zero_flag),
        .mem_alu_result(mem_alu_result), .mem_write_data(mem_write_data), .mem_write_reg(mem_write_reg)
    );

    // ==========================================
    // 4. MEMORY STAGE (MEM)
    // ==========================================
    wire [31:0] mem_read_data;
    wire PCSrc;

    data_mem my_data_mem (
        .clk(clk), .MemRead(mem_MemRead), .MemWrite(mem_MemWrite),
        .address(mem_alu_result), .write_data(mem_write_data), .read_data(mem_read_data)
    );

    assign PCSrc = mem_Branch & mem_zero_flag;
    assign next_pc = (PCSrc == 1'b1) ? mem_branch_target : if_pc_plus_4;

    // ==========================================
    // MEM/WB PIPELINE REGISTER
    // ==========================================
    wire wb_MemtoReg;
    wire [31:0] wb_read_data, wb_alu_result;

    mem_wb_reg pipe4_mem_wb (
        .clk(clk), .reset(reset),
        .mem_RegWrite(mem_RegWrite), .mem_MemtoReg(mem_MemtoReg),
        .mem_read_data(mem_read_data), .mem_alu_result(mem_alu_result), .mem_write_reg(mem_write_reg),
        
        .wb_RegWrite(wb_RegWrite), .wb_MemtoReg(wb_MemtoReg),
        .wb_read_data(wb_read_data), .wb_alu_result(wb_alu_result), .wb_write_reg(wb_write_reg)
    );

    // ==========================================
    // 5. WRITEBACK STAGE (WB)
    // ==========================================
    assign wb_final_data = (wb_MemtoReg == 1'b1) ? wb_read_data : wb_alu_result;
    
    assign alu_result = wb_final_data;

endmodule
