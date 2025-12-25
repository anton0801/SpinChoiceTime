import Foundation
import SwiftUI


extension Color {
    static let accentPurple = Color(red: 0.5, green: 0.0, blue: 1.0).opacity(0.8)
    static let accentBlue = Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.8)
    static let accentYellow = Color(red: 1.0, green: 0.8, blue: 0.0).opacity(0.8)
    static let neonPurple = Color(red: 0.9, green: 0.3, blue: 1.0)
    static let neonBlue = Color(red: 0.3, green: 0.9, blue: 1.0)
    static let neonYellow = Color(red: 1.0, green: 0.9, blue: 0.3)
    static let futuristicGray = Color(red: 0.1, green: 0.1, blue: 0.1)
    static let glowWhite = Color.white.opacity(0.5)
    
    static func themeGradient(_ theme: String) -> LinearGradient {
        switch theme {
        case "Purple-Blue":
            return LinearGradient(colors: [.neonPurple, .neonBlue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "Blue-Yellow":
            return LinearGradient(colors: [.neonBlue, .neonYellow], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "Yellow-Purple":
            return LinearGradient(colors: [.neonYellow, .neonPurple], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "Neon Mix":
            return LinearGradient(colors: [.neonPurple, .neonBlue, .neonYellow], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [.futuristicGray, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

protocol ChoiceRepository {
    var isInitialRun: Bool { get }
    func retrieveStoredChoice() -> URL?
    func storeChoice(_ url: String)
    func updateAppState(_ state: String)
    func markAsRun()
    func retrieveAppState() -> String?
    func updateLastPermissionRequest(_ date: Date)
    func updatePermissionsAccepted(_ accepted: Bool)
    func updatePermissionsDenied(_ denied: Bool)
    func retrievePermissionsAccepted() -> Bool
    func retrievePermissionsDenied() -> Bool
    func retrieveLastPermissionRequest() -> Date?
    func retrievePushToken() -> String?
    func retrieveLanguageCode() -> String
    func retrieveAppIdentifier() -> String
    func retrieveFirebaseID() -> String?
    func retrieveAppStoreID() -> String
    func retrieveTrackingID() -> String
    func retrieveOrganicData(linkData: [String: Any]) async throws -> [String: Any]
    func retrieveServerChoice(data: [String: Any]) async throws -> URL
}
