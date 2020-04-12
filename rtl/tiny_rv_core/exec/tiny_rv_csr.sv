module tiny_rv_csr(
    input wire i_clk,

    input wire [31:0] pc,
    input wire [31:0] inst,
    input wire [6:0] opcode,
    input wire [2:0] funct3,

    input wire [31:0] rs1,
    input wire [31:0] rs2,

    input wire [11:0] csr,

    output reg active,
    output reg [31:0] result
);

    always @(*) begin
        result = 32'b0;
        if (opcode == `RV_SYSTEM) begin
            case (funct3)
                `RV_CSRRS: active = 1;
                default: active = 0;
            endcase
        end
    end

endmodule : tiny_rv_csr