module fetch_tb();

reg i_clk = 0;
reg i_reset = 1;


initial
begin
    $dumpfile("trace.vcd");
    $dumpvars(0,fetch_tb);
end


always #1 i_clk = !i_clk;

initial begin
    #2 i_reset = 0;
    #200 $finish();
end

wire [31:0] o_fetched_inst, o_fetched_pc;


reg stall = 0;
reg flush = 0;

reg load_addr = 0;


tiny_rv_tb_fetch uut(
    .i_clk,
    .i_reset,

    .i_pipe_stall(stall),
    .i_pipe_flush(flush),
    .i_ld_new_addr(load_addr),
    .i_new_addr(32'h69696969),

    .o_fetched_pc,
    .o_fetched_inst 
);

initial begin
    #11 stall = 1;
    #4 stall = 0;
    #4 flush = 1;
    #4 flush = 0;

    #4 load_addr = 1;
    #2 load_addr = 0;
end


endmodule
