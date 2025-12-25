
import Foundation

struct HistoryItem: Identifiable, Codable {
    let id: UUID
    let date: Date
    let wheelName: String
    let selectedOption: String
}


struct CacheSuccessfulChoiceUseCase {
    let repo: ChoiceRepository
    
    func perform(choice: String) {
        repo.storeChoice(choice)
        repo.updateAppState("SpinView")
        repo.markAsRun()
    }
}

struct ProcessSkipPermissionsUseCase {
    let repo: ChoiceRepository
    
    func perform() {
        repo.updateLastPermissionRequest(Date())
    }
}

struct ProcessGrantPermissionsUseCase {
    let repo: ChoiceRepository
    
    func perform(accepted: Bool) {
        repo.updatePermissionsAccepted(accepted)
        if !accepted {
            repo.updatePermissionsDenied(true)
        }
    }
}

struct RetrieveOrganicTrackingUseCase {
    let repo: ChoiceRepository
    
    func perform(linkData: [String: Any]) async throws -> [String: Any] {
        try await repo.retrieveOrganicData(linkData: linkData)
    }
}

struct RetrieveChoiceConfigUseCase {
    let repo: ChoiceRepository
    
    func perform(trackingData: [String: Any]) async throws -> URL {
        try await repo.retrieveServerChoice(data: trackingData)
    }
}
