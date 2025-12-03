module control_unit(
    input wire [5:0] opcode,
    output wire reg_dst,
    output wire alu_src,
    output wire reg_write,
    output wire [1:0] alu_op
);

    // 1. Invert Opcode Bits
    wire n0, n1, n2, n3, n4, n5;
    not inv0 (n0, opcode[0]);
    not inv1 (n1, opcode[1]);
    not inv2 (n2, opcode[2]);
    not inv3 (n3, opcode[3]);
    not inv4 (n4, opcode[4]);
    not inv5 (n5, opcode[5]);

    // 2. Detect Instruction Types (The Decoders)
    // We create a wire that goes HIGH only when that specific opcode is detected
    wire is_r_type, is_addi, is_slti, is_andi, is_ori, is_xori;

    // R-Type: 000000
    and d_rtype (is_r_type, n5, n4, n3, n2, n1, n0);

    // ADDI: 001000
    and d_addi  (is_addi, n5, n4, opcode[3], n2, n1, n0);

    // SLTI: 001010
    and d_slti  (is_slti, n5, n4, opcode[3], n2, opcode[1], n0);

    // ANDI: 001100
    and d_andi  (is_andi, n5, n4, opcode[3], opcode[2], n1, n0);

    // ORI: 001101
    and d_ori   (is_ori, n5, n4, opcode[3], opcode[2], n1, opcode[0]);

    // XORI: 001110
    and d_xori  (is_xori, n5, n4, opcode[3], opcode[2], opcode[1], n0);


    // 3. Drive Control Signals (The Outputs)
    // We combine the detector wires using OR gates based on the Truth Table

    // RegDst: 1 only for R-type (dest is rd)
    buf b_regdst (reg_dst, is_r_type);

    // ALUSrc: 1 for any I-type (operand is immediate)
    // If your compiler supports multi-input OR, do this:
    or o_alusrc (alu_src, is_addi, is_slti, is_andi, is_ori, is_xori);
    // If it only supports 2-input OR, chain them: (is_addi | is_slti) | (is_andi | ...)

    // RegWrite: 1 for ALL supported instructions
    // (Technically R-Type + all I-Types listed)
    or o_regwrite (reg_write, is_r_type, is_addi, is_slti, is_andi, is_ori, is_xori);

    // ALUOp Generation
    // ALUOp[1] is 1 for: R-Type (10) OR Bitwise Imm (11 -> ANDI, ORI, XORI)
    wire op1_bitwise;
    or o_op1_sub (op1_bitwise, is_andi, is_ori, is_xori);
    or o_op1_final (alu_op[1], is_r_type, op1_bitwise);

    // ALUOp[0] is 1 for: SLTI (01) OR Bitwise Imm (11 -> ANDI, ORI, XORI)
    // Note: ADDI is 00, R-Type is 10.
    wire op0_bitwise;
    or o_op0_sub (op0_bitwise, is_andi, is_ori, is_xori);
    or o_op0_final (alu_op[0], is_slti, op0_bitwise);

endmodule