//  ContentView.swift
//  Battery status display and widget onboarding.
//
//  Copyright © 2024 BatteryPercentage Contributors. MIT License.

import SwiftUI

struct ContentView: View {

    @State private var batteryLevel: Float = -1
    @State private var batteryState: UIDevice.BatteryState = .unknown

    // ── Derived properties ─────────────────────

    private var percentage: Int {
        batteryLevel >= 0 ? Int(batteryLevel * 100) : 0
    }

    private var isCharging: Bool {
        batteryState == .charging || batteryState == .full
    }

    private var iconName: String {
        if isCharging { return "battery.100.bolt" }
        switch percentage {
        case 75...100: return "battery.100"
        case 50..<75:  return "battery.75"
        case 25..<50:  return "battery.50"
        case 10..<25:  return "battery.25"
        default:       return "battery.0"
        }
    }

    private var iconColor: Color {
        if isCharging { return .green }
        switch percentage {
        case 20...100: return .green
        case 10..<20:  return .orange
        default:       return .red
        }
    }

    private var stateText: String {
        switch batteryState {
        case .charging:  return "Charging"
        case .full:      return "Fully Charged"
        case .unplugged: return "On Battery"
        default:         return "Unknown"
        }
    }

    // ── Body ───────────────────────────────────

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: iconName)
                .font(.system(size: 72))
                .foregroundStyle(iconColor)
                .contentTransition(.symbolEffect(.replace))

            Text("\(percentage)%")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())

            Text(stateText)
                .font(.title3)
                .foregroundStyle(.secondary)

            Spacer()

            GroupBox {
                Label {
                    Text("Add the **Battery Percentage** widget to your Home Screen or Lock Screen for at-a-glance monitoring.")
                } icon: {
                    Image(systemName: "plus.rectangle.on.rectangle")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            Spacer()
        }
        .onAppear {
            UIDevice.current.isBatteryMonitoringEnabled = true
            batteryLevel = UIDevice.current.batteryLevel
            batteryState = UIDevice.current.batteryState
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIDevice.batteryLevelDidChangeNotification)
        ) { _ in
            batteryLevel = UIDevice.current.batteryLevel
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIDevice.batteryStateDidChangeNotification)
        ) { _ in
            batteryState = UIDevice.current.batteryState
        }
    }
}

#Preview {
    ContentView()
}
