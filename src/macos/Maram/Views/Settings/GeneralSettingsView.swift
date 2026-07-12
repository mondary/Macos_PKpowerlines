import SwiftUI

struct GeneralSettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                monitorSection
                aboutSection
            }
            .padding(24)
        }
    }

    private var monitorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Source affichée")
                .font(.headline)

            Picker("Source", selection: $settings.monitorType) {
                ForEach(MonitorType.allCases) { type in
                    Label(type.displayName, systemImage: type.icon).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(maxWidth: .infinity)

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle")
                    .foregroundStyle(.secondary)
                Text(settings.monitorType.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            previewCard
        }
    }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Aperçu")
                .font(.subheadline.weight(.medium))
            PreviewBar(settings: settings)
                .frame(height: 14)
                .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("À propos")
                .font(.headline)
            Text("Maram affiche une barre en temps réel en haut de chaque écran. Le mode se change à tout moment depuis les réglages ou la barre des menus.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct PreviewBar: View {
    @ObservedObject var settings: AppSettings
    private let monitor = RAMMonitor()
    private let battery = BatteryMonitor()
    @State private var percentage: Double = 0
    @State private var color: Color = .red
    @State private var label = "0%"

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Color(NSColor.darkGray)
                Rectangle()
                    .fill(color)
                    .frame(width: geo.size.width * percentage / 100)
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.leading, 8)
            }
        }
        .onAppear { refresh() }
        .onChange(of: settings.monitorType) { _ in refresh() }
        .onReceive(Timer.publish(every: 2, on: .main, in: .common).autoconnect()) { _ in refresh() }
    }

    private func refresh() {
        switch settings.monitorType {
        case .ram:
            let u = monitor.getRAMUsage()
            percentage = u.usedPercentage
            color = .red
            label = "\(Int(u.usedPercentage))%"
        case .battery:
            let b = battery.getBatteryUsage()
            guard b.percentage >= 0 else {
                percentage = 0
                color = .gray
                label = "Pas de batterie"
                return
            }
            percentage = b.percentage
            color = b.isCharging ? .blue : (b.percentage < 20 ? .red : .green)
            label = (b.isCharging ? "⚡ " : "") + "\(Int(b.percentage))%"
        }
    }
}
