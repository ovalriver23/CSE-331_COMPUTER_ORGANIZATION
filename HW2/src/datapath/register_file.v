module register_file( 
    input wire clk, 
    input wire reset, 
    input wire reg_write, // Write enable 
    input wire [4:0] read_reg1,     // rs 
    input wire [4:0] read_reg2,     // rt 
    input wire [4:0] write_reg,     // rd (R-type) or rt (I-type) 
    input wire [31:0] write_data, 
    output wire [31:0] read_data1, 
    output wire [31:0] read_data2 
);

reg [31:0] registers [31:0];

integer i;

always @(posedge clk) begin
    if(reset) begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] <= 32'b0;
        end
    end
    else begin
            // Write Logic
            // Write only if RegWrite is enabled AND we are NOT writing to Register $0
            if (reg_write && (write_reg != 5'b00000)) begin
                registers[write_reg] <= write_data;
            end
        end
end


assign read_data1 = (read_reg1 == 5'b0) ? 32'b0 : registers[read_reg1];
assign read_data2 = (read_reg2 == 5'b0) ? 32'b0 : registers[read_reg2];

endmodule