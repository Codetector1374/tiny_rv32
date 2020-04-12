module tiny_rv_exec_alu(
    input wire i_clk,
    
    input wire [31:0] pc,
    input wire [6:0] opcode,
    input wire [2:0] funct3,

    input wire [31:0] rs1,
    input wire [31:0] rs2,
    input wire [31:0] imm,
    
    output wire [31:0] result,
    output wire active,
);

always @* begin
    case(opcode)
        `RV_LUI: begin
            active = 1;
            result = {imm[19:0], 12'b0};
        end
        `RV_AUIPC: begin
            active = 1;
            result = {imm[19:0], 12'b0} + pc;
        end
        default: begin
            result = 32'b0; active = 0;
        end
    endcase
end

endmodule
