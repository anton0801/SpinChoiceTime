import SwiftUI

struct ConfettiView: View {
    @State private var counter: Int = 0
    
    var body: some View {
        ZStack {
            ForEach(0..<100) { _ in
                Circle()
                    .foregroundColor([.neonPurple, .neonBlue, .neonYellow].randomElement()!)
                    .frame(width: CGFloat.random(in: 5...15), height: CGFloat.random(in: 5...15))
                    .offset(x: CGFloat.random(in: -UIScreen.main.bounds.width/2...UIScreen.main.bounds.width/2), y: CGFloat.random(in: -UIScreen.main.bounds.height...0))
                    .animation(.easeOut(duration: 2.0).delay(CGFloat.random(in: 0...1.0)), value: counter)
                    .blur(radius: 1)
                    .shadow(color: .glowWhite, radius: 5)
            }
        }
        .onAppear {
            counter += 1
        }
    }
}

//struct WheelView: View {
//    let wheel: Wheel
//    let size: CGFloat
//    @Binding var rotation: Double
//    @Binding var isSpinning: Bool
//    
//    var body: some View {
//        ZStack {
//            ZStack {
//                // Wheel segments
//                ForEach(0..<wheel.options.count, id: \.self) { index in
//                    let anglePerSegment = 360.0 / Double(wheel.options.count)
//                    let startAngle = Double(index) * anglePerSegment
//                    let endAngle = startAngle + anglePerSegment
//                    
//                    Path { path in
//                        let center = CGPoint(x: size / 2, y: size / 2)
//                        path.move(to: center)
//                        path.addArc(center: center, radius: size / 2, startAngle: .degrees(startAngle), endAngle: .degrees(endAngle), clockwise: false)
//                    }
//                    .fill(segmentColor(index: index, theme: wheel.colorTheme))
//                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 0)
//                    
//                    // Text on segment
//                    Text(wheel.options[index])
//                        .font(.system(size: 14, weight: .bold))
//                        .foregroundColor(.white)
//                        .rotationEffect(.degrees(-rotation - startAngle - anglePerSegment / 2))
//                        .offset(x: size / 4 * cos(.pi * (startAngle + anglePerSegment / 2) / 180), y: size / 4 * sin(.pi * (startAngle + anglePerSegment / 2) / 180))
//                }
//                
//                // Border
//                Circle()
//                    .stroke(Color.neonYellow, lineWidth: 4)
//                    .frame(width: size, height: size)
//                    .shadow(color: .neonYellow.opacity(0.5), radius: 10)
//            }
//            .rotationEffect(.degrees(rotation))
//            
//            // Pointer
//            Triangle()
//                .fill(Color.red)
//                .frame(width: 20, height: 30)
//                .offset(y: size / 2 - 15)
//                .shadow(color: .red.opacity(0.5), radius: 5)
//                .rotationEffect(.degrees(180))
//        }
//        .frame(width: size, height: size)
//    }
//    
//    private func segmentColor(index: Int, theme: String) -> Color {
//        let colors: [Color]
//        switch theme {
//        case "Purple-Blue":
//            colors = [.accentPurple, .accentBlue]
//        case "Blue-Yellow":
//            colors = [.accentBlue, .accentYellow]
//        case "Yellow-Purple":
//            colors = [.accentYellow, .accentPurple]
//        case "Neon Mix":
//            colors = [.neonPurple, .neonBlue, .neonYellow]
//        default:
//            colors = [.gray]
//        }
//        return colors[index % colors.count]
//    }
//}

struct WheelView: View {
    let wheel: Wheel
    let size: CGFloat
    var selectorVisible = true
    @Binding var rotation: Double
    @Binding var isSpinning: Bool
    @State private var glowOpacity: Double = 0.5
    
    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .fill(Color.neonBlue.opacity(0.2))
                    .frame(width: size * 1.2, height: size * 1.2)
                    .blur(radius: 20)
                
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
                    .overlay(
                        Path { path in
                            let center = CGPoint(x: size / 2, y: size / 2)
                            path.addArc(center: center, radius: size / 2, startAngle: .degrees(startAngle), endAngle: .degrees(endAngle), clockwise: false)
                        }
                        .stroke(Color.glowWhite, lineWidth: 2)
                    )
                    //.shadow(color: .neonPurple.opacity(0.5), radius: 10, x: 0, y: 0)
                    
                    Text(wheel.options[index])
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        //.shadow(color: .glowWhite, radius: 3)
                        .rotationEffect(.degrees(-rotation - startAngle - anglePerSegment / 2))
                        .offset(x: size / 4 * cos(.pi * (startAngle + anglePerSegment / 2) / 180), y: size / 4 * sin(.pi * (startAngle + anglePerSegment / 2) / 180))
                }
                
//                Circle()
//                    .stroke(Color.neonYellow, lineWidth: 6)
//                    .frame(width: size, height: size)
//                    .shadow(color: .neonYellow.opacity(0.8), radius: 15)
            }
            .rotationEffect(.degrees(rotation))
            .particleEffect(active: isSpinning)
            
            if selectorVisible {
                Triangle()
                    .fill(LinearGradient(colors: [.red, .neonYellow], startPoint: .top, endPoint: .bottom))
                    .frame(width: 25, height: 40)
                    .offset(y: size / 2 - 20)
                    .rotationEffect(.degrees(180))
            }
        }
        .frame(width: size, height: size)
    }
    
    private func segmentColor(index: Int, theme: String) -> Color {
        let colors: [Color]
        switch theme {
        case "Purple-Blue":
            colors = [.neonPurple, .neonBlue]
        case "Blue-Yellow":
            colors = [.neonBlue, .neonYellow]
        case "Yellow-Purple":
            colors = [.neonYellow, .neonPurple]
        case "Neon Mix":
            colors = [.neonPurple, .neonBlue, .neonYellow]
        default:
            colors = [.futuristicGray]
        }
        return colors[index % colors.count].opacity(0.9)
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

#Preview {
    WheelView(wheel: Wheel(id: UUID(), name: "", category: "", colorTheme: "Neon Mix", options: Array(repeating: "", count: 8)), size: 250, rotation: .constant(3600), isSpinning: .constant(true))
}

struct ParticleEffect: ViewModifier {
    let active: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if active {
                    ZStack {
                        ForEach(0..<20) { _ in
                            Circle()
                                .fill(Color.neonYellow.opacity(0.5))
                                .frame(width: 5, height: 5)
                                .offset(x: CGFloat.random(in: -50...50), y: CGFloat.random(in: -50...50))
                                .animation(.easeOut(duration: 1.0).repeatForever(autoreverses: false), value: UUID())
                        }
                    }
                }
            }
    }
}

extension View {
    func particleEffect(active: Bool) -> some View {
        modifier(ParticleEffect(active: active))
    }
}
