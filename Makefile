prefix ?= /usr/local
bindir = $(prefix)/bin

build:
	swift build -c release --disable-sandbox

install: build
	install -d "$(bindir)"
	install ".build/release/MakeColors" "$(bindir)/make-colors"

uninstall:
	rm -rf "$(bindir)/make-colors"

clean:
	rm -rf .build

.PHONY: build install uninstall clean
