module tiny_rv_tb_fetch(
    input wire i_clk,
    input wire i_reset,

    input wire i_pipe_stall,
    input wire i_pipe_flush,
    input wire [31:0] i_ld_new_addr,
    input wire [31:0] i_new_addr,

    output reg [31:0] o_fetched_pc,
    output reg [31:0] o_fetched_inst
);

reg [31:0] imem [65535];

reg [31:0] current_pc;


always @(posedge i_clk) begin
    if (i_reset)
        current_pc <= 32'h0;
    else begin
        if (i_pipe_flush || i_ld_new_addr) begin
            o_fetched_inst <= 0;
            if (i_ld_new_addr) begin
            current_pc <= i_new_addr + 4; // Current PC should set to the next;
            o_fetched_pc <= i_new_addr;
            o_fetched_inst <= imem[i_new_addr];
            end
        end
        else if (!i_pipe_stall) begin
            current_pc <= current_pc + 4;
            o_fetched_pc <= current_pc;
            o_fetched_inst <= imem[current_pc];
        end
    end
end


endmodule
