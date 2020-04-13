module tiny_rv(
    input wire i_clk,
    input wire i_reset
);


wire pipe_stall, pipe_flush;

wire [31:0] new_pc;
wire ld_new_pc;

wire [31:0] fetch_pc, fetch_inst;

wire flush_icache, icache_clean;

`define FETCH_CACHE
`ifdef FETCH_CACHE
tiny_rv_fetch_directmap fetch(
    .i_clk, .i_reset,
    .i_pipe_stall(pipe_stall),
    .i_pipe_flush(pipe_flush),
    .i_new_pc(ld_new_pc), .i_pc(new_pc),
    // Wishbone stuff
    .o_wb_cyc(fetch_wb_cyc), .o_wb_stb(fetch_wb_stb), .o_wb_we(fetch_wb_we),
    .o_wb_addr(fetch_wb_addr), .o_wb_data(fetch_wb_data_mosi), .o_wb_sel(fetch_wb_sel),
    .i_wb_ack(fetch_wb_ack), .i_wb_stall(fetch_wb_stall), .i_wb_err(fetch_wb_err),
    .i_wb_data(master_wb_data_miso),
    // Buffer
    .o_buf_pc(fetch_pc), .o_buf_inst(fetch_inst),
    .i_clear_cache(flush_icache), .o_cache_clean(icache_clean)
);

`else
    assign icache_clean = 1;
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
`endif

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

    .i_pipe_stall(pipe_stall),
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

wire [4:0] of1_reg;
wire [31:0] of1_val;

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
    .of2_reg(write_addr1),
    .of1_val, 
    .of2_val(write_data1),

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

wire [31:0] exec_pc, exec_inst;

tiny_rv_exec exec(
    .i_clk,
    .i_reset,

    .exec_rr_stall(pipe_stall), 
    .exec_rr_flush(pipe_flush),

    .rr_pc,
    .rr_inst,
    .rr_opcode,
    .rr_rd,
    .rr_rs1,
    .rr_rs2,
    .rr_funct3,
    .rr_funct7,
    .rr_imm32,

    .exec_pc,
    .exec_inst,
    // Writeback
    .exec_rd(write_addr1),
    .exec_rd_val(write_data1),

    .of1_reg,
    .of1_val,

    .new_pc,
    .ld_new_pc,
    .o_flush_icache(flush_icache),
    .i_icache_clean(icache_clean),

    .o_wb_cyc(mem_wb_cyc),
    .o_wb_stb(mem_wb_stb),
    .o_wb_we(mem_wb_we),
    .o_wb_addr(mem_wb_addr),
    .o_wb_data(mem_wb_data_mosi),
    .o_wb_sel(mem_wb_sel),
    .i_wb_ack(mem_wb_ack),
    .i_wb_stall(mem_wb_stall),
    .i_wb_err(mem_wb_err),
    .i_wb_data(master_wb_data_miso)
);

// ========================
//    WISHBONE
// =========================
    // MASTER
    wire master_wb_cyc, master_wb_stb;
    wire master_wb_we;
    wire [29:0] master_wb_addr;
    wire [31:0] master_wb_data_mosi;
    wire [3:0] master_wb_sel;
    wire master_wb_ack, master_wb_stall, master_wb_err;
    wire [31:0] master_wb_data_miso;

    // FETCH
    wire fetch_wb_cyc, fetch_wb_stb;
    wire fetch_wb_we;
    wire [29:0] fetch_wb_addr;
    wire [31:0] fetch_wb_data_mosi;
    wire [3:0] fetch_wb_sel;
    wire fetch_wb_ack, fetch_wb_stall, fetch_wb_err;

    // MEM
    wire mem_wb_cyc, mem_wb_stb;
    wire mem_wb_we;
    wire [29:0] mem_wb_addr;
    wire [31:0] mem_wb_data_mosi;
    wire [3:0] mem_wb_sel;
    wire mem_wb_ack, mem_wb_stall, mem_wb_err;



    wbpriarbiter master_arb (.i_clk,
        // Bus A
        .i_a_cyc(mem_wb_cyc), .i_a_stb(mem_wb_stb), .i_a_we(mem_wb_we), .i_a_adr(mem_wb_addr), .i_a_dat(mem_wb_data_mosi), .i_a_sel(mem_wb_sel), .o_a_ack(mem_wb_ack), .o_a_stall(mem_wb_stall), .o_a_err(mem_wb_err),
        // Bus B
        .i_b_cyc(fetch_wb_cyc), .i_b_stb(fetch_wb_stb), .i_b_we(fetch_wb_we), .i_b_adr(fetch_wb_addr), .i_b_dat(fetch_wb_data_mosi), .i_b_sel(fetch_wb_sel), .o_b_ack(fetch_wb_ack), .o_b_stall(fetch_wb_stall), .o_b_err(fetch_wb_err),
        // Both buses
        .o_cyc(master_wb_cyc), .o_stb(master_wb_stb), .o_we(master_wb_we), .o_adr(master_wb_addr), .o_dat(master_wb_data_mosi), .o_sel(master_wb_sel), .i_ack(master_wb_ack), .i_stall(master_wb_stall), .i_err(master_wb_err));

//    `ifdef VERILATOR
    memdev #(20) my_mem(
        .i_clk(i_clk),
        .i_wb_cyc(master_wb_cyc),
        .i_wb_stb(master_wb_stb),
        .i_wb_we(master_wb_we),
        .i_wb_addr(master_wb_addr[19-2:0]),
        .i_wb_data(master_wb_data_mosi),
        .i_wb_sel(master_wb_sel),

        .o_wb_ack(master_wb_ack),
        .o_wb_stall(master_wb_stall),
        .o_wb_data(master_wb_data_miso)
    );
//    `else



endmodule : tiny_rv
