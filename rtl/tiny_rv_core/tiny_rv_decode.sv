`include "./rv_opcodes.sv"

module tiny_rv_decode(
    input wire i_clk,
    input wire i_reset,

    input wire i_pipe_stall,
    input wire i_pipe_flush,

    input wire [31:0] fetch_pc,
    input wire [31:0] fetch_inst,

    output reg [31:0] decode_pc,
    output reg [31:0] decode_inst,
    output reg [31:0] decode_imm32,
    output reg [6:0] decode_opcode,
    output reg [2:0] decode_funct3,
    output reg [6:0] decode_funct7,
    output reg [4:0] decode_rs1,
    output reg [4:0] decode_rs2,
    output reg [4:0] decode_rd
);

wire [6:0] fetch_opcode = fetch_inst[6:0];

always @(posedge i_clk) begin
    if (i_pipe_flush || i_reset) begin
        decode_pc <= 0;
        decode_inst <= 0;
        decode_imm32 <= 0;
        decode_opcode <= 0;
        decode_funct3 <= 0;
        decode_funct7 <= 0;
        decode_rs1 <= 0;
        decode_rs2 <= 0;
        decode_rd <= 0;
    end
    else if (!i_pipe_stall) begin
        decode_pc <= fetch_pc;
        decode_inst <= fetch_inst;
        decode_opcode <= fetch_opcode;
        decode_funct3 <= fetch_inst[14:12];
        decode_funct7 <= fetch_inst[31:25];
        decode_rs1 <= fetch_inst[19:15];
        decode_rs2 <= fetch_inst[24:20];
        decode_rd <= fetch_inst[11:7];
        // TODO Imm
        case (fetch_opcode)
        // U Type Imm
            `RV_LUI,
            `RV_AUIPC: decode_imm32 <= {fetch_inst[31:12], 12'b0};
        // J Type Imm
            `RV_JAL: decode_imm32 <= {{12{fetch_inst[31]}}, fetch_inst[19:12], fetch_inst[20], fetch_inst[30:25], fetch_inst[24:21], 1'b0};
        // B Type Imm
            `RV_BRANCH: decode_imm32 <= {{20{fetch_inst[31]}}, fetch_inst[7], fetch_inst[30:25], fetch_inst[11:8], 1'b0};
        // ALUI
            `RV_ALUI: decode_imm32 <= {{21{fetch_inst[31]}}, fetch_inst[30:20]};
            default: decode_imm32 <= 0;
        endcase
    end
end


endmodule
