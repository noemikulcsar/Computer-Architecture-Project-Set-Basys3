🚀 MIPS Project - Single Cycle Implementations on Basys3

🏗️ Project Overview

This project contains 7 different MIPS Single Cycle implementations, each tested and executed on a Basys3 Master FPGA board. The key difference between these implementations lies in the Instruction Fetch (IFetch) component, which holds different machine code instructions for each MIPS instance. Each implementation solves a unique computational problem, using assembly programs that have been converted into machine code.

The goal is to understand MIPS processor execution flow and validate different algorithmic approaches directly on hardware. 🖥️⚙️

🌟 Components

Instruction Fetch (IFetch) 🔍

Role: Loads the instruction from memory at the beginning of each cycle.

Purpose: Each MIPS instance has a unique IFetch unit containing distinct machine code instructions.

Instruction Decode (ID) 📜

Role: Decodes the instruction and prepares it for execution.

Purpose: Determines the instruction type and operands.

Execution (EX) ⚡

Role: Executes arithmetic/logical operations.

Purpose: Performs ALU computations, shifting, and branching.

Memory (MEM) 🧠

Role: Manages data memory operations.

Purpose: Handles load and store operations.

Write-Back (WB) 💾

Role: Writes results back to registers.

Purpose: Ensures values are stored for future operations.

Control Unit (CU) 🕹️

Role: Determines control signals for each instruction.

Purpose: Orchestrates the correct execution of instructions.

Seven Segment Display (SSD) 🔢

Role: Displays results or debugging information.

Purpose: Provides real-time status updates.

🔧 Implemented Functionalities

Each of the 7 MIPS implementations solves a distinct computational problem using machine code instructions loaded in IFetch:

1️⃣ Counting Positive and Odd Numbers

Task: Count the number of positive and odd values in a memory array of size N.

Memory Usage:

N read from address 4.

Array starts at address 8.

Result stored at address 0.

2️⃣ Sum of Lower 16 Bits

Task: Extract and sum the lower 16 bits of 8 elements in memory.

Memory Usage:

A (starting address) read from 0.

Sum stored at address 4.

3️⃣ Reverse Subtraction in an Array

Task: Replace each element xi with xi - xN-i+1 in an array of size N.

Memory Usage:

N read from 0.

Array starts at 4.

4️⃣ Fibonacci Sequence Multiplied by 8

Task: Compute the first N Fibonacci numbers, multiply by 8, and store them in memory.

Memory Usage:

A (starting address) from 0, N from 4.

Output stored consecutively starting from A.

5️⃣ Circular Summation

Task: Replace each xi with xi + xi+1 (last element sums with first).

Memory Usage:

N read from 0.

Array starts at 4.

6️⃣ Counting Values Less Than X

Task: Traverse memory from address A until a 0 is found, counting values < X.

Memory Usage:

A from 0, X from 4.

Result stored at address 8.

7️⃣ Multiplication via Bitwise Shifting

Task: Compute X × Y using repeated additions based on the binary form of Y.

Memory Usage:

X from 0, Y from 4.

Result stored at address 8.

🔍 Single Cycle Implementation

Each of these MIPS implementations follows a single cycle execution model, where every instruction completes in one clock cycle. This results in a simpler, though less optimized, architecture. The execution is structured into the five main stages: IFetch, ID, EX, MEM, WB.

🖼️ Single Cycle Architecture Diagram



🚀 Getting Started

Clone this repository:

git clone https://github.com/yourusername/mips-single-cycle-basys3.git

Open the Vivado project and configure it for Basys3.

Load the appropriate machine code in the IFetch module.

Synthesize and generate the bitstream.

Upload to Basys3 and verify using the Seven Segment Display.

📜 Conclusion

This project showcases multiple single-cycle MIPS implementations solving different algorithmic problems, with execution on a Basys3 FPGA. Each MIPS variant has a unique Instruction Fetch unit containing preloaded machine code for its specific problem, demonstrating different computational methods on hardware.
