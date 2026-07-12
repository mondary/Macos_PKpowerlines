import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem { Label("Général", systemImage: "gearshape") }
            AppearanceSettingsView()
                .tabItem { Label("Apparence", systemImage: "paintbrush") }
        }
        .frame(width: 520, height: 380)
    }
}
