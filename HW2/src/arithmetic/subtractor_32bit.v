module subtractor_32bit( 
    input wire [31:0] a, 
    input wire [31:0] b, 
    output wire [31:0] difference, 
    output wire borrow_out 
);


    wire [31:0] b_inverted;
    wire carry_out_wire;

    // loop to invert the each bit of the b
    genvar i;
    generate
        for (i = 0; i < 32 ; i = i + 1) begin : sub_loop
            not n1(b_inverted[i], b[i]);

        end
    endgenerate

    adder_32bit add_inst(
        .a(a),
        .b(b_inverted),
        .cin(1'b1),              // This adds the '1' for Two's Complement!
        .sum(difference),
        .carry_out(carry_out_wire)
    );

    not n_borrow(borrow_out, carry_out_wire);

endmodule