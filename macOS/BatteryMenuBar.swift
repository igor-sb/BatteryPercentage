//  BatteryMenuBar.swift
//  Lightweight macOS menu bar battery percentage and remaining time display.
//
//  Build:  swiftc -O -framework Cocoa -framework IOKit BatteryMenuBar.swift -o BatteryMenuBar
//  The compiled binary is a single ~200 KB native ARM64/x86_64 executable — zero dependencies.
//
//  Copyright © 2024 BatteryPercentage Contributors. MIT License.

import Cocoa
import IOKit.ps

// ──────────────────────────────────────────────
// MARK: - IOKit Power Source Callback (C-convention)
// ──────────────────────────────────────────────

/// Called by the kernel whenever any power source property changes (charge level,
/// AC adapter state, etc.).  The run-loop source is added to CFRunLoopGetMain(),
/// so this fires on the main thread — safe to touch AppKit from here.
private func powerSourceDidChange(_ context: UnsafeMutableRawPointer?) {
    guard let ctx = context else { return }
    let app = Unmanaged<BatteryApp>.fromOpaque(ctx).takeUnretainedValue()
    app.refreshBattery()
}

// ──────────────────────────────────────────────
// MARK: - Battery Reading (IOKit — kernel level)
// ──────────────────────────────────────────────

struct BatteryReading {
    let percentage: Int          // 0–100
    let isCharging: Bool
    let isPluggedIn: Bool
    let minutesToEmpty: Int      // -1 while calculating
    let minutesToFull: Int       // -1 while calculating
    let cycleCount: Int
    let healthPercent: Int       // maxCapacity / designCapacity × 100

    // ── Read from IOKit ────────────────────────

    static func read() -> BatteryReading? {
        // 1. Basic info from IOPSCopyPowerSourcesInfo (public API)
        let blob = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let list = IOPSCopyPowerSourcesList(blob).takeRetainedValue() as Array

        guard !list.isEmpty else { return nil }

        var pct = 0, charging = false, pluggedIn = false
        var minsEmpty = -1, minsFull = -1

        for src in list {
            guard let desc = IOPSGetPowerSourceDescription(blob, src)?
                    .takeUnretainedValue() as? [String: Any],
                  let type = desc[kIOPSTypeKey] as? String,
                  type == kIOPSInternalBatteryType else { continue }

            let cur = desc[kIOPSCurrentCapacityKey] as? Int ?? 0
            let max = desc[kIOPSMaxCapacityKey]     as? Int ?? 100
            pct        = max > 0 ? cur * 100 / max : 0
            charging   = desc[kIOPSIsChargingKey] as? Bool ?? false
            pluggedIn  = (desc[kIOPSPowerSourceStateKey] as? String) == kIOPSACPowerValue
            minsEmpty  = desc[kIOPSTimeToEmptyKey]        as? Int ?? -1
            minsFull   = desc[kIOPSTimeToFullChargeKey]   as? Int ?? -1
        }

        // 2. Extended info from AppleSmartBattery (IORegistry)
        var cycles = 0, health = 100
        let service = IOServiceGetMatchingService(0, IOServiceMatching("AppleSmartBattery"))
        if service != IO_OBJECT_NULL {
            defer { IOObjectRelease(service) }

            func intProperty(_ key: String) -> Int? {
                IORegistryEntryCreateCFProperty(service, key as CFString, nil, 0)?
                    .takeRetainedValue() as? Int
            }
            cycles = intProperty("CycleCount")    ?? 0
            let design = intProperty("DesignCapacity") ?? 0
            let maxCap = intProperty("MaxCapacity")    ?? 0
            if design > 0 { health = maxCap * 100 / design }
        }

        return BatteryReading(
            percentage:     pct,
            isCharging:     charging,
            isPluggedIn:    pluggedIn,
            minutesToEmpty: minsEmpty,
            minutesToFull:  minsFull,
            cycleCount:     cycles,
            healthPercent:  health
        )
    }

