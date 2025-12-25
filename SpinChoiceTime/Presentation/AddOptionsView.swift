import SwiftUI
import WebKit
import Combine

struct AddOptionsView: View {
    @ObservedObject var appData: AppData
    let wheel: Wheel
    @State private var newOption: String = ""
    @State private var options: [String] = []
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(options, id: \.self) { option in
                        Text(option)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.futuristicGray.opacity(0.3))
                            .cornerRadius(10)
                    }
                    .onDelete { indices in
                        options.remove(atOffsets: indices)
                    }
                }
                
                HStack {
                    TextField("New option", text: $newOption)
                        .textFieldStyle(FuturisticTextFieldStyle())
                    
                    Button("+ Add option") {
                        if !newOption.isEmpty {
                            options.append(newOption)
                            newOption = ""
                        }
                    }
                    .buttonStyle(FuturisticButtonStyle())
                }
                .padding()
                
                Button("Save Options") {
                    if let index = appData.wheels.firstIndex(where: { $0.id == wheel.id }) {
                        appData.wheels[index].options = options
                        appData.saveData()
                    }
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(FuturisticButtonStyle())
            }
            .background(Color.themeGradient(wheel.colorTheme).ignoresSafeArea())
            .navigationTitle("Add Options")
        }
        .onAppear {
            options = wheel.options
        }
    }
}

class ChoiceAppManager: ObservableObject {
    @Published var choiceMainView: WKWebView!
    
    private var activeCancellables = Set<AnyCancellable>()
    
    private func generateBaseConfig() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        
        
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let prefs = WKPreferences()
        prefs.javaScriptEnabled = true
        prefs.javaScriptCanOpenWindowsAutomatically = true
        config.preferences = prefs
        
        let pagePrefs = WKWebpagePreferences()
        pagePrefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = pagePrefs
        
        return config
    }
    
    private func setViewParameters(on webView: WKWebView) {
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.bounces = false
        webView.scrollView.bouncesZoom = false
        webView.allowsBackForwardNavigationGestures = true
    }
    
    func backAppChoice(to url: URL? = nil) {
        if !managerAppAdditionalAPps.isEmpty {
            if let lastExtra = managerAppAdditionalAPps.last {
                lastExtra.removeFromSuperview()
                managerAppAdditionalAPps.removeLast()
            }
            
            if let targetURL = url {
                choiceMainView.load(URLRequest(url: targetURL))
            }
        } else if choiceMainView.canGoBack {
            choiceMainView.goBack()
        }
    }
    
    func initMainView() {
        let setupConfig = generateBaseConfig()
        choiceMainView = WKWebView(frame: .zero, configuration: setupConfig)
        setViewParameters(on: choiceMainView)
    }
    
    @Published var managerAppAdditionalAPps: [WKWebView] = []
    
    func retrieveCachedSpot() {
        guard let cachedSpot = UserDefaults.standard.object(forKey: "preserved_grains") as? [String: [String: [HTTPCookiePropertyKey: AnyObject]]] else { return }
        
        let spotStore = choiceMainView.configuration.websiteDataStore.httpCookieStore
        let spotItems = cachedSpot.values.flatMap { $0.values }.compactMap {
            HTTPCookie(properties: $0 as [HTTPCookiePropertyKey: Any])
        }
        
        spotItems.forEach { spotStore.setCookie($0) }
    }
    
    func executeRefresh() {
        choiceMainView.reload()
    }
}
