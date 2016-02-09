BUILDDIR	= ../.build/debug
SWIFTCFLAGS	= -F $(BUILDDIR) -I $(BUILDDIR) -L $(BUILDDIR) -lmalimbe -lNSLinux -lswiftGlibc 

all:	testserver1 guestbook


testserver1:	testserver1.swift $(BUILDDIR)/libmalimbe.a $(BUILDDIR)/libNSLinux.a
	swiftc $(SWIFTCFLAGS) -o testserver1 testserver1.swift


guestbook:	guestbook.swift $(BUILDDIR)/libmalimbe.a $(BUILDDIR)/libNSLinux.a
	swiftc $(SWIFTCFLAGS) -o guestbook guestbook.swift

# swift build, for some reason, names libraries foo.a, rather than the libfoo.a ld looks for.
# perhaps this will be fixed in subsequent versions of Swift for Linux
$(BUILDDIR)/libmalimbe.a:	$(BUILDDIR)/malimbe.a
	cp $(BUILDDIR)/malimbe.a $(BUILDDIR)/libmalimbe.a
$(BUILDDIR)/libNSLinux.a:	$(BUILDDIR)/NSLinux.a
	cp $(BUILDDIR)/NSLinux.a $(BUILDDIR)/libNSLinux.a

clean:
	rm -f testserver1 guestbook