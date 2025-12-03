module mux2to1_5bit (
    input wire [4:0] input0,   // 5-bit input (e.g., rt for I-type)
    input wire [4:0] input1,   // 5-bit input (e.g., rd for R-type)
    input wire select,         // Select signal (RegDst)
    output wire [4:0] out      // 5-bit output
);

    // Instantiate 5 1-bit multiplexers, one for each bit position
    
    // Bit 0
    mux2to1_1bit m0 (
        .s(select), 
        .I0(input0[0]), 
        .I1(input1[0]), 
        .out(out[0])
    );

    // Bit 1
    mux2to1_1bit m1 (
        .s(select), 
        .I0(input0[1]), 
        .I1(input1[1]), 
        .out(out[1])
    );

    // Bit 2
    mux2to1_1bit m2 (
        .s(select), 
        .I0(input0[2]), 
        .I1(input1[2]), 
        .out(out[2])
    );

    // Bit 3
    mux2to1_1bit m3 (
        .s(select), 
        .I0(input0[3]), 
        .I1(input1[3]), 
        .out(out[3])
    );

    // Bit 4
    mux2to1_1bit m4 (
        .s(select), 
        .I0(input0[4]), 
        .I1(input1[4]), 
        .out(out[4])
    );

endmodule