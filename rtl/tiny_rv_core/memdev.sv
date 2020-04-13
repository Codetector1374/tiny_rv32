module	memdev(i_clk, i_wb_cyc, i_wb_stb, i_wb_we, i_wb_addr, i_wb_data, i_wb_sel,
    o_wb_ack, o_wb_stall, o_wb_data);
    parameter	LGMEMSZ=15, DW=32, EXTRACLOCK= 0;
    localparam	AW = LGMEMSZ - 2;
    input	wire			i_clk, i_wb_cyc, i_wb_stb, i_wb_we;
    input	wire	[(AW-1):0]	i_wb_addr;
    input	wire	[(DW-1):0]	i_wb_data;
    input	wire	[(DW/8-1):0]	i_wb_sel;
    output	reg			o_wb_ack;
    output	wire			o_wb_stall;
    output	reg	[(DW-1):0]	o_wb_data;

    wire			w_wstb, w_stb;
    wire	[(DW-1):0]	w_data;
    wire	[(AW-1):0]	w_addr;
    wire	[(DW/8-1):0]	w_sel;

    generate
        if (EXTRACLOCK == 0)
            begin

                assign	w_wstb = (i_wb_stb)&&(i_wb_we);
                assign	w_stb  = i_wb_stb;
                assign	w_addr = i_wb_addr;
                assign	w_data = i_wb_data;
                assign	w_sel  = i_wb_sel;

            end else begin

            reg		last_wstb, last_stb;
            always @(posedge i_clk)
                last_wstb <= (i_wb_stb)&&(i_wb_we);
            always @(posedge i_clk)
                last_stb <= (i_wb_stb);

            reg	[(AW-1):0]	last_addr;
            reg	[(DW-1):0]	last_data;
            reg	[(DW/8-1):0]	last_sel;
            always @(posedge i_clk)
                last_data <= i_wb_data;
            always @(posedge i_clk)
                last_addr <= i_wb_addr;
            always @(posedge i_clk)
                last_sel <= i_wb_sel;

            assign	w_wstb = last_wstb;
            assign	w_stb  = last_stb;
            assign	w_addr = last_addr;
            assign	w_data = last_data;
            assign	w_sel  = last_sel;
        end endgenerate

    reg	[(DW-1):0]	mem	[0:((1<<AW)-1)];

    always @(posedge i_clk)
        begin
            o_wb_data <= mem[w_addr];

            if ((w_wstb)&&(w_sel[3]))
                mem[w_addr][31:24] <= w_data[31:24];
            if ((w_wstb)&&(w_sel[2]))
                mem[w_addr][23:16] <= w_data[23:16];
            if ((w_wstb)&&(w_sel[1]))
                mem[w_addr][15: 8] <= w_data[15:8];
            if ((w_wstb)&&(w_sel[0]))
                mem[w_addr][ 7: 0] <= w_data[7:0];

            o_wb_ack <= (w_stb);
        end
    assign	o_wb_stall = 1'b0;

    // Now, let's keep verilator happy
    // verilator lint_off UNUSED
    wire	unused;
    assign	unused = i_wb_cyc;
    // verilator lint_on UNUSED
endmodule
