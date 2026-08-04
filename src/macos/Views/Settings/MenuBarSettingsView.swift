import SwiftUI

struct MenuBarSettingsView: View {
    @State private var padding: Int = MenuBarSpacing.appleDefaultsPadding
    @State private var spacing: Int = MenuBarSpacing.appleDefaultsSpacing
    @State private var isAppleDefault: Bool = true
    @State private var debounceTask: Task<Void, Never>?
    @State private var lastAppliedPadding: Int = MenuBarSpacing.appleDefaultsPadding
    @State private var lastAppliedSpacing: Int = MenuBarSpacing.appleDefaultsSpacing

    var body: some View {
        Form {
            Section {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Modifie un réglage caché de macOS")
                            .font(.subheadline.weight(.semibold))
                        Text("L'espacement est appliqué en direct pendant le drag (relance ControlCenter, ~300 ms de debounce). Ça peut interrompre un AirDrop ou un screen share en cours. Totalement réversible via « Restaurer défauts Apple ».")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                }
            }

            Section("Padding interne") {
                HStack(spacing: 12) {
                    Slider(value: Binding(
                        get: { Double(padding) },
                        set: { padding = Int($0.rounded()) }
                    ), in: Double(MenuBarSpacing.minPadding)...Double(MenuBarSpacing.maxPadding))
                    Stepper(value: Binding(
                        get: { padding },
                        set: { padding = $0 }
                    ), in: MenuBarSpacing.minPadding...MenuBarSpacing.maxPadding) {
                        Text("\(padding) px").monospacedDigit()
                            .frame(width: 60, alignment: .trailing).foregroundStyle(.secondary)
                    }
                }
                Text("Espace à l'intérieur de chaque item de la menu bar (autour de l'icône).")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("Espacement entre items") {
                HStack(spacing: 12) {
                    Slider(value: Binding(
                        get: { Double(spacing) },
                        set: { spacing = Int($0.rounded()) }
                    ), in: Double(MenuBarSpacing.minSpacing)...Double(MenuBarSpacing.maxSpacing))
                    Stepper(value: Binding(
                        get: { spacing },
                        set: { spacing = $0 }
                    ), in: MenuBarSpacing.minSpacing...MenuBarSpacing.maxSpacing) {
                        Text("\(spacing) px").monospacedDigit()
                            .frame(width: 60, alignment: .trailing).foregroundStyle(.secondary)
                    }
                }
                Text("Espace entre chaque item (icône système, apps tierces). Plus c'est petit, plus tu gagnes de place.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("État") {
                HStack(spacing: 12) {
                    if isAppleDefault {
                        Label("Configuration Apple par défaut", systemImage: "checkmark.seal.fill")
                            .font(.caption.weight(.medium)).foregroundStyle(.green)
                    } else {
                        Label("Configuration personnalisée", systemImage: "circle.dashed")
                            .font(.caption.weight(.medium)).foregroundStyle(.orange)
                    }
                    Spacer()
                    Button {
                        padding = MenuBarSpacing.appleDefaultsPadding
                        spacing = MenuBarSpacing.appleDefaultsSpacing
                        MenuBarSpacing.reset()
                        lastAppliedPadding = MenuBarSpacing.appleDefaultsPadding
                        lastAppliedSpacing = MenuBarSpacing.appleDefaultsSpacing
                        isAppleDefault = true
                    } label: {
                        Label("Restaurer défauts Apple", systemImage: "arrow.uturn.backward")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .formStyle(.grouped)
        .onAppear(perform: readCurrent)
        .onChange(of: padding) { _ in scheduleApply() }
        .onChange(of: spacing) { _ in scheduleApply() }
    }

    private func readCurrent() {
        if let p = MenuBarSpacing.readPadding() {
            padding = p
            lastAppliedPadding = p
        }
        if let s = MenuBarSpacing.readSpacing() {
            spacing = s
            lastAppliedSpacing = s
        }
        updateIsAppleDefault()
    }

    private func scheduleApply() {
        updateIsAppleDefault()
        debounceTask?.cancel()
        let p = padding
        let s = spacing
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            if Task.isCancelled { return }
            guard p != lastAppliedPadding || s != lastAppliedSpacing else { return }
            await MainActor.run {
                MenuBarSpacing.write(padding: p, spacing: s)
                lastAppliedPadding = p
                lastAppliedSpacing = s
            }
        }
    }

    private func updateIsAppleDefault() {
        isAppleDefault = (padding == MenuBarSpacing.appleDefaultsPadding && spacing == MenuBarSpacing.appleDefaultsSpacing)
    }
}
