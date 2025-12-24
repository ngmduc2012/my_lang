.PHONY: init test test-root test-example push

FLUTTER ?= flutter

init:
	$(FLUTTER) pub get
	cd example && $(FLUTTER) pub get

test: test-root test-example

test-root:
	$(FLUTTER) test

test-example:
	cd example && $(FLUTTER) test

push:
	git add .
	git commit -m "$(shell date '+%Y-%m-%d %H:%M')" || true
	git push
