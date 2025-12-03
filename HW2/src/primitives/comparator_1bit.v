module comparator_1bit (
    input wire a,       // Current bit from A
    input wire b,       // Current bit from B
    input wire lt_in,   // "Less Than" signal from the previous bit
    input wire eq_in,   // "Equal" signal from the previous bit
    output wire lt_out, // Updated "Less Than" for the next bit
    output wire eq_out  // Updated "Equal" for the next bit
);

    wire xor_ab;
    wire xnor_ab;       // Means "Current bits are equal"
    wire not_a;
    wire a_lt_b;        // Means "a is 0 and b is 1"
    wire new_less;      // Logic for becoming less at this stage

    // 1. EQUAL Logic: Output is Equal only if History is Equal AND Current is Equal
    xor x1 (xor_ab, a, b);          // Check difference
    not n1 (xnor_ab, xor_ab);       // Invert to check equality (XNOR)
    and a1 (eq_out, eq_in, xnor_ab);// Combine with history

    // 2. LESS THAN Logic
    not n2 (not_a, a);
    and a2 (a_lt_b, not_a, b);      // Check if a=0 and b=1 (strictly less here)

    // We are "less" at this stage if:
    // a) The previous bits already said we are less (lt_in is 1)
    // b) The previous bits were equal (eq_in is 1), AND we are less right now (a_lt_b)
    
    and a3 (new_less, eq_in, a_lt_b);
    or  o1 (lt_out, lt_in, new_less);

endmodule