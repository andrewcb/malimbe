BUILDDIR	= ../.build/debug
SWIFTCFLAGS	= -F $(BUILDDIR) -I $(BUILDDIR) -L $(BUILDDIR) -laserver -lNSLinux -lswiftGlibc 

all:	testserver1 guestbook


testserver1:	testserver1.swift
	swiftc $(SWIFTCFLAGS) -o testserver1 testserver1.swift


guestbook:	guestbook.swift
	swiftc $(SWIFTCFLAGS) -o guestbook guestbook.swift

clean:
	rm -f testserver1