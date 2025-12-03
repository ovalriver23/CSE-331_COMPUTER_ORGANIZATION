`include "../src/primitives/full_adder_1bit.v"
`include "../src/primitives/mux2to1_1bit.v"
`include "../src/arithmetic/adder_32bit.v"
`include "../src/arithmetic/subtractor_32bit.v"
`include "../src/arithmetic/and_32bit.v"
`include "../src/arithmetic/or_32bit.v"
`include "../src/arithmetic/xor_32bit.v"
`include "../src/arithmetic/comparator_32bit.v"
`include "../src/control/control_unit.v"
`include "../src/control/alu_control.v"
`include "../src/datapath/sign_extender.v"
`include "../src/datapath/mux2to1_5bit.v"
`include "../src/datapath/mux2to1_32bit.v"
`include "../src/datapath/alu.v"
`include "../src/datapath/register_file.v"
`include "../src/top/mips_single_cycle_datapath.v"


module testbench; 
    reg clk; 
    reg reset; 
    reg [31:0] instruction; 
    wire [31:0] alu_result; 
    wire [31:0] write_data; 
    // Instantiate datapath 
    mips_single_cycle_datapath uut( 
        .clk(clk), 
        .reset(reset), 
        .instruction(instruction), 
        .alu_result(alu_result), 
        .write_data(write_data) 
    ); 
    // Clock generation 
    initial begin 
        clk = 0; 
        forever #5 clk = ~clk; 
    end 
    // Test sequence 
    initial begin 

// Reset 
reset = 1; 
instruction = 32'h00000000; 
#10 reset = 0; 

// Test 1: addi $1, $0, 10 (R1 = 10) 
// opcode=001000, rs=00000, rt=00001, imm=0000000000001010 
instruction = 32'b001000_00000_00001_0000000000001010; 
#10; 
$display("ADDI: R1 should be 10, Result = %d", write_data); 

// Test 2: addi $2, $0, 20 (R2 = 20) 
instruction = 32'b001000_00000_00010_0000000000010100; 
#10; 
$display("ADDI: R2 should be 20, Result = %d", write_data); 

// Test 3: add $3, $1, $2 (R3 = R1 + R2 = 30) 
// opcode=000000, rs=00001, rt=00010, rd=00011, shamt=00000, funct=100000 
instruction = 32'b000000_00001_00010_00011_00000_100000; 
#10; 
$display("ADD: R3 should be 30, Result = %d", write_data); 

// Test 4: sub $4, $2, $1 (R4 = R2 - R1 = 10) 
instruction = 32'b000000_00010_00001_00100_00000_100010; 
#10; 
$display("SUB: R4 should be 10, Result = %d", write_data); 

// Test 5: and $5, $1, $2 (R5 = R1 & R2) 
instruction = 32'b000000_00001_00010_00101_00000_100100; 
#10; 
$display("AND: R5 = %d", write_data); 

// Test 6: ori $6, $5, 5 (R6 = R5 | 5) 
instruction = 32'b001101_00101_00110_0000000000000101; 
#10; 
$display("ORI: R6 = %d", write_data);

$finish; 
    end
endmodule