module mux2to1_1bit (
    input wire s,
    input wire I0,
    input wire I1,
    output wire out
);


wire not_s;
wire sANDI1;
wire nSANDI0;


not (not_s, s);
and a1(sANDI1, s, I1);
and a2(nSANDI0, not_s, I0);

or o1(out, sANDI1, nSANDI0);

endmodule