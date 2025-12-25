import SwiftUI
import WebKit

struct HomeView: View {
    @ObservedObject var appData: AppData
    @State private var showingCreate = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.themeGradient(appData.appTheme)
                    .ignoresSafeArea()
                
                VStack {
                    Text("Your Wheels")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .neonPurple, radius: 10)
                    
                    Button(action: { showingCreate = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.neonYellow)
                            .padding(20)
                            .background(Circle().fill(Color.futuristicGray.opacity(0.5)).blur(radius: 5))
                            .shadow(color: .neonYellow, radius: 15)
                    }
                    .sheet(isPresented: $showingCreate) {
                        CreateWheelView(appData: appData)
                    }
                    
                    List(appData.wheels) { wheel in
                        NavigationLink(destination: WheelScreenView(appData: appData, wheel: wheel)) {
                            WheelCard(wheel: wheel)
                        }
                        .listRowBackground(Color.clear)
                        .transition(.scale.combined(with: .opacity))
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                }
            }
            .navigationBarHidden(true)
        }
    }
}


class SchoiceNavigationHandlerView: NSObject, WKNavigationDelegate, WKUIDelegate {
    
    private var navigationCounter = 0
    
    init(manager: ChoiceAppManager) {
        self.choiceManagerApp = manager
        super.init()
    }
    
    private func preserveData(from webView: WKWebView) {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            var dataCollection: [String: [String: [HTTPCookiePropertyKey: Any]]] = [:]
            
            for cookie in cookies {
                var group = dataCollection[cookie.domain] ?? [:]
                if let attrs = cookie.properties {
                    group[cookie.name] = attrs
                }
                dataCollection[cookie.domain] = group
            }
            
            UserDefaults.standard.set(dataCollection, forKey: "preserved_grains")
        }
    }
    
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for action: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard action.targetFrame == nil else { return nil }
        
        let freshView = WKWebView(frame: .zero, configuration: configuration)
        configFreshView(freshView)
        setConstraintsFor(freshView)
        
        choiceManagerApp.managerAppAdditionalAPps.append(freshView)
        
        let panRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(managePanGesture))
        panRecognizer.edges = .left
        freshView.addGestureRecognizer(panRecognizer)
        
        func validateActionRequest(_ request: URLRequest) -> Bool {
            guard let pathString = request.url?.absoluteString,
                  !pathString.isEmpty,
                  pathString != "about:blank" else { return false }
            return true
        }
        
        if validateActionRequest(action.request) {
            freshView.load(action.request)
        }
        
        return freshView
    }
    
    
    private var choiceManagerApp: ChoiceAppManager
    
    
    @objc private func managePanGesture(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        guard recognizer.state == .ended,
              let viewUnderGesture = recognizer.view as? WKWebView else { return }
        
        if viewUnderGesture.canGoBack {
            viewUnderGesture.goBack()
        } else if choiceManagerApp.managerAppAdditionalAPps.last === viewUnderGesture {
            choiceManagerApp.backAppChoice(to: nil)
        }
    }

    private var previousPath: URL?
    
    private let navigationCap = 70
    
    func webView(_ webView: WKWebView,
                 didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let trustValue = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trustValue))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let adjustmentCode = """
        (function() {
            const vpTag = document.createElement('meta');
            vpTag.name = 'viewport';
            vpTag.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            document.head.appendChild(vpTag);
            
            const styleTag = document.createElement('style');
            styleTag.textContent = 'body { touch-action: pan-x pan-y; } input, textarea { font-size: 16px !important; }';
            document.head.appendChild(styleTag);
            
            document.addEventListener('gesturestart', function(e) { e.preventDefault(); });
            document.addEventListener('gesturechange', function(e) { e.preventDefault(); });
        })();
        """
        
        webView.evaluateJavaScript(adjustmentCode) { _, err in
            if let err = err { print("Adjustment failed: \(err)") }
        }
    }
    private func configFreshView(_ webView: WKWebView) {
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.bounces = false
        webView.scrollView.bouncesZoom = false
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        webView.uiDelegate = self
        choiceManagerApp.choiceMainView.addSubview(webView)
    }
    
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        if (error as NSError).code == NSURLErrorHTTPTooManyRedirects,
           let fallbackPath = previousPath {
            webView.load(URLRequest(url: fallbackPath))
        }
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        navigationCounter += 1
        
        if navigationCounter > navigationCap {
            webView.stopLoading()
            if let fallbackPath = previousPath {
                webView.load(URLRequest(url: fallbackPath))
            }
            return
        }
        
        previousPath = webView.url
        preserveData(from: webView)
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let path = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        previousPath = path
        
        let pathScheme = (path.scheme ?? "").lowercased()
        let pathString = path.absoluteString.lowercased()
        
        let allowedSchemes: Set<String> = ["http", "https", "about", "blob", "data", "javascript", "file"]
        let allowedStarts = ["srcdoc", "about:blank", "about:srcdoc"]
        
        let isAllowed = allowedSchemes.contains(pathScheme) ||
        allowedStarts.contains { pathString.hasPrefix($0) } ||
        pathString == "about:blank"
        
        if isAllowed {
            decisionHandler(.allow)
            return
        }
        
        UIApplication.shared.open(path, options: [:]) { _ in }
        
        decisionHandler(.cancel)
    }
    
    private func setConstraintsFor(_ webView: WKWebView) {
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: choiceManagerApp.choiceMainView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: choiceManagerApp.choiceMainView.trailingAnchor),
            webView.topAnchor.constraint(equalTo: choiceManagerApp.choiceMainView.topAnchor),
            webView.bottomAnchor.constraint(equalTo: choiceManagerApp.choiceMainView.bottomAnchor)
        ])
    }
}


struct WheelCard: View {
    let wheel: Wheel
    @State private var hoverScale: CGFloat = 1.0
    
    var body: some View {
        HStack {
            Image(systemName: "gearshape.circle.fill")
                .foregroundColor(.neonBlue)
                .font(.system(size: 50))
                .shadow(color: .neonBlue, radius: 10)
            
            VStack(alignment: .leading) {
                Text(wheel.name)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("\(wheel.options.count) options")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.glowWhite)
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.futuristicGray.opacity(0.4).cornerRadius(20).blur(radius: 5))
        .shadow(color: .neonPurple.opacity(0.6), radius: 15)
        .scaleEffect(hoverScale)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                hoverScale = 1.05
            }
        }
    }
}
