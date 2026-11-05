# ⚡ BatteryPercentage

A **zero-dependency**, native Swift battery percentage widget for **macOS** and **iOS**.

Compiles straight to ARM64/x86_64 machine code via LLVM — no Electron, no web views, no runtime overhead. The macOS binary is a single ~200 KB executable that uses ~2 MB RAM.

---

## Features

| | macOS (Menu Bar) | iOS (Widget) |
|---|---|---|
| **Battery %** | ✅ Real-time in menu bar | ✅ Home & Lock Screen |
| **Remaining time** | ✅ Select instead of percentage | — |
| **Battery icon** | ✅ SF Symbol, adapts to level | ✅ SF Symbol, color-coded |
| **Charging indicator** | ✅ Bolt icon + status | ✅ Bolt icon + label |
| **Details dropdown** | ✅ Time remaining, cycle count, health | — |
| **Lock Screen** | — | ✅ Circular, inline, rectangular |
| **Update mechanism** | IOKit kernel notifications + 60 s fallback | WidgetKit timeline (15 min) |
| **Memory footprint** | ~2 MB | Widget extension process |
| **Binary size** | ~200 KB | Standard .appex |

---

## macOS — Menu Bar App

### Quick Install

```bash
git clone https://github.com/imunishsoni/BatteryPercentage.git
cd BatteryPercentage
make install
```

This compiles the native binary and copies `BatteryMenuBar.app` to `/Applications/`.

### Build Only

```bash
make build    # → ./BatteryMenuBar (standalone binary)
make bundle   # → ./BatteryMenuBar.app (proper .app bundle)
```

### Choose the Menu Bar Display

Click the battery icon and select **Show Percentage** (the default) or **Show Remaining Time**.
The selected option is checked, updates immediately, and is remembered after quitting the app.
Time mode shows estimated battery life, or time until full while charging. It shows
“Calculating…” when macOS has no estimate, and “Full” or “Plugged In” when connected
without charging. Hover over the menu bar item for the full status and time details.

### How It Works

The macOS app is a **single Swift file** (`macOS/BatteryMenuBar.swift`) that:

1. Queries the kernel's power subsystem via **IOKit** (`IOPSCopyPowerSourcesInfo`) — the lowest-level public API for battery data on macOS
2. Registers an **IOPSNotificationCreateRunLoopSource** callback so the display updates the instant the kernel reports a change (plug/unplug, charge level)
3. Runs a 60-second fallback timer as a safety net
4. Displays the selected percentage or remaining time + an SF Symbol battery icon in the **system menu bar**
5. Shows a dropdown with: status, time remaining, cycle count, and battery health

The binary compiles with `swiftc -O` — a single LLVM pass produces optimised native machine code. No frameworks are embedded; Cocoa and IOKit are dynamically linked from the system.

### Start at Login

**System Settings → General → Login Items** → add `BatteryMenuBar.app`.

### Uninstall

```bash
make uninstall
```

---

## iOS — Home Screen & Lock Screen Widget

### Prerequisites

- Xcode 15+ with iOS 17+ SDK
- A physical device or simulator

### Generate Xcode Project

Since `.xcodeproj` is a generated artifact, this repo includes a lightweight Swift script instead:

```bash
cd BatteryPercentage
swift generate_xcodeproj.swift
open BatteryPercentage.xcodeproj
```

### Build & Run

1. Open the generated `BatteryPercentage.xcodeproj` in Xcode
2. Select the **BatteryPercentage** scheme and your device
3. Build & Run (⌘R)
4. Long-press your Home Screen → tap **+** → search **Battery** → add the widget

### Supported Widget Families

| Family | Location | Display |
|---|---|---|
| `systemSmall` | Home Screen | Large icon + percentage |
| `accessoryCircular` | Lock Screen | Circular gauge |
| `accessoryInline` | Lock Screen | Icon + "85%" inline text |
| `accessoryRectangular` | Lock Screen | Icon + percentage + status |

### Note on Update Frequency

iOS widgets refresh on a system-managed timeline. This widget requests a 15-minute refresh interval, but the system may adjust this based on battery life, usage patterns, and other factors. The host app displays real-time battery info when opened.

---

## Project Structure

```
BatteryPercentage/
├── Makefile                         # macOS build (make build / make install)
├── generate_xcodeproj.swift         # Generates iOS Xcode project
├── macOS/
│   ├── BatteryMenuBar.swift         # Complete macOS menu bar app (single file)
│   └── Info.plist                   # App bundle metadata
├── iOS/
│   ├── App/
│   │   ├── BatteryPercentageApp.swift
│   │   ├── ContentView.swift
│   │   └── Info.plist
│   └── Widget/
│       ├── BatteryWidget.swift      # WidgetKit extension
│       └── Info.plist
└── Resources/
    └── Assets.xcassets/
```

## Requirements

| Platform | Minimum |
|---|---|
| macOS | 11.0 (Big Sur) |
| iOS | 17.0 |
| Swift | 5.9+ |
| Xcode | 15.0+ (iOS only) |

## License

[MIT](LICENSE)
