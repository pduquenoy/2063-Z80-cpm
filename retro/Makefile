TOP=..
include $(TOP)/Make.default


all: retro.bin

clean:
	rm -f *.lst *.bin *.hex *.sym 

DATE := $(shell date +"%Y-%m-%d %H:%M:%S%z")
GIT_VERSION := $(shell git describe --long --dirty; git show -s --format='%ci')
%.bin: %.asm
	cat $< | sed -e "s/@@DATE@@/$(DATE)/g" -e "s/@@GIT_VERSION@@/$(GIT_VERSION)/g" | $(CROSS_AS) - -o $@ --list=$(basename $@).lst --label=$(basename $@).sym $(CROSS_AS_FLAGS)

world: clean all

retro.bin: ../cpm-2.2/src/cpm22.asm retro.asm 
retro.bin: disk_callgate.asm disk_config.asm 
retro.bin: disk_dmcache.asm disk_nhacp.asm disk_nocache.asm disk_stub.asm
