import Foundation
import SwiftUI


extension Color {
    static let accentPurple = Color.purple.opacity(0.8)
    static let accentBlue = Color.blue.opacity(0.8)
    static let accentYellow = Color.yellow.opacity(0.8)
    static let neonPurple = Color(red: 0.8, green: 0.2, blue: 1.0)
    static let neonBlue = Color(red: 0.2, green: 0.8, blue: 1.0)
    static let neonYellow = Color(red: 1.0, green: 0.8, blue: 0.2)
    
    static func themeGradient(_ theme: String) -> LinearGradient {
        switch theme {
        case "Purple-Blue":
            return LinearGradient(colors: [.accentPurple, .accentBlue], startPoint: .top, endPoint: .bottom)
        case "Blue-Yellow":
            return LinearGradient(colors: [.accentBlue, .accentYellow], startPoint: .top, endPoint: .bottom)
        case "Yellow-Purple":
            return LinearGradient(colors: [.accentYellow, .accentPurple], startPoint: .top, endPoint: .bottom)
        case "Neon Mix":
            return LinearGradient(colors: [.neonPurple, .neonBlue, .neonYellow], startPoint: .top, endPoint: .bottom)
        default:
            return LinearGradient(colors: [.gray, .black], startPoint: .top, endPoint: .bottom)
        }
    }
}
