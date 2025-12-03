module and_32bit (
    input wire [31:0] a,
    input wire [31:0] b,
    output wire [31:0] result
);

    genvar i;
    generate
        for (i = 0; i < 32 ; i = i + 1) begin : and_loop
            and a1(result[i], a[i], b[i]);
        end
    endgenerate
endmodule