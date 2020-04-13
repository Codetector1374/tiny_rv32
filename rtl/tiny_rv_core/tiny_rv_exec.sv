`default_nettype none;
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
    output wire ld_new_pc,

    output reg o_flush_icache,
    input wire i_icache_clean,

    // Wishbone
    output wire o_wb_cyc, o_wb_stb, o_wb_we,
    output wire [29:0] o_wb_addr,
    output wire [31:0] o_wb_data,
    output wire [3:0] o_wb_sel,
    input wire i_wb_ack, i_wb_stall, i_wb_err,
    input wire [31:0] i_wb_data
);
    wire [11:0] rr_csr = rr_inst[31:20];

    assign exec_rr_flush = br_ldpc || fence_flush;
    assign exec_rr_stall = mem_stall || fence_stall;

    // BR PC
    assign ld_new_pc = br_ldpc || fence_flush;
    always @* begin
        if (br_ldpc)
            new_pc = br_pc;
        else if (fence_flush)
            new_pc = fence_pc;
        else
            new_pc = 32'b0;
    end

    wire br_active;
    wire [31:0] br_result;
    wire br_ldpc;
    wire [31:0] br_pc;

    tiny_rv_br branch_unit(
        .i_clk,

        .pc(rr_pc),
        .next_pc(rr_pc+4),
        .computed_broffset(rr_imm32),
        .opcode(rr_opcode),
        .funct3(rr_funct3),

        .rs1(rr_rs1),
        .rs2(rr_rs2),

        .br_taken(br_ldpc),
        .br_addr(br_pc),

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

    wire mem_stall, mem_active;
    wire [31:0] mem_result;

    tiny_rv_mem mem(
        .i_clk,
        .i_reset,
        .stall(mem_stall),
        .o_wb_cyc, .o_wb_stb, .o_wb_we,
        .o_wb_addr, .o_wb_data, .o_wb_sel,
        .i_wb_ack, .i_wb_stall, .i_wb_err,
        .i_wb_data,

        .opcode(rr_opcode),
        .funct3(rr_funct3),
        .rs1(rr_rs1),
        .rs2(rr_rs2),
        .offset(rr_imm32),

        .result(mem_result),
        .active(mem_active)
    );


    // BEGIN FENCE
    wire fence_flush = fence_state == FENCE_DONE;
    wire fence_stall = (fence_state != FENCE_DONE) && (rr_opcode == `RV_FENCE);
    wire [31:0] fence_pc = rr_pc + 4;
    localparam FENCE_IDLE = 2'h0, FENCE_EX = 2'h1, FENCE_DONE = 2'h2;
    reg [1:0] fence_state = 0;
    always @(posedge i_clk) begin
        if (i_reset) begin
            fence_state <= FENCE_IDLE;
        end
        else if (fence_state == FENCE_DONE)
            fence_state <= FENCE_IDLE;
        else if (rr_opcode == `RV_FENCE) begin
            if (rr_funct3 == `RV_FENCE_I) begin
                if (fence_state == FENCE_IDLE) begin
                    o_flush_icache <= 1;
                    fence_state <= FENCE_EX;
                end
                else if (fence_state == FENCE_EX) begin
                    o_flush_icache <= 0;
                    if (i_icache_clean)
                        fence_state <= FENCE_DONE;
                end
            end
            else
                fence_state <= FENCE_DONE;
        end
    end
    // END FENCE

    wire any_active = br_active | alu_active | csr_active | mem_active;

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
        else if (mem_active)
            of1_val = mem_result;
        else
            of1_val = 32'b0;
    end

endmodule: tiny_rv_exec
