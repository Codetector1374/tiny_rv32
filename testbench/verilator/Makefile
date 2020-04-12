RTL_DIR = ../../rtl

.PHONY: verilator clean

verilator:
	verilator --cc --trace --public +1800-2009ext+.sv \
	-I$(RTL_DIR)/tiny_rv_core -I$(RTL_DIR)/tiny_rv_core/exec \
	$(RTL_DIR)/tiny_rv_core/tiny_rv.sv
	make -f Vtiny_rv.mk -C obj_dir

clean:
	rm -rf obj_dir/