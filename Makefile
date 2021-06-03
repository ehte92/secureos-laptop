install:
	install -Dm755 secureos "$(DESTDIR)/usr/bin/secureos"

all: install
