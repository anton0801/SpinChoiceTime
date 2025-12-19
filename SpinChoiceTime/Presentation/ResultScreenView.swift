import SwiftUI

struct ResultScreenView: View {
    @ObservedObject var appData: AppData
    let wheel: Wheel
    let selectedOption: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.themeGradient(wheel.colorTheme)
                .ignoresSafeArea()
            
            ConfettiView()
            
            VStack {
                Text("Your choice is:")
                    .font(.title)
                    .foregroundColor(.white)
                
                Text(selectedOption)
                    .font(.largeTitle.bold())
                    .foregroundColor(.neonYellow)
                    .shadow(color: .neonYellow.opacity(0.5), radius: 5)
                
                HStack {
                    Button("Spin again") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(10)
                    
                    Button("Mark as done") {
                        // Optional: Could remove or mark, but for now just dismiss
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(10)
                    
                    Button("Back to wheel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(10)
                }
            }
        }
    }
}
