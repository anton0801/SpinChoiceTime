import SwiftUI

struct WheelScreenView: View {
    @ObservedObject var appData: AppData
    var wheel: Wheel
    @State private var rotation: Double = 0
    @State private var isSpinning: Bool = false
    @State private var selectedOption: String?
    @State private var showResult: Bool = false
//    var audioPlayer: AVAudioPlayer? {
//        if appData.soundEnabled {
//            if let path = Bundle.main.path(forResource: "spin_sound", ofType: "mp3") { // Assume you add a spin_sound.mp3 file
//                return try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
//            }
//        }
//        return nil
//    }
    
    var body: some View {
        ZStack {
            Color.themeGradient(wheel.colorTheme)
                .ignoresSafeArea()
            
            VStack {
                WheelView(wheel: wheel, size: 350, rotation: $rotation, isSpinning: $isSpinning)
                
                if !isSpinning {
                    Button("SPIN") {
                        spinWheel()
                    }
                    .buttonStyle(FuturisticButtonStyle())
                    .font(.system(size: 32, weight: .black, design: .rounded))
                }
            }
        }
        .sheet(isPresented: $showResult) {
            ResultScreenView(appData: appData, wheel: wheel, selectedOption: selectedOption ?? "")
        }
    }
    
    private func spinWheel() {
        isSpinning = true
//        audioPlayer?.play()
        let randomSpins = Double.random(in: 10...20) * 360
        let segmentCount = Double(wheel.options.count)
        let anglePerSegment = 360 / segmentCount
        let randomSegment = Int.random(in: 0..<wheel.options.count)
        let finalOffset = Double(randomSegment) * anglePerSegment + anglePerSegment / 2
        
        withAnimation(.easeOut(duration: 8 / appData.animationSpeed)) {
            rotation = randomSpins + finalOffset
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8 / appData.animationSpeed) {
            isSpinning = false
            selectedOption = wheel.options[randomSegment]
            showResult = true
            let historyItem = HistoryItem(id: UUID(), date: Date(), wheelName: wheel.name, selectedOption: selectedOption ?? "")
            appData.history.append(historyItem)
            appData.saveData()
        }
    }
}
