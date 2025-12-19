
import Foundation

struct HistoryItem: Identifiable, Codable {
    let id: UUID
    let date: Date
    let wheelName: String
    let selectedOption: String
}
