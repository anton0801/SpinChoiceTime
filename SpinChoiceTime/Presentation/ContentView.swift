import SwiftUI

struct ContentView: View {
    @StateObject private var appData = AppData()
    @State private var showOnboarding = false
    
    var body: some View {
        ZStack {
            if appData.isFirstLaunch || showOnboarding {
                OnboardingView(showOnboarding: $showOnboarding)
            } else {
                TabView {
                    HomeView(appData: appData)
                        .tabItem { Label("Home", systemImage: "house") }
                    
                    CategoriesView(appData: appData)
                        .tabItem { Label("Categories", systemImage: "folder") }
                    
                    TemplatesView(appData: appData)
                        .tabItem { Label("Templates", systemImage: "doc.text") }
                    
                    HistoryView(appData: appData)
                        .tabItem { Label("History", systemImage: "clock") }
                    
                    SettingsView(appData: appData)
                        .tabItem { Label("Settings", systemImage: "gear") }
                }
                .accentColor(.neonYellow)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
