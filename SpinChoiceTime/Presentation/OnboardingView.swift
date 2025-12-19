import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    
    var body: some View {
        TabView {
            OnboardingPage(title: "Create your own wheels", icon: "plus.circle", image: "wheel_plus")
            OnboardingPage(title: "Add any options you want", icon: "square.grid.2x2", image: "segments")
            OnboardingPage(title: "Spin and let fate decide", icon: "arrow.clockwise", image: "arrow_confetti")
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .overlay(alignment: .bottom) {
            HStack {
                Button("Skip") {
                    showOnboarding = false
                }
                .foregroundColor(.white)
                
                Spacer()
                
                Button("Next") { } // Handled by swipe
                    .foregroundColor(.white)
                
                Button("Start") {
                    showOnboarding = false
                }
                .foregroundColor(.white)
            }
            .padding()
            .background(Color.black.opacity(0.3))
        }
        .background(Color.themeGradient("Purple-Blue").ignoresSafeArea())
    }
}

struct OnboardingPage: View {
    let title: String
    let icon: String
    let image: String // Placeholder for icon/image
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.neonYellow)
                .shadow(color: .neonYellow.opacity(0.5), radius: 10)
            
            Text(title)
                .font(.title.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}
