module tiny_rv_br(
    input wire i_clk,

    input wire [31:0] pc,
    input wire [31:0] next_pc,
    input wire [31:0] computed_broffset,
    input wire [6:0] opcode,
    input wire [2:0] funct3,

    input wire [31:0] rs1,
    input wire [31:0] rs2,

    output wire br_taken,
    output wire [31:0] br_addr,

    output wire active,
    output wire [31:0] result
);

always @* begin
    case(opcode)
        `RV_JAL: begin
            active = 1;
            result = next_pc;
            br_taken = 1;
            br_addr = computed_broffset;
        end
        `RV_JALR: begin
            active = 1;
            result = next_pc;
            br_taken = 1;
            br_addr = rs1 + computed_broffset;
        end
        `RV_BRANCH: begin
            active = 0;
            result = 0;
            br_addr = pc + computed_broffset;
            case(funct3)
                `RV_BR_EQ: br_taken = (sr1 == sr2);
                `RV_BR_NE: br_taken = (sr1 != sr2);
                `RV_BR_LT: br_taken = ($signed(sr1) < $signed(sr2));
                `RV_BR_GE: br_taken = ($signed(sr1) >= $signed(sr2));
                `RV_BR_LTU: br_taken = (sr1 < sr2);
                `RV_BR_GEU: br_taken = (sr1 >= sr2);
                default: br_taken = 0;
            endcase
        end
        default: begin
            active = 0;
            result = 32'h0;
            br_taken = 0;
            br_addr = 0;
        end
    endcase
end

endmodule