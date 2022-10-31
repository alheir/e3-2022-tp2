PROJ = blinky
PIN_DEF = ../upduino.pcf
DEVICE = up5k
PACKAGE = sg48

ICEPACK = icepack
ICETIME = icetime
ICEPROG = iceprog

all: $(PROJ).bin

%.json: %.v
	yosys -p 'synth_ice40 -json $@' $<

%.asc: $(PIN_DEF) %.json
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --asc $@ --pcf-allow-unconstrained --pcf $< --json $*.json

%.bin: %.asc
	$(ICEPACK) $< $@

%.rpt: %.asc
	$(ICETIME) -d $(DEVICE) -mtr $@ $<

# prog: $(PROJ).bin
# 	$(ICEPROG) -S $<

# sudo-prog: $(PROJ).bin
# 	@echo 'Executing prog as root!!!'
# 	sudo $(ICEPROG) -S $<

flash: $(PROJ).bin
	$(ICEPROG) -d i:0x0403:0x6014 -X $<

# sim: $(PROJ)_tb.vcd
# 	gtkwave $< $(<:.vcd=.gtkw) &

# #-- set the dependencies for simulation
# $(PROJ)_tb.vcd: $(PROJ).v $(PROJ)_tb.v

clean:
	rm -f $(PROJ).json $(PROJ).asc $(PROJ).rpt $(PROJ).bin

.SECONDARY:
.PHONY: all prog clean