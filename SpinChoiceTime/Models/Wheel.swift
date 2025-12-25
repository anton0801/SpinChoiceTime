
import Foundation

struct Wheel: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: String
    var colorTheme: String
    var options: [String]
}



struct DetermineCurrentPhaseUseCase {
    let repo: ChoiceRepository
    
    func perform(trackingData: [String: Any], initial: Bool, currentURL: URL?, interimURL: String?) -> SpinPhase {
        if trackingData.isEmpty {
            return .legacy
        }
        if repo.retrieveAppState() == "Inactive" {
            return .legacy
        }
        if initial && (trackingData["af_status"] as? String == "Organic") {
            return .setup
        }
        if let interim = interimURL, let url = URL(string: interim), currentURL == nil {
            return .operational
        }
        return .setup
    }
}

struct CheckPermissionPromptUseCase {
    let repo: ChoiceRepository
    
    func perform() -> Bool {
        guard !repo.retrievePermissionsAccepted(),
              !repo.retrievePermissionsDenied() else {
            return false
        }
        if let previous = repo.retrieveLastPermissionRequest(),
           Date().timeIntervalSince(previous) < 259200 {
            return false
        }
        return true
    }
}

struct ActivateLegacyUseCase {
    let repo: ChoiceRepository
    
    func perform() {
        repo.updateAppState("Inactive")
        repo.markAsRun()
    }
}

struct RetrieveCachedChoiceUseCase {
    let repo: ChoiceRepository
    
    func perform() -> URL? {
        repo.retrieveStoredChoice()
    }
}
