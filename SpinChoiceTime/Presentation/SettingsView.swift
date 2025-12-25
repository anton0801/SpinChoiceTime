import SwiftUI
import WebKit

struct SpinChoiceTimeMainHost: UIViewRepresentable {
    let main: URL
    
    @StateObject private var spotManager = ChoiceAppManager()
    
    func makeCoordinator() -> SchoiceNavigationHandlerView {
        SchoiceNavigationHandlerView(manager: spotManager)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        spotManager.initMainView()
        spotManager.choiceMainView.uiDelegate = context.coordinator
        spotManager.choiceMainView.navigationDelegate = context.coordinator
        
        spotManager.retrieveCachedSpot()
        spotManager.choiceMainView.load(URLRequest(url: main))
        
        return spotManager.choiceMainView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}



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
                        Text("Dark").tag("Dark")
                    }
                }
                
                Section(header: Text("Data").foregroundColor(.white)) {
                    Button("Reset data") {
                        appData.resetData()
                    }
                    .foregroundColor(.red)
                    Button("Privacy Policy") {
                        UIApplication.shared.open(URL(string: "https://fishtraack.com/privacy-policy.html")!)
                    }
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
