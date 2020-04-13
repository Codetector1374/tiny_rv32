`ifndef RISCV_OPCODES
`define RISCV_OPCODES

`define RV_LUI      7'b0110111
`define RV_AUIPC    7'b0010111
`define RV_JAL      7'b1101111
`define RV_JALR     7'b1100111
`define RV_BRANCH   7'b1100011
`define RV_LOAD     7'b0000011
`define RV_STORE    7'b0100011
`define RV_ALUI     7'b0010011
`define RV_ALU      7'b0110011
`define RV_FENCE    7'b0001111
`define RV_SYSTEM   7'b1110011

`define RV_BR_EQ    3'b000
`define RV_BR_NE    3'b001
`define RV_BR_LT    3'b100
`define RV_BR_GE    3'b101
`define RV_BR_LTU   3'b110
`define RV_BR_GEU   3'b111

`define RV_ALU_ADD  3'b000
`define RV_ALU_SLT  3'b010
`define RV_ALU_SLTU 3'b011
`define RV_ALU_XOR  3'b100
`define RV_ALU_OR   3'b110
`define RV_ALU_AND  3'b111
`define RV_ALU_SHL   3'b001
`define RV_ALU_SHR   3'b101

`define RV_EINST 3'b000
`define RV_CSRRW 3'b001
`define RV_CSRRS 3'b010
`define RV_CSRRC 3'b011
`define RV_CSRRWI 3'b101
`define RV_CSRRSI 3'b110
`define RV_CSRRCI 3'b111

`define RV_BYTE_OP      3'b000
`define RV_BYTE_US      3'b100
`define RV_HALF_OP      3'b001
`define RV_HALF_US      3'b101
`define RV_WORD         3'b010

`define RV_FENCE_I  3'b001

`endif