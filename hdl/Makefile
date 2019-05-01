HDLC = ghdl

SRC_DIR = src
TB_DIR = test

.PHONY: all test_alu test_shifter test_basic_register test_memory_interface clean

all: alu_tb shifter_tb basic_register_tb memory_interface_tb

alu.o: $(SRC_DIR)/alu.vhd
	$(HDLC) -a $(SRC_DIR)/alu.vhd

shifter.o: $(SRC_DIR)/shifter.vhd
	$(HDLC) -a $(SRC_DIR)/shifter.vhd

basic_register.o: $(SRC_DIR)/basic_register.vhd
	$(HDLC) -a $(SRC_DIR)/basic_register.vhd

memory_interface.o: $(SRC_DIR)/memory_interface.vhd
	$(HDLC) -a $(SRC_DIR)/memory_interface.vhd

alu_tb.o: $(TB_DIR)/alu_tb.vhd alu.o
	$(HDLC) -a $(TB_DIR)/alu_tb.vhd

shifter_tb.o: $(TB_DIR)/shifter_tb.vhd shifter.o
	$(HDLC) -a $(TB_DIR)/shifter_tb.vhd

basic_register_tb.o: $(TB_DIR)/basic_register_tb.vhd basic_register.o
	$(HDLC) -a $(TB_DIR)/basic_register_tb.vhd

memory_interface_tb.o: $(TB_DIR)/memory_interface_tb.vhd memory_interface.o
	$(HDLC) -a $(TB_DIR)/memory_interface_tb.vhd

alu_tb: alu_tb.o
	$(HDLC) -e alu_tb

shifter_tb: shifter_tb.o
	$(HDLC) -e shifter_tb

basic_register_tb: basic_register_tb.o
	$(HDLC) -e basic_register_tb

memory_interface_tb: memory_interface_tb.o
	$(HDLC) -e memory_interface_tb

test_alu:
	$(HDLC) -r alu_tb --vcd=alu_tb.vcd --stop-time=300ns

test_shifter:
	$(HDLC) -r shifter_tb --vcd=shifter_tb.vcd --stop-time=100ns

test_basic_register:
	$(HDLC) -r basic_register_tb --vcd=basic_register_tb.vcd --stop-time=100ns

test_memory_interface:
	$(HDLC) -r memory_interface_tb --vcd=memory_interface_tb.vcd --stop-time=100ns

clean:
	rm -f *.o *.vcd *.cf alu_tb shifter_tb basic_register_tb memory_interface_tb
