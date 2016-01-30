BUILDDIR	= ../.build/debug
SWIFTCFLAGS	= -F $(BUILDDIR) -I $(BUILDDIR) -L $(BUILDDIR) -laserver -lNSLinux -lswiftGlibc 

all:	testserver1


testserver1:	testserver1.swift
	swiftc $(SWIFTCFLAGS) -o testserver1 testserver1.swift


clean:
	rm -f testserver1