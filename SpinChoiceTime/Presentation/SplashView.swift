import SwiftUI
import WebKit
import Combine

struct SplashView: View {
    
    @StateObject private var viewModel = SpinChoiceTimeViewModel()
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if viewModel.currentSpinPhase == .setup || viewModel.displayPermissionView {
                SplashLoadView()
            }
            
            if viewModel.displayPermissionView {
                CheckPermissionsView(
                    onAllow: viewModel.handleGrantPermissions,
                    onSkip: viewModel.handleSkipPermissions
                )
            } else {
                switch viewModel.currentSpinPhase {
                case .setup:
                    EmptyView()
                    
                case .operational:
                    if viewModel.spinURL != nil {
                        FishTrackMainView()
                    } else {
                        ContentView()
                    }
                    
                case .legacy:
                    ContentView()
                    
                case .disconnected:
                    SpinChoiceIssueInternetView()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
}

struct SplashLoadView: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            ZStack {
                Color.themeGradient("Neon Mix")
                    .ignoresSafeArea()
                
                Image(isLandscape ? "loading_app_back_land" : "loading_app_back")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .ignoresSafeArea()
                
                VStack {
                    Text("Spin Choice Time")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .neonYellow, radius: 10)
                        .tracking(2)
                    
                    Text("Loading...")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .neonYellow, radius: 10)
                        .tracking(2)
                }
                .overlay(ConfettiView().opacity(0.3))
                
                VStack {
                    Spacer()
                    WheelView(wheel: Wheel(id: UUID(), name: "", category: "", colorTheme: "Neon Mix", options: Array(repeating: "", count: 8)), size: 100, selectorVisible: false, rotation: $rotation, isSpinning: .constant(true))
                        .onAppear {
                            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                                rotation = 360 * 10
                            }
                        }
                        .padding(.bottom, 52)
                }
                
            }
        }
        .ignoresSafeArea()
    }
}

struct SpinChoiceIssueInternetView: View {
    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            ZStack {
                Image(isLandscape ? "issue_internet_bg_land" : "issue_internet_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .ignoresSafeArea()
                
                Image("internet_issue_alert")
                    .resizable()
                    .frame(width: 270, height: 210)
            }
        }
        .ignoresSafeArea()
    }
}

struct CheckPermissionsView: View {
    let onAllow: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            ZStack {
                Image(isLandscape ? "push_bg_land" : "push_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .ignoresSafeArea()
                
                VStack(spacing: isLandscape ? 5 : 10) {
                    Spacer()
                    
                    Text("Allow notifications about bonuses and promos".uppercased())
                        .font(.custom("CherryBombOne-Regular", size: 20))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Stay tuned with best offers from our casino")
                        .font(.custom("CherryBombOne-Regular", size: 17))
                        .foregroundColor(Color.init(red: 186/255, green: 186/255, blue: 186/255))
                        .padding(.horizontal, 52)
                        .multilineTextAlignment(.center)
                    
                    Button(action: onAllow) {
                        Image("accept_btn")
                            .resizable()
                            .frame(height: 60)
                    }
                    .frame(width: 350)
                    .padding(.top, 12)
                    
                    Button(action: onSkip) {
                        Text("Skip")
                            .font(.custom("CherryBombOne-Regular", size: 17))
                            .foregroundColor(Color.init(red: 186/255, green: 186/255, blue: 186/255))
                    }
                    .frame(width: 50)
                    
                    Spacer()
                        .frame(height: isLandscape ? 30 : 50)
                }
                .padding(.horizontal, isLandscape ? 20 : 0)
            }
        }
        .ignoresSafeArea()
    }
}

struct FishTrackMainView: View {
    
    @State private var activeSpotLink: String? = nil
    
    var body: some View {
        ZStack {
            if let activeSpotLink = activeSpotLink {
                if let spotLink = URL(string: activeSpotLink) {
                    SpinChoiceTimeMainHost(main: spotLink)
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear(perform: configureSpotLink)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LoadTempUrl"))) { _ in
            if let tempSpot = UserDefaults.standard.string(forKey: "temp_url"), !tempSpot.isEmpty {
                activeSpotLink = nil
                activeSpotLink = tempSpot
                UserDefaults.standard.removeObject(forKey: "temp_url")
            }
        }
    }
    
    private func configureSpotLink() {
        let tempSpot = UserDefaults.standard.string(forKey: "temp_url")
        let storedSpot = UserDefaults.standard.string(forKey: "stored_path") ?? ""
        activeSpotLink = tempSpot ?? storedSpot
        
        if tempSpot != nil {
            UserDefaults.standard.removeObject(forKey: "temp_url")
        }
    }
}
