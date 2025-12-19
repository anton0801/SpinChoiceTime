import SwiftUI

struct SettingsView: View {
    @ObservedObject var appData: AppData
    
    var body: some View {
        ZStack {
            Color.themeGradient("Purple-Blue")
                .ignoresSafeArea()
            
            Form {
                Section(header: Text("Preferences").foregroundColor(.white)) {
                    Toggle("Sound ON/OFF", isOn: $appData.soundEnabled)
                    Picker("Animation speed", selection: $appData.animationSpeed) {
                        Text("Slow").tag(0.5)
                        Text("Normal").tag(1.0)
                        Text("Fast").tag(2.0)
                    }
                    Picker("Theme", selection: $appData.appTheme) {
                        Text("Default").tag("Default")
                        Text("Dark").tag("Dark") // Placeholder, can expand
                    }
                }
                
                Section(header: Text("Data").foregroundColor(.white)) {
                    Button("Reset data") {
                        appData.resetData()
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("About").foregroundColor(.white)) {
                    Text("Spin Choice Time v1.0")
                    Text("Privacy: All data stored locally.")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .navigationTitle("Settings")
        .onChange(of: appData.soundEnabled) { _ in appData.saveData() }
        .onChange(of: appData.animationSpeed) { _ in appData.saveData() }
        .onChange(of: appData.appTheme) { _ in appData.saveData() }
    }
}
