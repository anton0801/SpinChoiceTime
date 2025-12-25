import SwiftUI

struct ResultScreenView: View {
    @ObservedObject var appData: AppData
    let wheel: Wheel
    let selectedOption: String
    @Environment(\.presentationMode) var presentationMode
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        ZStack {
            Color.themeGradient(wheel.colorTheme)
                .ignoresSafeArea()
            
            ConfettiView()
            
            VStack {
                Text("Your choice is:")
                    .font(.system(size: 28, design: .rounded))
                    .foregroundColor(.glowWhite)
                
                Text(selectedOption)
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundColor(.neonYellow)
                    .shadow(color: .neonYellow, radius: 15)
                    .scaleEffect(scale)
                    .onAppear {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                            scale = 1.0
                        }
                    }
                
                HStack(spacing: 20) {
                    Button("Spin again") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .buttonStyle(FuturisticButtonStyle())
                    
                    Button("Mark as done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .buttonStyle(FuturisticButtonStyle())
                    
                    Button("Back to wheel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .buttonStyle(FuturisticButtonStyle())
                }
            }
        }
    }
}
