`include "./rv_opcodes.sv"
module tiny_rv_exec(
    input wire i_clk,
    input wire i_reset,

    output wire exec_rr_stall, exec_rr_flush,

    input wire [31:0] rr_pc,
    input wire [31:0] rr_inst,
    input wire [6:0] rr_opcode,
    input wire [4:0] rr_rd,
    input wire [31:0] rr_rs1,
    input wire [31:0] rr_rs2,
    input wire [2:0] rr_funct3,
    input wire [6:0] rr_funct7,
    input wire [31:0] rr_imm32,

    output reg [31:0] exec_pc,
    output reg [31:0] exec_inst,
    output reg [4:0] exec_rd,
    output reg [31:0] exec_rd_val,

    output reg [31:0] of1_val,
    output wire [4:0] of1_reg,

    output wire [31:0] new_pc,
    output wire ld_new_pc
);

    wire [11:0] rr_csr = rr_inst[31:20];

    assign exec_rr_flush = ld_new_pc;

    wire br_active;
    wire [31:0] br_result;

    tiny_rv_br branch_unit(
        .i_clk,

        .pc(rr_pc),
        .next_pc(rr_pc+4),
        .computed_broffset(rr_imm32),
        .opcode(rr_opcode),
        .funct3(rr_funct3),

        .rs1(rr_rs1),
        .rs2(rr_rs2),

        .br_taken(ld_new_pc),
        .br_addr(new_pc),

        .active(br_active),
        .result(br_result)
    );

    wire [31:0] alu_result;
    wire alu_active;

    tiny_rv_alu alu(
        .i_clk,

        .pc(rr_pc),
        .opcode(rr_opcode),
        .funct3(rr_funct3),
        .funct7(rr_funct7),

        .rs1(rr_rs1),
        .rs2(rr_rs2),
        .imm(rr_imm32),

        .result(alu_result),
        .active(alu_active)
    );

    wire csr_active;
    wire [31:0] csr_result;

    tiny_rv_csr csr(
        .i_clk,
        .pc(rr_pc),
        .inst(rr_inst),
        .opcode(rr_opcode),
        .funct3(rr_funct3),
        .rs1(rr_rs1),
        .rs2(rr_rs2),
        .csr(rr_csr),
        .active(csr_active),
        .result(csr_result)
    );
    wire any_active = br_active | alu_active | csr_active;

    always @(posedge i_clk) begin
        if (i_reset) begin
            exec_rd <= 0;
            exec_rd_val <= 0;
        end
        else begin
            exec_pc <= rr_pc;
            exec_inst <= rr_inst;
            exec_rd <= of1_reg;
            exec_rd_val <= of1_val;
        end
    end

    assign of1_reg = any_active ? rr_rd:5'b0;

    always @* begin
        if (br_active)
            of1_val = br_result;
        else if (alu_active)
            of1_val = alu_result;
        else if (csr_active)
            of1_val = csr_result;
        else
            of1_val = 32'b0;
    end

endmodule: tiny_rv_exec
