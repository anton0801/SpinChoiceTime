import SwiftUI

struct WheelScreenView: View {
    @ObservedObject var appData: AppData
    var wheel: Wheel
    @State private var rotation: Double = 0
    @State private var isSpinning: Bool = false
    @State private var selectedOption: String?
    @State private var showResult: Bool = false
    
    var body: some View {
        ZStack {
            Color.themeGradient(wheel.colorTheme)
                .ignoresSafeArea()
            
            VStack {
                WheelView(wheel: wheel, size: 300, rotation: $rotation, isSpinning: $isSpinning)
                
                if !isSpinning {
                    Button("SPIN") {
                        spinWheel()
                    }
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding(20)
                    .background(Circle().fill(Color.neonYellow).shadow(color: .neonYellow.opacity(0.5), radius: 10))
                }
            }
        }
        .sheet(isPresented: $showResult) {
            ResultScreenView(appData: appData, wheel: wheel, selectedOption: selectedOption ?? "")
        }
    }
    
    private func spinWheel() {
        isSpinning = true
        let randomSpins = Double.random(in: 5...10) * 360
        let segmentCount = Double(wheel.options.count)
        let anglePerSegment = 360 / segmentCount
        let randomSegment = Int.random(in: 0..<wheel.options.count)
        let finalOffset = Double(randomSegment) * anglePerSegment + anglePerSegment / 2
        
        withAnimation(.easeOut(duration: 5 / appData.animationSpeed)) {
            rotation = randomSpins + finalOffset
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5 / appData.animationSpeed) {
            isSpinning = false
            selectedOption = wheel.options[randomSegment]
            showResult = true
            // Add to history
            let historyItem = HistoryItem(id: UUID(), date: Date(), wheelName: wheel.name, selectedOption: selectedOption ?? "")
            appData.history.append(historyItem)
            appData.saveData()
        }
    }
}

