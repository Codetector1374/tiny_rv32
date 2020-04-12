module tiny_rv(
    input wire i_clk,
    input wire i_reset
);


wire pipe_stall, pipe_flush;

wire [31:0] new_pc;
wire ld_new_pc;

wire [31:0] fetch_pc, fetch_inst;

tiny_rv_tb_fetch fetch(
    .i_clk,
    .i_reset,

    .i_pipe_stall(pipe_stall),
    .i_pipe_flush(pipe_flush),
    .i_ld_new_addr(ld_new_pc),
    .i_new_addr(new_pc),

    .o_fetched_pc(fetch_pc),
    .o_fetched_inst(fetch_inst)
);

wire [31:0] decode_pc;
wire [31:0] decode_inst;
wire [31:0] decode_imm32;
wire [6:0] decode_opcode;
wire [2:0] decode_funct3;
wire [6:0] decode_funct7;
wire [4:0] decode_rs1;
wire [4:0] decode_rs2;
wire [4:0] decode_rd;

tiny_rv_decode decode(
    .i_clk,
    .i_reset,

    .i_pipe_stall(i_pipe_stall),
    .i_pipe_flush(pipe_flush),

    .fetch_pc,
    .fetch_inst,

    .decode_pc,
    .decode_inst,
    .decode_imm32,
    .decode_opcode,
    .decode_funct3,
    .decode_funct7,
    .decode_rs1,
    .decode_rs2,
    .decode_rd
);

wire [4:0] read_addr1, read_addr2, write_addr1;
wire [31:0] read_data1, read_data2, write_data1;

wire [4:0] of1_reg, of2_reg;
wire [31:0] of1_val, of2_val;

tiny_rv_dprf dprf (
    .i_clk,

    .read_addr1,
    .read_addr2,
    .write_addr1,

    .read_data1,
    .read_data2,
    .write_data1
);

wire [31:0] rr_pc;
wire [31:0] rr_inst;
wire [31:0] rr_imm32;
wire [6:0]  rr_opcode;
wire [2:0]  rr_funct3;
wire [6:0]  rr_funct7;
wire [31:0]  rr_rs1;
wire [31:0]  rr_rs2;
wire [4:0]  rr_rd;

tiny_rv_rr reg_read (
    .i_clk,
    .i_reset,

    .i_pipe_stall(pipe_stall),
    .i_pipe_flush(pipe_flush),

    .decode_pc,
    .decode_inst,
    .decode_imm32,
    .decode_opcode,
    .decode_funct3,
    .decode_funct7,
    .decode_rs1,
    .decode_rs2,
    .decode_rd,

    .read_p1(read_addr1),
    .read_p2(read_addr2),
    .data_p1(read_data1),
    .data_p2(read_data2),

    .of1_reg, 
    .of2_reg,
    .of1_val, 
    .of2_val,

    .rr_pc,
    .rr_inst,
    .rr_opcode,
    .rr_rd,
    .rr_rs1,
    .rr_rs2,
    .rr_funct3,
    .rr_funct7,
    .rr_imm32
);


endmodule
