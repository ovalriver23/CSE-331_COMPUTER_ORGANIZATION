# MIPS Single-Cycle Datapath

A complete **structural Verilog implementation** of a MIPS single-cycle processor datapath built entirely from primitive logic gates (AND, OR, NOT, XOR) and basic components.

## 🏗️ Project Architecture

```
Project_Root/
├── 📁 src/                          # Source Code
│   ├── 📁 top/                      # Top-Level Integration
│   │   └── mips_single_cycle_datapath.v
│   │
│   ├── 📁 control/                  # Control Logic
│   │   ├── control_unit.v           # Main Decoder (Opcode → Control Signals)
│   │   └── alu_control.v            # ALU Decoder (Funct/ALUOp → ALU Control)
│   │
│   ├── 📁 datapath/                 # Major Data Components
│   │   ├── register_file.v          # 32x32 Register File
│   │   ├── sign_extender.v          # 16-bit to 32-bit Sign Extension
│   │   ├── alu.v                    # Arithmetic Logic Unit
│   │   ├── mux2to1_5bit.v           # 5-bit MUX (RegDst)
│   │   └── mux2to1_32bit.v          # 32-bit MUX (ALUSrc)
│   │
│   ├── 📁 arithmetic/               # ALU Sub-modules
│   │   ├── adder_32bit.v            # 32-bit Ripple Carry Adder
│   │   ├── subtractor_32bit.v       # 32-bit Subtractor (2's Complement)
│   │   ├── and_32bit.v              # 32-bit Bitwise AND
│   │   ├── or_32bit.v               # 32-bit Bitwise OR
│   │   ├── xor_32bit.v              # 32-bit Bitwise XOR
│   │   └── comparator_32bit.v       # 32-bit Comparator (SLT)
│   │
│   └── 📁 primitives/               # Low-Level Building Blocks
│       ├── full_adder_1bit.v        # 1-bit Full Adder
│       ├── mux2to1_1bit.v           # 1-bit 2-to-1 Multiplexer
│       └── comparator_1bit.v        # 1-bit Comparator
│
└── 📁 test/                         # Simulation Files
    └── testbench.v                  # Comprehensive Testbench
```

## 🎯 Supported Instructions

### R-Type Instructions
- **ADD** (`100000`) - Add: `rd = rs + rt`
- **SUB** (`100010`) - Subtract: `rd = rs - rt`
- **AND** (`100100`) - Bitwise AND: `rd = rs & rt`
- **OR** (`100101`) - Bitwise OR: `rd = rs | rt`
- **XOR** (`100110`) - Bitwise XOR: `rd = rs ^ rt`
- **SLT** (`101010`) - Set Less Than: `rd = (rs < rt) ? 1 : 0`

### I-Type Instructions
- **ADDI** (`001000`) - Add Immediate: `rt = rs + imm`
- **SLTI** (`001010`) - Set Less Than Immediate: `rt = (rs < imm) ? 1 : 0`
- **ANDI** (`001100`) - AND Immediate: `rt = rs & imm`
- **ORI** (`001101`) - OR Immediate: `rt = rs | imm`
- **XORI** (`001110`) - XOR Immediate: `rt = rs ^ imm`

## 🔧 Design Features

### ✅ Purely Structural Design
- Built from **primitive gates only** (AND, OR, NOT, XOR)
- No behavioral `assign` statements or `always` blocks (except in register file)
- 32-bit adder constructed from **32 cascaded 1-bit full adders**
- All multiplexers built from basic logic gates

### ✅ Complete Control Path
- **Control Unit**: Decodes 6-bit opcode → generates RegDst, ALUSrc, RegWrite, ALUOp
- **ALU Control**: Decodes funct/opcode → generates 4-bit ALU control signal
- Supports both R-type and I-type instruction formats

### ✅ Single-Cycle Operation
- All instructions complete in **one clock cycle**
- Simple design for educational purposes
- Clear datapath visualization

### ✅ Modular & Hierarchical
- Clean separation between control and datapath
- Easy to understand, extend, and debug
- Well-commented code

## 🚀 Running the Simulation

### Prerequisites
- **Icarus Verilog** (`iverilog`) - Open-source Verilog simulator
- **GTKWave** (optional) - Waveform viewer

### Compile and Run

```bash
# Navigate to project directory
cd /path/to/HW2

# Compile all source files and testbench
iverilog -o mips_sim \
  src/primitives/*.v \
  src/arithmetic/*.v \
  src/datapath/*.v \
  src/control/*.v \
  src/top/*.v \
  test/testbench.v

# Run simulation
vvp mips_sim
```

### Alternative (Using includes in testbench)

```bash
cd test
iverilog -o test testbench.v
vvp test
```

### Expected Output

```
ADDI: R1 should be 10, Result = 10
ADDI: R2 should be 20, Result = 20
ADD: R3 should be 30, Result = 30
SUB: R4 should be 10, Result = 10
AND: R5 = 0
ORI: R6 = 5
```

## 📊 Control Signal Truth Table

| Instruction | Opcode   | RegDst | ALUSrc | RegWrite | ALUOp |
|-------------|----------|--------|--------|----------|-------|
| R-Type      | `000000` | 1      | 0      | 1        | `10`  |
| ADDI        | `001000` | 0      | 1      | 1        | `00`  |
| SLTI        | `001010` | 0      | 1      | 1        | `01`  |
| ANDI        | `001100` | 0      | 1      | 1        | `11`  |
| ORI         | `001101` | 0      | 1      | 1        | `11`  |
| XORI        | `001110` | 0      | 1      | 1        | `11`  |

## 🔍 ALU Control Mapping

| ALU Control | Operation | Instructions              |
|-------------|-----------|---------------------------|
| `0000`      | AND       | AND, ANDI                 |
| `0001`      | OR        | OR, ORI                   |
| `0010`      | ADD       | ADD, ADDI                 |
| `0011`      | XOR       | XOR, XORI                 |
| `0110`      | SUB       | SUB                       |
| `0111`      | SLT       | SLT, SLTI                 |

## 📝 Key Components

### Control Unit
- **Pure gate-level logic** using AND/OR/NOT gates
- Decodes 6-bit opcode to generate control signals
- Supports 6 instruction types (1 R-type + 5 I-types)

### ALU Control
- **Two-level decoder**
  - Level 1: ALUOp (from Control Unit)
  - Level 2: Funct field (for R-type) or Opcode (for I-type)
- Generates 4-bit ALU control signal

### Register File
- 32 registers × 32 bits
- 2 read ports (asynchronous)
- 1 write port (synchronous on clock edge)
- Register $0 hardwired to 0

### ALU
- Supports 6 operations: AND, OR, ADD, XOR, SUB, SLT
- Built from individual arithmetic/logic modules
- All modules constructed from primitive gates

## 🎓 Educational Value

This project demonstrates:
- **Digital logic fundamentals** - Building complex circuits from basic gates
- **Computer architecture** - MIPS instruction set and datapath design
- **Hierarchical design** - Breaking complex systems into manageable modules
- **Structural Verilog** - Hardware description at the gate level
- **Verification** - Comprehensive testbench design

## 📚 References

- Patterson & Hennessy - "Computer Organization and Design"
- MIPS Instruction Set Architecture
- Verilog HDL Structural Modeling

## 👥 Author

Created for **Computer Organization** coursework - Fall 2025

---

**Note**: This is a simplified educational processor. Real-world processors include memory hierarchy, pipelining, branch prediction, and many other optimizations.
