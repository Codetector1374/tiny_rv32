module tiny_rv_rr(
    input wire i_clk,
    input wire i_reset,

    input wire i_pipe_stall,
    input wire i_pipe_flush,

    input wire [31:0] decode_pc,
    input wire [31:0] decode_inst,
    input wire [31:0] decode_imm32,
    input wire [6:0] decode_opcode,
    input wire [2:0] decode_funct3,
    input wire [6:0] decode_funct7,
    input wire [4:0] decode_rs1,
    input wire [4:0] decode_rs2,
    input wire [4:0] decode_rd,

    output wire [4:0] read_p1,
    output wire [4:0] read_p2,
    input wire [31:0] data_p1,
    input wire [31:0] data_p2,

    input wire [4:0] of1_reg, of2_reg,
    input wire [31:0] of1_val, of2_val,

    output reg [31:0] rr_pc,
    output reg [31:0] rr_inst,
    output reg [6:0] rr_opcode,
    output reg [4:0] rr_rd,
    output reg [31:0] rr_rs1,
    output reg [31:0] rr_rs2,
    output reg [2:0] rr_funct3,
    output reg [6:0] rr_funct7,
    output reg [31:0] rr_imm32
);

assign read_p1 = decode_rs1;
assign read_p2 = decode_rs2;


always @(posedge i_clk) begin
    if (i_reset || i_pipe_flush) begin
        rr_pc <= 0;
        rr_inst <= 0;
        rr_opcode <= 0;
        rr_rd <= 0;
        rr_rs1 <= 0;
        rr_rs2 <= 0;
        rr_funct3 <= 0;
        rr_funct <= 0;
        rr_imm32 <= 0;
    end 
    else if (!i_pipe_stall) begin

        rr_pc <= decode_pc;
        rr_inst <= decode_inst;
        rr_opcode <= decode_opcode;
        rr_rd <= decode_rd;
        rr_funct3 <= decode_funct3;
        rr_funct <= decode_funct7;
        rr_imm32 <= decode_imm32;

        // Register Forwarding RS1
        if (decode_rs1 == 5'b0) begin
            rr_rs1 <= 32'h0;
        end
        else if (decode_rs1 == of1_reg) begin
            rr_rs1 <= of1_val;
        end
        else if (decode_rs1 == of2_ref) begin
            rr_rs1 <= of2_val;
        end
        else begin
            rr_rs1 <= data_p1;
        end
        // Register Forwarding RS2
        if (decode_rs2 == 5'b0) begin
            rr_rs2 <= 32'h0;
        end
        else if (decode_rs2 == of1_reg) begin
            rr_rs2 <= of1_val;
        end
        else if (decode_rs2 == of2_ref) begin
            rr_rs2 <= of2_val;
        end
        else begin
            rr_rs2 <= data_p2;
        end
    end
end


endmodule
