module comparator_32bit ( 
    input wire [31:0] a,
    input wire [31:0] b, 
    output wire [31:0] result
);

    wire [31:0] sub_result;
    wire borrow;

    subtractor_32bit sub_inst (
        .a(a),
        .b(b),
        .difference(sub_result),
        .borrow_out(borrow)
    );

    buf b0(result[0], sub_result[31]);

    wire logic_zero;
    wire not_sign;

    not n1(not_sign, sub_result[31]);

    and a1(logic_zero, sub_result[31], not_sign);

    genvar i;
    generate
        for (i = 1; i < 32 ;i = i + 1) begin : buf_loop
            buf b_zero(result[i], logic_zero);
        end
    endgenerate
endmodule