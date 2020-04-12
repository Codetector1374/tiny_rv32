module tiny_rv_dprf(
    input wire i_clk,

    input wire [4:0] read_addr1,
    input wire [4:0] read_addr2,
    input wire [4:0] write_addr1,

    output reg [31:0] read_data1,
    output reg [31:0] read_data2,
    input wire [31:0] write_data1
);

reg [31:0] registers [32];

always @(*) begin
    if (|read_addr1)
        read_data1 = registers[read_addr1];
    else
        read_data1 = 32'h0;
end

always @(*) begin
    if (|read_addr2)
        read_data2 = registers[read_addr2];
    else
        read_data2 = 32'h0;
endmodule

always @(posedge i_clk) begin
    registers[write_addr1] <= write_data1;
end
