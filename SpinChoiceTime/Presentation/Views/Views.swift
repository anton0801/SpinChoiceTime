import SwiftUI

struct ConfettiView: View {
    @State private var counter: Int = 0
    
    var body: some View {
        ZStack {
            ForEach(0..<50) { _ in
                Circle()
                    .foregroundColor([.neonPurple, .neonBlue, .neonYellow].randomElement()!)
                    .frame(width: 10, height: 10)
                    .offset(x: CGFloat.random(in: -100...100), y: CGFloat.random(in: -200...0))
                    .animation(.easeOut(duration: 1.5).delay(CGFloat.random(in: 0...0.5)), value: counter)
            }
        }
        .onAppear {
            counter += 1
        }
    }
}

struct WheelView: View {
    let wheel: Wheel
    let size: CGFloat
    @Binding var rotation: Double
    @Binding var isSpinning: Bool
    
    var body: some View {
        ZStack {
            ZStack {
                // Wheel segments
                ForEach(0..<wheel.options.count, id: \.self) { index in
                    let anglePerSegment = 360.0 / Double(wheel.options.count)
                    let startAngle = Double(index) * anglePerSegment
                    let endAngle = startAngle + anglePerSegment
                    
                    Path { path in
                        let center = CGPoint(x: size / 2, y: size / 2)
                        path.move(to: center)
                        path.addArc(center: center, radius: size / 2, startAngle: .degrees(startAngle), endAngle: .degrees(endAngle), clockwise: false)
                    }
                    .fill(segmentColor(index: index, theme: wheel.colorTheme))
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    // Text on segment
                    Text(wheel.options[index])
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(-rotation - startAngle - anglePerSegment / 2))
                        .offset(x: size / 4 * cos(.pi * (startAngle + anglePerSegment / 2) / 180), y: size / 4 * sin(.pi * (startAngle + anglePerSegment / 2) / 180))
                }
                
                // Border
                Circle()
                    .stroke(Color.neonYellow, lineWidth: 4)
                    .frame(width: size, height: size)
                    .shadow(color: .neonYellow.opacity(0.5), radius: 10)
            }
            .rotationEffect(.degrees(rotation))
            
            // Pointer
            Triangle()
                .fill(Color.red)
                .frame(width: 20, height: 30)
                .offset(y: size / 2 - 15)
                .shadow(color: .red.opacity(0.5), radius: 5)
                .rotationEffect(.degrees(180))
        }
        .frame(width: size, height: size)
    }
    
    private func segmentColor(index: Int, theme: String) -> Color {
        let colors: [Color]
        switch theme {
        case "Purple-Blue":
            colors = [.accentPurple, .accentBlue]
        case "Blue-Yellow":
            colors = [.accentBlue, .accentYellow]
        case "Yellow-Purple":
            colors = [.accentYellow, .accentPurple]
        case "Neon Mix":
            colors = [.neonPurple, .neonBlue, .neonYellow]
        default:
            colors = [.gray]
        }
        return colors[index % colors.count]
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

