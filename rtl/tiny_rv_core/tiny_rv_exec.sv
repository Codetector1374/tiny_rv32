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

    output wire [31:0] new_pc,
    output wire ld_new_pc
);

assign exec_rr_flush = ld_new_pc;

wire br_active;
wire [31:0] br_result;

tiny_rv_br branch_unit(
    .i_clk,

    .pc(rr_pc),
    .next_pc(rr_pc + 4),
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


endmodule
