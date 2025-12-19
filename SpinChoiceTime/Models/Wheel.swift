
import Foundation

struct Wheel: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: String
    var colorTheme: String
    var options: [String]
}
