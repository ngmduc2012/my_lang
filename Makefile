.PHONY: init test test-root test-example

FLUTTER ?= flutter

init:
	$(FLUTTER) pub get
	cd example && $(FLUTTER) pub get

test: test-root test-example

test-root:
	$(FLUTTER) test

test-example:
	cd example && $(FLUTTER) test
