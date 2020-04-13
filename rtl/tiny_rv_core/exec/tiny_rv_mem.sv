`default_nettype none

module tiny_rv_mem(
    input wire i_clk, i_reset,

    output wire stall,

    // Wishbone
    output wire o_wb_cyc, o_wb_stb,
    output reg o_wb_we,
    output reg [29:0]o_wb_addr,
    output reg [31:0] o_wb_data,
    output reg [3:0] o_wb_sel,
    input wire i_wb_ack, i_wb_stall, i_wb_err,
    input wire [31:0] i_wb_data,

    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [31:0] rs1,
    input wire [31:0] rs2,
    input wire [31:0] offset,

    output reg [31:0] result,
    output reg active
);

    assign stall = start_tx && !result_valid;

// Wishbone
initial begin
    o_wb_we = 0;
    o_wb_data = 0;
    o_wb_addr = 0;
end

// Internal

// Small inconsistencies between LW, SW, IN, and OUT make this a little
// annoying. Here we generate a bunch of combinational logic so that the state
// machine is simpler.
//
// Buffer Layout:
//  LW: dr <- MEM[sr1+imm]
//  SW: MEM[sr1+imm] <- sr2
//  IN: dr <- IO[imm]
// OUT: IO[imm] <- sr1
//
// However IO is mapped onto the memory bus so mem_addr will hold the mapped
// address for IO. The correct write value will be resolved into wr_val.
//
// IO is mapped into the highest 16 bits of memory however the memory bus is
// only 30 bits wide. To reconcile this, the top 2 bits of the IO imm are
// ignored. 16 + 14 = 30 bits. mem_addr is 32 bits wide. The bottom two bits
// select within a 32 bit word for instruction where this is supported. (none
// right now). When sent on the wishbone bus, only the top 30 bits of mem_addr
// are sent.

    assign active = opcode == `RV_LOAD && result_valid;

wire start_tx;
assign start_tx = (opcode == `RV_LOAD || opcode == `RV_STORE);

wire is_write;
assign is_write = (opcode == `RV_STORE);

wire is_byte_operation;
assign is_byte_operation = (funct3 == `RV_BYTE_OP  // Byte
                         || funct3 == `RV_BYTE_US ); // Unsigned Byte

wire is_half_word_operation;
assign is_half_word_operation = (funct3 == `RV_HALF_OP  || // LH
                                 funct3 == `RV_HALF_US ); // LHU

wire [31:0] mem_addr = rs1 + offset;

wire [31:0] wr_val = rs2;

reg [3:0] wb_sel_val;
always @(*)
    if (is_byte_operation)
        case(mem_addr[1:0])
            3: wb_sel_val = 4'b1000;
            2: wb_sel_val = 4'b0100;
            1: wb_sel_val = 4'b0010;
            default: wb_sel_val = 4'b0001;
        endcase
    else if (is_half_word_operation)
        case(mem_addr[1])
            1: wb_sel_val = 4'b1100;
            default: wb_sel_val = 4'b0011;
        endcase
    else
        wb_sel_val = 4'b1111;

reg [31:0] write_data;
always @(*)
    if (is_byte_operation)
        case(mem_addr[1:0])
            3: write_data = wr_val << 24;
            2: write_data = wr_val << 16;
            1: write_data = wr_val << 8;
            default: write_data = wr_val;
        endcase
    else if (is_half_word_operation)
        case(mem_addr[1])
            1: write_data = wr_val << 16;
            default: write_data = wr_val;
        endcase
    else
        write_data = wr_val;


// WOW Verilog, you are like Tiger
function [15:0] trunc_32_to_8(input [31:0] val32);
  trunc_32_to_8 = {8'h0, val32[7:0]};
endfunction

function [15:0] trunc_32_to_16(input [31:0] val32);
  trunc_32_to_16 = val32[15:0];
endfunction


reg [31:0] in_data;
reg [15:0] shifted_i_data;
always @(*)
    if (is_byte_operation) begin
        case(mem_addr[1:0])
            3: shifted_i_data = trunc_32_to_8(i_wb_data >> 24);
            2: shifted_i_data = trunc_32_to_8(i_wb_data >> 16);
            1: shifted_i_data = trunc_32_to_8(i_wb_data >> 8);
            default: shifted_i_data = trunc_32_to_8(i_wb_data);
        endcase
        if (funct3 == `RV_BYTE_OP) // LWSE
            in_data = {{24{shifted_i_data[7]}}, shifted_i_data[7:0]};
        else
            in_data = {24'h0, shifted_i_data[7:0]};
    end
    else if (is_half_word_operation) begin
        case(mem_addr[1])
            1: shifted_i_data = trunc_32_to_16(i_wb_data >> 16);
            default: shifted_i_data = trunc_32_to_16(i_wb_data);
        endcase
        if (funct3 == `RV_HALF_OP) // LHWSE
            in_data = {{16{shifted_i_data[15]}}, shifted_i_data};
        else
            in_data = {16'h0, shifted_i_data};
    end
    else
        in_data = i_wb_data;


    localparam  WB_IDLE = 0,
                WB_STROBE = 1,
                WB_WAIT = 2;

    reg [3:0] state;
    initial state = WB_IDLE;

    reg result_valid = 0;

    assign o_wb_cyc = state != WB_IDLE;
    assign o_wb_stb = state == WB_STROBE;

always @(posedge i_clk) begin
    result_valid <= 0;
    if (i_reset) begin
        state <= WB_IDLE;
    end
    else if (state == WB_IDLE) begin
        if (start_tx && !result_valid) begin
            o_wb_sel <= wb_sel_val;
            o_wb_addr <= mem_addr[31:2];
            o_wb_data <= write_data;
            o_wb_we <= is_write;
            state <= WB_STROBE;
        end
    end
    else if (i_wb_ack || i_wb_err) begin
        state <= WB_IDLE;
        result <= in_data;
        result_valid <= 1;
    end
    else if (state == WB_STROBE && !i_wb_stall) begin
        state <= WB_WAIT;
    end
end

endmodule : tiny_rv_mem


