module tiny_rv_alu(
    input wire i_clk,

    input wire [31:0] pc,
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [6:0] funct7,

    input wire [31:0] rs1,
    input wire [31:0] rs2,
    input wire [31:0] imm,

    output reg [31:0] result,
    output reg active
);

always @* begin
    active = 1;
    result = 32'h1337_1337;
    case(opcode)
        `RV_LUI: result = imm;
        `RV_AUIPC: result = imm + pc;
        `RV_ALUI:
            case (funct3)
                `RV_ALU_ADD: result = imm + rs1;
                `RV_ALU_SLT: result = ($signed(rs1) < $signed(imm)) ? 32'b1 : 32'b0;
                `RV_ALU_SLTU: result = (rs1 < imm) ? 32'b1 : 32'b0;
                `RV_ALU_XOR: result = rs1 ^ imm;
                `RV_ALU_OR: result = rs1 | imm;
                `RV_ALU_AND: result = rs1 & imm;
                `RV_ALU_SHL: result = rs1 << (imm[4:0]);
                `RV_ALU_SHR:
                    if (imm[10])
                        result = $signed($signed(rs1) >>> imm[4:0]);
                    else
                        result = rs1 >> imm[4:0];
                default: active = 0;
            endcase
        `RV_ALU:
            case (funct3)
                `RV_ALU_ADD:
                    if (funct7[5])
                        result = $signed(rs1) - $signed(rs2);
                    else
                        result = rs1 + rs2;
                `RV_ALU_SLT: result = ($signed(rs1) < $signed(rs2)) ? 32'b1 : 32'b0;
                `RV_ALU_SLTU: result = (rs1 < rs2) ? 32'b1 : 32'b0;
                `RV_ALU_XOR: result = rs1 ^ rs2;
                `RV_ALU_OR: result = rs1 | rs2;
                `RV_ALU_AND: result = rs1 & rs2;
                `RV_ALU_SHL: result = rs1 << (rs2[4:0]);
                `RV_ALU_SHR:
                    if (funct7[5])
                        result = $signed($signed(rs1) >>> rs2[4:0]);
                    else
                        result = rs1 >> rs2[4:0];
                default: active = 0;
            endcase

        default: begin
            result = 32'b0; active = 0;
        end
    endcase
end

endmodule
