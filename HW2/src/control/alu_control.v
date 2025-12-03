module alu_control( 
    input wire [1:0] alu_op,      // 00:ADDI, 01:SLTI, 10:R-Type, 11:Bitwise(I-Type)
    input wire [5:0] funct,       // R-Type: Funct Code | I-Type: OPCODE (The Hack!)
    output wire [3:0] alu_control // The final command to the ALU
);

    // ==========================================
    // 1. INVERT INPUTS (Prepare for Decoding)
    // ==========================================
    
    // Invert ALU Op
    wire n_op1, n_op0;
    not inv_op1 (n_op1, alu_op[1]);
    not inv_op0 (n_op0, alu_op[0]);

    // Invert Funct (This wire holds Funct OR Opcode)
    wire nf5, nf4, nf3, nf2, nf1, nf0;
    not inv_f5 (nf5, funct[5]);
    not inv_f4 (nf4, funct[4]);
    not inv_f3 (nf3, funct[3]);
    not inv_f2 (nf2, funct[2]);
    not inv_f1 (nf1, funct[1]);
    not inv_f0 (nf0, funct[0]);


    // ==========================================
    // 2. DETECT MODE (Instruction Categories)
    // ==========================================
    
    // Mode 00: ADDI (No funct needed)
    wire is_addi_mode;
    and d_00 (is_addi_mode, n_op1, n_op0);

    // Mode 01: SLTI (No funct needed)
    wire is_slti_mode;
    and d_01 (is_slti_mode, n_op1, alu_op[0]);

    // Mode 10: R-Type (Look at actual Funct Code)
    wire is_rtype_mode;
    and d_10 (is_rtype_mode, alu_op[1], n_op0);

    // Mode 11: Bitwise I-Type (Look at Opcode inside funct input)
    wire is_bitwise_mode;
    and d_11 (is_bitwise_mode, alu_op[1], alu_op[0]);


    // ==========================================
    // 3. DECODE SPECIFIC INSTRUCTIONS
    // ==========================================

    // --- R-TYPE DECODING (Only valid if is_rtype_mode is 1) ---
    // Codes: ADD(100000), SUB(100010), AND(100100), OR(100101), XOR(100110), SLT(101010)

    wire r_add, r_sub, r_and, r_or, r_xor, r_slt;

    and dec_r_add (r_add, is_rtype_mode, funct[5], nf4, nf3, nf2, nf1, nf0); // 100000
    and dec_r_sub (r_sub, is_rtype_mode, funct[5], nf4, nf3, nf2, funct[1], nf0); // 100010
    and dec_r_and (r_and, is_rtype_mode, funct[5], nf4, nf3, funct[2], nf1, nf0); // 100100
    and dec_r_or  (r_or,  is_rtype_mode, funct[5], nf4, nf3, funct[2], nf1, funct[0]); // 100101
    and dec_r_xor (r_xor, is_rtype_mode, funct[5], nf4, nf3, funct[2], funct[1], nf0); // 100110
    and dec_r_slt (r_slt, is_rtype_mode, funct[5], nf4, funct[3], nf2, funct[1], nf0); // 101010


    // --- I-TYPE BITWISE DECODING (Only valid if is_bitwise_mode is 1) ---
    // Here, 'funct' actually contains the OPCODE.
    // Opcodes: ANDI(001100), ORI(001101), XORI(001110)

    wire i_andi, i_ori, i_xori;

    // ANDI: 001100
    and dec_i_andi (i_andi, is_bitwise_mode, nf5, nf4, funct[3], funct[2], nf1, nf0);

    // ORI: 001101
    and dec_i_ori  (i_ori,  is_bitwise_mode, nf5, nf4, funct[3], funct[2], nf1, funct[0]);

    // XORI: 001110
    and dec_i_xori (i_xori, is_bitwise_mode, nf5, nf4, funct[3], funct[2], funct[1], nf0);


    // ==========================================
    // 4. GENERATE OUTPUT (The OR Gates)
    // ==========================================
    // We map the detected instructions to the ALU Control Codes:
    // AND(0000), OR(0001), ADD(0010), XOR(0011), SUB(0110), SLT(0111)

    // Bit 3: Always 0
    buf b_out3 (alu_control[3], 1'b0);

    // Bit 2: High for SUB and SLT
    // Triggered by: r_sub, r_slt, is_slti_mode
    or o_out2 (alu_control[2], r_sub, r_slt, is_slti_mode);

    // Bit 1: High for ADD, XOR, SUB, SLT
    // Triggered by: r_add, is_addi_mode, r_xor, i_xori, r_sub, r_slt, is_slti_mode
    or o_out1 (alu_control[1], r_add, is_addi_mode, r_xor, i_xori, r_sub, r_slt, is_slti_mode);

    // Bit 0: High for OR, XOR, SLT
    // Triggered by: r_or, i_ori, r_xor, i_xori, r_slt, is_slti_mode
    or o_out0 (alu_control[0], r_or, i_ori, r_xor, i_xori, r_slt, is_slti_mode);

endmodule