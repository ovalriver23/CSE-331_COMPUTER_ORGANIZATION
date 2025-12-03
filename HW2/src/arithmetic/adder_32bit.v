module adder_32bit( 
    input wire [31:0] a, 
    input wire [31:0] b,
    input wire cin, 
    output wire [31:0] sum, 
    output wire carry_out 
);

    wire [32:0] c;

    assign c[0] = cin;
    assign carry_out = c[32];

    genvar i;
    generate
        for(i=0;i<32; i=i+1) begin : adder_loop
            full_adder_1bit fa_inst(
                .a(a[i]),
                .b(b[i]),
                .cin(c[i]),
                .sum(sum[i]),
                .cout(c[i+1])
            );
        end
    endgenerate

endmodule

