module mips_single_cycle_datapath(
    input wire clk,
    input wire reset,
    input wire [31:0] instruction,
    output wire [31:0] alu_result,
    output wire [31:0] write_data
);

    // ==========================================
    // 1. INSTRUCTION DECODING (Splitting the wires)
    // ==========================================
    wire [5:0] opcode = instruction[31:26];
    wire [4:0] rs     = instruction[25:21];
    wire [4:0] rt     = instruction[20:16];
    wire [4:0] rd     = instruction[15:11];
    wire [5:0] funct  = instruction[5:0];
    wire [15:0] imm   = instruction[15:0];

    // ==========================================
    // 2. MAIN CONTROL UNIT
    // ==========================================
    wire reg_dst, alu_src, reg_write;
    wire [1:0] alu_op;

    control_unit ctrl_inst (
        .opcode(opcode),
        .reg_dst(reg_dst),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .alu_op(alu_op)
    );

    // ==========================================
    // 3. REGISTER FILE LOGIC
    // ==========================================
    
    // A. Write Register MUX (5-bit)
    // Selects destination register: rt (0) or rd (1) based on RegDst
    wire [4:0] write_reg_addr;
    mux2to1_5bit mux_regdst (
        .input0(rt),
        .input1(rd),
        .select(reg_dst),
        .out(write_reg_addr)
    );

    // B. Register File Instantiation
    wire [31:0] read_data1; // Output A (rs value)
    wire [31:0] read_data2; // Output B (rt value)
    
    // Note: The data to be written comes from the ALU result.
    // We connect 'alu_result' wire to the 'write_data' input of the regfile.
    // We also assign it to the top-level output 'write_data' for visibility.
    assign write_data = alu_result; 

    register_file reg_file_inst (
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write),
        .read_reg1(rs),
        .read_reg2(rt),
        .write_reg(write_reg_addr),
        .write_data(alu_result), // Feedback from ALU
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // ==========================================
    // 4. ALU INPUT LOGIC
    // ==========================================

    // A. Sign Extender
    wire [31:0] sign_ext_imm;
    sign_extender sign_ext_inst (
        .immediate_in(imm),
        .immediate_out(sign_ext_imm)
    );

    // B. ALU Source MUX (32-bit)
    // Selects ALU Operand B: Register Data (0) or Immediate (1) based on ALUSrc
    wire [31:0] alu_operand_b;
    mux2to1_32bit mux_alusrc (
        .input0(read_data2),
        .input1(sign_ext_imm),
        .select(alu_src),
        .out(alu_operand_b)
    );

    // ==========================================
    // 5. ALU CONTROL (WITH THE HACK)
    // ==========================================

    // We need to send either 'funct' OR 'opcode' to the ALU Control.
    // Selector Logic: If alu_op is 11 (Bitwise I-Type), select Opcode.
    wire hack_sel;
    and a_hack (hack_sel, alu_op[1], alu_op[0]); 

    wire [5:0] alu_ctrl_input; // The MUXed input for the ALU control
    
    // Instantiate 6 1-bit MUXes to choose between Funct and Opcode
    genvar i;
    generate
        for (i=0; i<6; i=i+1) begin : hack_mux_loop
            mux2to1_1bit m_hack (
                .s(hack_sel),
                .I0(funct[i]),    // Select 0: Standard Funct Code
                .I1(opcode[i]),   // Select 1: Opcode (The Hack)
                .out(alu_ctrl_input[i])
            );
        end
    endgenerate

    // Instantiate ALU Control
    wire [3:0] alu_control_sig;
    alu_control alu_ctrl_inst (
        .alu_op(alu_op),
        .funct(alu_ctrl_input), // Connected to our hack MUX output
        .alu_control(alu_control_sig)
    );

    // ==========================================
    // 6. ALU EXECUTION
    // ==========================================
    wire zero_flag; // Unused in this project (no branches), but part of ALU
    
    alu alu_inst (
        .a(read_data1),
        .b(alu_operand_b),
        .alu_control(alu_control_sig),
        .result(alu_result), // Goes to Output and back to RegFile
        .zero(zero_flag)
    );

endmodule