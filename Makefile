#!/usr/bin/make
# Targets:
#   make DIRNAME-autograde
#      enter DIRNAME and call the autograde target to generate
#       ./autograde.tar

.PHONY: clean

%-autograde:
	$(MAKE) -C $* autograde

clean:
	rm -f *.tar
