HDLC = ghdl

SRC_DIR = src
TB_DIR = test

.PHONY: all test_alu clean

all: alu_tb shifter_tb

alu.o: $(SRC_DIR)/alu.vhd
	$(HDLC) -a $(SRC_DIR)/alu.vhd

shifter.o: $(SRC_DIR)/shifter.vhd
	$(HDLC) -a $(SRC_DIR)/shifter.vhd

alu_tb.o: $(TB_DIR)/alu_tb.vhd alu.o
	$(HDLC) -a $(TB_DIR)/alu_tb.vhd

shifter_tb.o: $(TB_DIR)/shifter_tb.vhd shifter.o
	$(HDLC) -a $(TB_DIR)/shifter_tb.vhd

alu_tb: alu_tb.o
	$(HDLC) -e alu_tb

shifter_tb: shifter_tb.o
	$(HDLC) -e shifter_tb

test_alu:
	$(HDLC) -r alu_tb --vcd=alu_tb.vcd --stop-time=300ns

test_shifter:
	$(HDLC) -r shifter_tb --vcd=shifter_tb.vcd --stop-time=100ns

clean:
	rm -f *.o *.vcd *.cf alu_tb shifter_tb
