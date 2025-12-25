import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            OnboardingPage(title: "Create your own wheels", icon: "plus.circle.fill", image: "wheel_plus").tag(0)
            OnboardingPage(title: "Add any options you want", icon: "square.grid.3x3.fill", image: "segments").tag(1)
            OnboardingPage(title: "Spin and let fate decide", icon: "arrow.triangle.2.circlepath", image: "arrow_confetti").tag(2)
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .overlay(alignment: .bottom) {
            HStack {
                Button("Skip") {
                    showOnboarding = false
                }
                .buttonStyle(FuturisticButtonStyle())
                
                Spacer()
                
                Button("Next") {
                    if currentPage < 2 {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                }
                .buttonStyle(FuturisticButtonStyle())
                
                if currentPage == 2 {
                    Button("Start") {
                        showOnboarding = false
                    }
                    .buttonStyle(FuturisticButtonStyle())
                }
            }
            .padding()
            .background(Color.futuristicGray.opacity(0.6).blur(radius: 10))
        }
        .background(Color.themeGradient("Purple-Blue").ignoresSafeArea())
        .transition(.opacity.combined(with: .scale))
    }
}

struct OnboardingPage: View {
    let title: String
    let icon: String
    let image: String // Placeholder
    
    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: icon)
                .resizable()
                .frame(width: 120, height: 120)
                .foregroundColor(.neonYellow)
                .shadow(color: .neonYellow, radius: 15)
                .rotationEffect(.degrees(10))
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: UUID())
            
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .shadow(color: .glowWhite, radius: 5)
        }
    }
}

struct FuturisticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.neonBlue.opacity(0.4))
            .cornerRadius(30)
            .shadow(color: .neonBlue, radius: configuration.isPressed ? 20 : 10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
