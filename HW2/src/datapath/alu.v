module alu (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0] alu_control, // We only really need [2:0]
    output wire [31:0] result,
    output wire zero
);

    // 1. Wires to hold results from all units
    wire [31:0] w_and, w_or, w_add, w_sub, w_slt, w_xor;
    wire [31:0] w_unused; // For empty MUX slots
    assign w_unused = 32'b0; // Hardwire unused slots to 0

    // 2. Instantiate all Arithmetic/Logic Units
    // Note: Connect inputs a, b to all of them.
    
    wire cout_add, bout_sub; // Unused carry/borrow outputs
    
    and_32bit  c_and (a, b, w_and);
    or_32bit   c_or  (a, b, w_or);
    adder_32bit c_add (a, b, 1'b0, w_add, cout_add); // cin=0 for normal addition
    subtractor_32bit c_sub (a, b, w_sub, bout_sub);
    xor_32bit  c_xor (a, b, w_xor);
    // Remember: Comparator inputs depend on how you wrote it (maybe subtractor inside?)
    // If you wrote comparator_32bit to take a and b:
    comparator_32bit c_slt (a, b, w_slt);

    // 3. Select the Result using a MUX Tree
    // We use alu_control[0], [1], [2] as selectors.
    
    // LAYER 1 (Select based on alu_control[0])
    wire [31:0] m0_out, m1_out, m2_out, m3_out;
    
    // MUX 0: Selects between 000 (AND) and 001 (OR)
    mux2to1_32bit mx0 (w_and, w_or, alu_control[0], m0_out);
    
    // MUX 1: Selects between 010 (ADD) and 011 (XOR)
    mux2to1_32bit mx1 (w_add, w_xor, alu_control[0], m1_out);
    
    // MUX 2: Selects between 100 (Unused) and 101 (Unused)
    mux2to1_32bit mx2 (w_unused, w_unused, alu_control[0], m2_out);
    
    // MUX 3: Selects between 110 (SUB) and 111 (SLT)
    mux2to1_32bit mx3 (w_sub, w_slt, alu_control[0], m3_out);
    
    
    // LAYER 2 (Select based on alu_control[1])
    wire [31:0] m4_out, m5_out;
    
    // MUX 4: Selects between Group 00x and 01x
    mux2to1_32bit mx4 (m0_out, m1_out, alu_control[1], m4_out);
    
    // MUX 5: Selects between Group 10x and 11x
    mux2to1_32bit mx5 (m2_out, m3_out, alu_control[1], m5_out);
    
    
    // LAYER 3 (Select based on alu_control[2]) -> FINAL RESULT
    mux2to1_32bit mx_final (m4_out, m5_out, alu_control[2], result);


    // 4. Zero Flag Logic (NOR of all bits)
    // Structure: OR all bits, then NOT the result.
    wire or_all_bits;
    
    // Since we can't write "assign or_all_bits = |result;", we must chain OR gates
    // OR create a helper module "nor_32bit".
    // For simplicity here, let's assume you can use a 32-input OR if your tool allows,
    // or chain them. Here is a generate loop approach for OR-ing:
    
    wire [31:0] or_chain;
    assign or_chain[0] = result[0];
    
    genvar i;
    generate
        for(i=1; i<32; i=i+1) begin : z_loop
            or o1 (or_chain[i], or_chain[i-1], result[i]);
        end
    endgenerate
    
    not n_zero (zero, or_chain[31]); // Invert the final OR result

endmodule