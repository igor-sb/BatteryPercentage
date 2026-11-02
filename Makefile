# ─── BatteryMenuBar macOS Build ─────────────────────────────
# Produces a single native ARM64 binary — no frameworks embedded,
# no XIBs, no storyboards.  ~200 KB on disk, ~2 MB RAM at runtime.

BINARY     = BatteryMenuBar
SOURCES    = macOS/BatteryMenuBar.swift
FRAMEWORKS = -framework Cocoa -framework IOKit
SWIFTFLAGS = -O

.PHONY: all build bundle clean install uninstall

all: bundle

# Compile to a standalone native binary
build:
	swiftc $(SWIFTFLAGS) $(FRAMEWORKS) $(SOURCES) -o $(BINARY)

# Wrap in a .app bundle so LSUIElement and Info.plist are honoured
bundle: build
	@mkdir -p $(BINARY).app/Contents/MacOS
	@cp $(BINARY) $(BINARY).app/Contents/MacOS/
	@cp macOS/Info.plist $(BINARY).app/Contents/
	@echo "✓ Built $(BINARY).app"

clean:
	@rm -rf $(BINARY) $(BINARY).app
	@echo "✓ Cleaned build artifacts"

install: bundle
	@cp -r $(BINARY).app /Applications/
	@echo "✓ Installed to /Applications/$(BINARY).app"

uninstall:
	@rm -rf /Applications/$(BINARY).app
	@echo "✓ Uninstalled from /Applications/"
