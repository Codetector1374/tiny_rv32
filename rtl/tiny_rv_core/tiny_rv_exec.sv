module tiny_rv_exec(
    input wire i_clk,
    input wire i_reset,

    input wire exec_rr_stall, exec_rr_flush,
    output wire pipe_flush, pipe_stall,

    input wire [31:0] rr_pc,
    input wire [31:0] rr_inst,
    input wire [6:0] rr_opcode,
    input wire [4:0] rr_rd,
    input wire [31:0] rr_rs1,
    input wire [31:0] rr_rs2,
    input wire [2:0] rr_funct3,
    input wire [6:0] rr_funct7,

    output reg [31:0] exec_pc,
    output reg [31:0] exec_inst,
    output reg [31:0] exec_rd,
    output reg [31:0] exec_rd_val
);




endmodule
