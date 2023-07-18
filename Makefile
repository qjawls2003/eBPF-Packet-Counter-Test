TARGETS = my_ebpf_program

all: $(TARGETS)
.PHONY: all

$(TARGETS): %: %.bpf.o 

%.bpf.o: %.bpf.c
	clang \
	    -target bpf \
		-I/usr/include/$(shell uname -m)-linux-gnu \
		-g \
	    -O2 -o $@ -c $<

load:
	- bpftool prog load $(TARGETS).bpf.o /sys/fs/bpf/$(TARGETS)
	- bpftool prog list
	- echo 'bpftool net attach xdp id <program id> dev <interface>'

check:
	- bpftool prog list

attach: 
	- bpftool net attach xdp id 119 dev ens33
	- bpftool net list
	- ip link

clean: 
	- rm *.bpf.o
	- rm -f /sys/fs/bpf/my_ebpf_program
	- bpftool net detach xdp dev ens33

monitor:
	- bpftool prog tracelog