    // ── Derived display helpers ────────────────

    var sfSymbol: String {
        if isCharging { return "battery.100.bolt" }
        switch percentage {
        case 75...100: return "battery.100"
        case 50..<75:  return "battery.75"
        case 25..<50:  return "battery.50"
        case 10..<25:  return "battery.25"
        default:       return "battery.0"
        }
    }

    var statusText: String {
        if isCharging  { return "Charging" }
        if isPluggedIn { return percentage >= 100 ? "Plugged In — Full" : "Plugged In — Not Charging" }
        return "On Battery"
    }

    /// Compact estimate for the menu bar; macOS may not have an estimate yet.
    var menuBarTimeText: String {
        if isPluggedIn && !isCharging {
            return percentage >= 100 ? "Full" : "Plugged In"
        }
        let minutes = isCharging ? minutesToFull : minutesToEmpty
        guard minutes >= 0 else { return "Calculating…" }
        if isCharging && minutes == 0 { return "Full" }
        return format(minutes: minutes)
    }

    var timeText: String {
        if isPluggedIn && !isCharging {
            return percentage >= 100 ? "Fully Charged" : "Not Charging"
        }
        if isCharging {
            guard minutesToFull >= 0 else { return "Calculating…" }
            if minutesToFull == 0 { return "Fully Charged" }
            return format(minutes: minutesToFull) + " until full"
        } else {
            guard minutesToEmpty >= 0 else { return "Calculating…" }
            return format(minutes: minutesToEmpty) + " remaining"
        }
    }

    private func format(minutes m: Int) -> String {
        let h = m / 60, r = m % 60
        if h > 0 && r > 0 { return "\(h) hr \(r) min" }
        if h > 0           { return "\(h) hr" }
        return "\(r) min"
    }
}

// ──────────────────────────────────────────────
// MARK: - Application Delegate
// ──────────────────────────────────────────────

