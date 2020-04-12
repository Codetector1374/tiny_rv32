`ifndef RISCV_OPCODES
`define RISCV_OPCODES

`define RV_LUI      7'b0110111
`define RV_AUIPC    7'b0010111
`define RV_JAL      7'b1101111
`define RV_JALR     7'b1100111
`define RV_BRANCH   7'b1100011
`define RV_LB       7'b0000011
`define RV_LH       7'b0000011
`define RV_LW       7'b0000011
`define RV_LBU      7'b0000011
`define RV_LHU      7'b0000011
`define RV_SB       7'b0100011
`define RV_SH       7'b0100011
`define RV_SW       7'b0100011
`define RV_ADDI     7'b0010011
`define RV_SLTI     7'b0010011
`define RV_SLTIU    7'b0010011
`define RV_XORI     7'b0010011
`define RV_ORI      7'b0010011
`define RV_ANDI     7'b0010011
`define RV_SLLI     7'b0010011
`define RV_SRLI     7'b0010011
`define RV_SRAI     7'b0010011
`define RV_ADD      7'b0110011
`define RV_SUB      7'b0110011
`define RV_SLL      7'b0110011
`define RV_SLT      7'b0110011
`define RV_SLTU     7'b0110011
`define RV_XOR      7'b0110011
`define RV_SRL      7'b0110011
`define RV_SRA      7'b0110011
`define RV_OR       7'b0110011
`define RV_AND      7'b0110011
`define RV_FENCE    7'b0001111
`define RV_ECALL    7'b1110011
`define RV_EBREAK   7'b1110011

`define RV_BR_EQ    3'b000
`define RV_BR_NE    3'b001
`define RV_BR_LT    3'b100
`define RV_BR_GE    3'b101
`define RV_BR_LTU   3'b110
`define RV_BR_GEU   3'b111

`endif