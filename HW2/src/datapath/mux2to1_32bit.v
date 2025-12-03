module mux2to1_32bit( 
    input wire [31:0] input0,   // Register data 
    input wire [31:0] input1,   // Immediate data 
    input wire select,          // ALUSrc 
    output wire [31:0] out 
);

genvar i;

    generate
        for(i = 0; i < 32; i=i+1) begin : mux_loop
            mux2to1_1bit m_inst(
                .s(select), 
                .I0(input0[i]), 
                .I1(input1[i]), 
                .out(out[i])
            );
        end
    endgenerate

endmodule