final class BatteryApp: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!
    private var runLoopSource: CFRunLoopSource?
    private var fallbackTimer: Timer?

    private enum DisplayMode: String {
        case percentage
        case remainingTime
    }

    private static let hideBatteryIconKey = "hideBatteryIcon"
    private var hideBatteryIcon = UserDefaults.standard.bool(forKey: hideBatteryIconKey)

    private static let displayModeKey = "menuBarDisplayMode"
    private var displayMode = DisplayMode(
        rawValue: UserDefaults.standard.string(forKey: displayModeKey) ?? ""
    ) ?? .percentage

    private let percentageMenuItem = NSMenuItem(
        title: "Show Percentage", action: #selector(selectPercentage), keyEquivalent: ""
    )
    private let remainingTimeMenuItem = NSMenuItem(
        title: "Show Remaining Time", action: #selector(selectRemainingTime), keyEquivalent: ""
    )

    private let showBatteryIconMenuItem = NSMenuItem(
        title: "Show Battery Icon", action: #selector(toggleBatteryIcon), keyEquivalent: ""
    )

    // Dynamic menu items
    private let statusMenuItem = NSMenuItem(title: "—", action: nil, keyEquivalent: "")
    private let timeMenuItem   = NSMenuItem(title: "—", action: nil, keyEquivalent: "")
    private let cycleMenuItem  = NSMenuItem(title: "—", action: nil, keyEquivalent: "")
    private let healthMenuItem = NSMenuItem(title: "—", action: nil, keyEquivalent: "")

    // ── Lifecycle ──────────────────────────────

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)          // hide from Dock
        buildStatusItem()
        registerPowerSourceNotifications()

        // Safety-net timer: refresh every 60 s in case a kernel notification is missed
        fallbackTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.refreshBattery()
        }

        refreshBattery()
    }

    func applicationWillTerminate(_ notification: Notification) {
        fallbackTimer?.invalidate()
        if let src = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), src, .defaultMode)
        }
    }

    // ── Status Bar Setup ───────────────────────

    private func buildStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        let menu = NSMenu()

        statusMenuItem.isEnabled = false
        timeMenuItem.isEnabled   = false
        cycleMenuItem.isEnabled  = false
        healthMenuItem.isEnabled = false

        menu.addItem(statusMenuItem)
        menu.addItem(timeMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(cycleMenuItem)
        menu.addItem(healthMenuItem)
        menu.addItem(NSMenuItem.separator())
        percentageMenuItem.target = self
        remainingTimeMenuItem.target = self
        menu.addItem(percentageMenuItem)
        menu.addItem(remainingTimeMenuItem)
        updateDisplayModeMenu()
        showBatteryIconMenuItem.target = self
        showBatteryIconMenuItem.state = hideBatteryIcon ? .off : .on
        menu.addItem(showBatteryIconMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit BatteryMenuBar",
                                action: #selector(NSApp.terminate(_:)),
                                keyEquivalent: "q"))
        statusItem.menu = menu
    }

    @objc private func selectPercentage() {
        setDisplayMode(.percentage)
    }

    @objc private func selectRemainingTime() {
        setDisplayMode(.remainingTime)
    }

    @objc private func toggleBatteryIcon() {
        hideBatteryIcon.toggle()
        UserDefaults.standard.set(hideBatteryIcon, forKey: Self.hideBatteryIconKey)
        showBatteryIconMenuItem.state = hideBatteryIcon ? .off : .on
        refreshBattery()
    }

    private func setDisplayMode(_ mode: DisplayMode) {
        displayMode = mode
        UserDefaults.standard.set(mode.rawValue, forKey: Self.displayModeKey)
        updateDisplayModeMenu()
        refreshBattery()
    }

    private func updateDisplayModeMenu() {
        percentageMenuItem.state = displayMode == .percentage ? .on : .off
        remainingTimeMenuItem.state = displayMode == .remainingTime ? .on : .off
    }

    // ── IOKit Notification Registration ────────

    private func registerPowerSourceNotifications() {
        let ctx = Unmanaged.passUnretained(self).toOpaque()
        guard let src = IOPSNotificationCreateRunLoopSource(
            powerSourceDidChange, ctx
        )?.takeRetainedValue() else { return }

        CFRunLoopAddSource(CFRunLoopGetMain(), src, .defaultMode)
        runLoopSource = src
    }

    // ── Refresh Display ────────────────────────

    @objc func refreshBattery() {
        guard let b = BatteryReading.read() else {
            statusItem.button?.title = "  No Battery"
            statusItem.button?.image = nil
            return
        }

        // Menu bar button: icon + selected battery display
        if let button = statusItem.button {
            button.image = nil
            button.imagePosition = hideBatteryIcon ? .noImage : .imageLeading
            if !hideBatteryIcon, #available(macOS 11.0, *) {
                let cfg = NSImage.SymbolConfiguration(pointSize: 14, weight: .regular)
                button.image = NSImage(
                    systemSymbolName: b.sfSymbol,
                    accessibilityDescription: "Battery"
                )?.withSymbolConfiguration(cfg)
                button.imagePosition = .imageLeading
            }
            let text = displayMode == .percentage ? "\(b.percentage)%" : b.menuBarTimeText
            button.title = button.image == nil ? text : " \(text)"
            button.toolTip = "\(b.statusText) — \(b.percentage)%\n\(b.timeText)"
            button.font  = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        }

        // Drop-down details
        statusMenuItem.title = "\(b.statusText) — \(b.percentage)%"
        timeMenuItem.title   = b.timeText
        cycleMenuItem.title  = "Cycle Count:    \(b.cycleCount)"
        healthMenuItem.title = "Battery Health: \(b.healthPercent)%"
    }
}

// ──────────────────────────────────────────────
// MARK: - Entry Point
// ──────────────────────────────────────────────

let app = NSApplication.shared
let delegate = BatteryApp()
app.delegate = delegate
app.run()
