RTL = ../../rtl/tiny_rv_core

SRCS = $(RTL)/tiny_rv_tb_fetch.sv \
./fetch_tb.sv

TOP = fetch_tb

.PHONY: run build clean

run: a.out
	./a.out

build: a.out

a.out: $(SRCS)
	iverilog -g 2005-sv $^ -s $(TOP)

clean: 
	rm -rf a.out