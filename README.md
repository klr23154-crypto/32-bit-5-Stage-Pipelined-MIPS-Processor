# 32-bit Pipelined MIPS Processor

A bare-metal, 5-stage pipelined 32-bit processor based on the MIPS architecture, written entirely in Verilog. This project was engineered from the ground up, transitioning from a single-cycle design to a fully pipelined architecture to optimize Instruction Per Cycle (IPC) throughput. 

The design has been cycle-accurately simulated in Xilinx Vivado and physically synthesized, deployed, and verified on a **Digilent Nexys A7 FPGA**.

## 🚀 Key Engineering Features
* **5-Stage RISC Pipeline:** Instruction execution is divided across Fetch, Decode, Execute, Memory, and Writeback stages, allowing up to 5 instructions to be processed simultaneously.
* **Dynamic Data Hazard Resolution:** Implements a dedicated **Forwarding Unit** with complex multiplexing to bypass the register file and resolve Read-After-Write (RAW) dependencies without stalling the CPU.
* **Load-Use Stall Injection:** Features a custom **Hazard Detection Unit** that monitors memory reads (`LW`), physically freezes the Program Counter and IF/ID pipeline registers, and injects a 1-cycle `NOP` (bubble) to ensure data integrity.
* **FPGA Hardware Verification:** Uses a custom clock divider to step the 100MHz board clock down to 1Hz, mapping the final pipeline Writeback stage directly to physical LEDs for real-time silicon debugging.

## ⚙️ Supported Instruction Set (ISA)
This processor supports a custom subset of the MIPS32 instruction set, focusing on core arithmetic, logic, and memory operations:
* **R-Type (Register-to-Register):** `ADD`, `SUB`, `AND`, `OR`, `SLT` (Set on Less Than)
* **I-Type (Immediate/Memory):** `ADDI` (Add Immediate), `LW` (Load Word), `SW` (Store Word)

## 🧠 Pipeline Architecture Breakdown
The datapath is separated by four physical hardware registers (`IF/ID`, `ID/EX`, `EX/MEM`, `MEM/WB`), creating the 5 distinct stages:

1. **Instruction Fetch (IF):** The Program Counter (PC) queries the Instruction Memory (ROM) to fetch the 32-bit machine code.
2. **Instruction Decode (ID):** The Control Unit decodes the opcode/funct. The Register File reads the requested `rs` and `rt` addresses, while the Immediate Generator sign-extends 16-bit values to 32-bit.
3. **Execute (EX):** The Arithmetic Logic Unit (ALU) performs mathematical operations or calculates the physical RAM address for memory operations.
4. **Memory (MEM):** The Data Memory (RAM) block is accessed. `SW` writes data to the calculated address, or `LW` reads data out.
5. **Writeback (WB):** The final multiplexer routes either the ALU math result or the RAM data back to the Register File to be saved.

### Deep Dive: Hazard Management
To ensure the pipeline does not calculate incorrect math due to temporal delays, two major subsystems were engineered:
* **The Forwarding Unit:** Sits in the EX stage. It compares the destination registers (`WriteReg`) of the instructions currently in the MEM and WB stages against the source registers (`rs`, `rt`) of the instruction entering the EX stage. If a match is found, 3-to-1 multiplexers intercept the older data and route it backward in time directly into the ALU.
* **The Hazard Detection Unit:** Sits in the ID stage. It specifically looks for a `LW` instruction in the EX stage whose destination register matches the source registers of the instruction in the ID stage. If detected, it drops the `Control_Mux` to `0` (forcing all control signals to `NOP`), and drops the `PCWrite` and `IF/ID_Enable` pins to `0`, freezing the first two stages in place for one clock cycle.

## 📁 Repository Structure
To maintain a clean repository, heavy Vivado synthesis caches (`.sim`, `.runs`, `.cache`) are ignored. Only the raw Hardware Description Language (HDL) and memory files are tracked.

```text
├── src/                      # Core hardware modules
│   ├── mips_pipeline_top.v   # The Top-Level Pipeline Engine
│   ├── fpga_wrapper.v        # Physical pin/clock mapping for the Nexys A7
│   ├── alu.v                 # Arithmetic Logic Unit
│   ├── reg_file.v            # 32-bit Register Bank
│   ├── forwarding_unit.v     # Time-travel data routing
│   ├── hazard_detection.v    # Stall & Bubble injection logic
│   ├── inst_mem.v            # Instruction Memory (ROM)
│   ├── data_mem.v            # Data Memory (RAM)
│   └── *_reg.v               # Inter-stage pipeline walls (IF/ID, ID/EX, etc.)
├── tb/                       # Simulation Testbenches
│   └── tb_mips_pipeline.v    # Primary testbench for behavioral simulation
└── program_mem.mem           # Hexadecimal machine code for hardware testing
🛠️ Tools & Hardware Used
Hardware Description Language: Verilog (IEEE 1364)

EDA Tool: Xilinx Vivado (Simulation, Synthesis, Implementation)

Target FPGA: Digilent Nexys A7 (Artix-7 xc7a100t)

💻 How to Run & Synthesize
Clone this repository to your local machine.

Open Xilinx Vivado and create a new RTL project targeting the Nexys A7 board.

Add all .v files from the src/ directory as Design Sources.

Add tb_mips_pipeline.v from the tb/ directory as a Simulation Source.

Add program_mem.mem as a memory file.

For Behavioral Simulation: Set tb_mips_pipeline.v as the Top Module. Add the ForwardA, ForwardB, and Control_Mux wires to the waveform viewer to observe the hazard logic in real-time.

For FPGA Deployment: Set fpga_wrapper.v as the Top Module. Ensure your XDC constraints file maps the clk to the 100MHz pin, and the alu_result vector to the 16 physical LEDs. Generate the bitstream and program the device.
