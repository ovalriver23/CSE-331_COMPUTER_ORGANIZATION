module full_adder_1bit (
    input wire a, 
    input wire b, 
    input wire cin, 
    output wire sum, 
    output wire cout
);

wire axorb; // Result of a XOR b
wire and1;  // Result of a AND b
wire and2;  // Result of cin AND (a XOR b)

xor x1(axorb, a, b);
xor x2(sum, axorb, cin);

and a1(and1, a, b);
and a2(and2, axorb, cin);

or o1(cout, and1, and2);

endmodule   
