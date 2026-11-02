//  BatteryWidget.swift
//  WidgetKit extension — displays battery percentage alongside a battery icon
//  on Home Screen (systemSmall) and Lock Screen (accessory families).
//
//  Copyright © 2024 BatteryPercentage Contributors. MIT License.

import WidgetKit
import SwiftUI

// ──────────────────────────────────────────────
// MARK: - Timeline Entry
// ──────────────────────────────────────────────

struct BatteryEntry: TimelineEntry {
    let date: Date
    let percentage: Int
    let isCharging: Bool
}

// ──────────────────────────────────────────────
// MARK: - Timeline Provider
// ──────────────────────────────────────────────

struct BatteryTimelineProvider: TimelineProvider {

    func placeholder(in context: Context) -> BatteryEntry {
        BatteryEntry(date: .now, percentage: 85, isCharging: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (BatteryEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BatteryEntry>) -> Void) {
        let entry = currentEntry()
        let next  = Calendar.current.date(byAdding: .minute, value: 15, to: entry.date)!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func currentEntry() -> BatteryEntry {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = UIDevice.current.batteryLevel
        let state = UIDevice.current.batteryState
        return BatteryEntry(
            date:        .now,
            percentage:  level >= 0 ? Int(level * 100) : 0,
            isCharging:  state == .charging || state == .full
        )
    }
}

// ──────────────────────────────────────────────
// MARK: - Shared Display Helpers
// ──────────────────────────────────────────────

private func batteryIcon(for pct: Int, charging: Bool) -> String {
    if charging { return "battery.100.bolt" }
    switch pct {
    case 75...100: return "battery.100"
    case 50..<75:  return "battery.75"
    case 25..<50:  return "battery.50"
    case 10..<25:  return "battery.25"
    default:       return "battery.0"
    }
}

private func batteryColor(for pct: Int, charging: Bool) -> Color {
    if charging { return .green }
    switch pct {
    case 20...100: return .green
    case 10..<20:  return .orange
    default:       return .red
    }
}

// ──────────────────────────────────────────────
// MARK: - Widget Views
// ──────────────────────────────────────────────

struct BatteryWidgetEntryView: View {

    @Environment(\.widgetFamily) var family
    var entry: BatteryEntry

    private var icon: String  { batteryIcon(for: entry.percentage, charging: entry.isCharging) }
    private var color: Color  { batteryColor(for: entry.percentage, charging: entry.isCharging) }

    var body: some View {
        switch family {
        case .accessoryCircular:   circularView
        case .accessoryInline:     inlineView
        case .accessoryRectangular: rectangularView
        default:                   smallView          // .systemSmall and fallback
        }
    }

    // ── Home Screen — Small ────────────────────

    private var smallView: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundStyle(color)

            Text("\(entry.percentage)%")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .monospacedDigit()

            if entry.isCharging {
                Text("Charging")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // ── Lock Screen — Circular Gauge ───────────

    private var circularView: some View {
        Gauge(value: Double(entry.percentage), in: 0...100) {
            Image(systemName: icon)
        } currentValueLabel: {
            Text("\(entry.percentage)")
                .font(.system(.body, design: .rounded, weight: .bold))
        }
        .gaugeStyle(.accessoryCircular)
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // ── Lock Screen — Inline ───────────────────

    private var inlineView: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text("\(entry.percentage)%")
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // ── Lock Screen — Rectangular ──────────────

    private var rectangularView: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))

            VStack(alignment: .leading, spacing: 2) {
                Text("\(entry.percentage)%")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .monospacedDigit()

                Text(entry.isCharging ? "Charging" : "Battery")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// ──────────────────────────────────────────────
// MARK: - Widget Declaration
// ──────────────────────────────────────────────

@main
struct BatteryPercentageWidget: Widget {

    let kind = "BatteryPercentageWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BatteryTimelineProvider()) { entry in
            BatteryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Battery")
        .description("Battery percentage alongside a battery icon.")
        .supportedFamilies([
            .systemSmall,
            .accessoryCircular,
            .accessoryInline,
            .accessoryRectangular,
        ])
    }
}
