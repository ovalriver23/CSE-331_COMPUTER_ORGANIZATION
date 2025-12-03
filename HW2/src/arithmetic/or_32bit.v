module or_32bit (
    input wire [31:0] a,
    input wire [31:0] b,
    output wire [31:0] result
);

    genvar j;
    generate
        for (j = 0; j < 32 ; j = j + 1) begin : or_loop
            or o1(result[j], a[j], b[j]);
        end
    endgenerate
endmodule