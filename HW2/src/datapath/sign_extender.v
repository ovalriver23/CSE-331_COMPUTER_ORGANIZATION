module sign_extender (
    input wire [15:0] immediate_in,
    output wire [31:0] immediate_out
);

    wire msbit;
    
    buf b1(msbit, immediate_in[15]);
    
    genvar j;
    generate
        for (j = 0 ; j < 16 ; j = j + 1) begin : lower
            buf b2(immediate_out[j], immediate_in[j]);
        end
    endgenerate
    
    
    genvar i;
    generate
        for (i = 16 ; i < 32 ; i = i + 1) begin : upper
            buf b2(immediate_out[i], msbit);
        end
    endgenerate
endmodule