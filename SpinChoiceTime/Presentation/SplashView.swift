import SwiftUI

struct SplashView: View {
    @State private var rotation: Double = 0
    @Binding var showSplash: Bool
    
    var body: some View {
        ZStack {
            Color.themeGradient("Purple-Blue")
                .ignoresSafeArea()
            
            VStack {
                WheelView(wheel: Wheel(id: UUID(), name: "", category: "", colorTheme: "Purple-Blue", options: ["", "", "", ""]), size: 200, rotation: $rotation, isSpinning: .constant(false))
                    .onAppear {
                        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }
                
                Text("Spin Choice Time")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .shadow(color: .neonYellow.opacity(0.5), radius: 5)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSplash = false
                }
            }
        }
    }
}
