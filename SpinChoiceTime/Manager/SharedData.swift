import Foundation
import AppsFlyerLib
import Firebase
import FirebaseMessaging
import Combine

// Categories
let categories = ["Daily", "Food", "Fun", "Challenges", "Custom"]

// Color Themes
let colorThemes = ["Purple-Blue", "Blue-Yellow", "Yellow-Purple", "Neon Mix", "Custom"]

let templates: [Wheel] = [
    Wheel(id: UUID(), name: "What to eat?", category: "Food", colorTheme: "Blue-Yellow", options: ["Pizza", "Salad", "Burger", "Sushi", "Pasta"]),
    Wheel(id: UUID(), name: "Weekend plans", category: "Fun", colorTheme: "Purple-Blue", options: ["Hiking", "Movie Night", "Beach Day", "Gaming", "Reading"]),
    Wheel(id: UUID(), name: "Workout choice", category: "Daily", colorTheme: "Yellow-Purple", options: ["Run", "Yoga", "Weights", "Cycling", "Swim"]),
    Wheel(id: UUID(), name: "Movie night", category: "Fun", colorTheme: "Neon Mix", options: ["Action", "Comedy", "Drama", "Horror", "Sci-Fi"])
]



class ChoiceRepositoryImpl: ChoiceRepository {
    private let defaults: UserDefaults
    private let tracker: AppsFlyerLib
    
    init(defaults: UserDefaults = .standard, tracker: AppsFlyerLib = .shared()) {
        self.defaults = defaults
        self.tracker = tracker
    }
    
    var isInitialRun: Bool {
        !defaults.bool(forKey: "hasRunPreviously")
    }
    
    func retrieveStoredChoice() -> URL? {
        if let stored = defaults.string(forKey: "stored_path"),
           let url = URL(string: stored) {
            return url
        }
        return nil
    }
    
    func storeChoice(_ url: String) {
        defaults.set(url, forKey: "stored_path")
    }
    
    func updateAppState(_ state: String) {
        defaults.set(state, forKey: "app_state")
    }
    
    func retrievePushToken() -> String? {
        defaults.string(forKey: "push_token") ?? Messaging.messaging().fcmToken
    }
    
    func markAsRun() {
        defaults.set(true, forKey: "hasRunPreviously")
    }
    
    func retrieveAppState() -> String? {
        defaults.string(forKey: "app_state")
    }
    
    func updateLastPermissionRequest(_ date: Date) {
        defaults.set(date, forKey: "last_perm_request")
    }
    
    func retrievePermissionsDenied() -> Bool {
        defaults.bool(forKey: "perms_denied")
    }
    
    func retrieveLastPermissionRequest() -> Date? {
        defaults.object(forKey: "last_perm_request") as? Date
    }
    
    func updatePermissionsAccepted(_ accepted: Bool) {
        defaults.set(accepted, forKey: "perms_accepted")
    }
    
    func updatePermissionsDenied(_ denied: Bool) {
        defaults.set(denied, forKey: "perms_denied")
    }
    
    func retrievePermissionsAccepted() -> Bool {
        defaults.bool(forKey: "perms_accepted")
    }
    
    func retrieveLanguageCode() -> String {
        Locale.preferredLanguages.first?.prefix(2).uppercased() ?? "EN"
    }
    
    func retrieveAppIdentifier() -> String {
        "com.choicetimings.SpinChoiceTime"
    }
    
    func retrieveFirebaseID() -> String? {
        FirebaseApp.app()?.options.gcmSenderID
    }
    
    func retrieveAppStoreID() -> String {
        "id\(AppConstants.appsFlyerAppID)"
    }
    
    func retrieveTrackingID() -> String {
        tracker.getAppsFlyerUID()
    }
    
    func retrieveOrganicData(linkData: [String: Any]) async throws -> [String: Any] {
        let url = buildTrackingURL()
        guard let url else {
            throw NSError(domain: "TrackingError", code: 0)
        }
        let (data, resp) = try await URLSession.shared.data(from: url)
        try validateResponse(resp: resp, data: data)
        guard let jsonData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "TrackingError", code: 1)
        }
        return mergeData(jsonData: jsonData, linkData: linkData)
    }
    
    private func buildTrackingURL() -> URL? {
        TrackingBuilder()
            .assignAppID(AppConstants.appsFlyerAppID)
            .assignDevKey(AppConstants.appsFlyerDevKey)
            .assignUID(retrieveTrackingID())
            .generate()
    }
    
    private func validateResponse(resp: URLResponse, data: Data) throws {
        guard let httpResp = resp as? HTTPURLResponse,
              httpResp.statusCode == 200 else {
            throw NSError(domain: "TrackingError", code: 1)
        }
    }
    
    private func mergeData(jsonData: [String: Any], linkData: [String: Any]) -> [String: Any] {
        var merged = jsonData
        for (k, v) in linkData where merged[k] == nil {
            merged[k] = v
        }
        return merged
    }
    
    func retrieveServerChoice(data: [String: Any]) async throws -> URL {
        let endpoint = try getEndpointURL()
        var requestData = prepareRequestData(baseData: data)
        let body = try serializeRequestData(requestData: requestData)
        let req = buildRequest(endpoint: endpoint, body: body)
        let (responseData, _) = try await URLSession.shared.data(for: req)
        return try parseResponseData(responseData: responseData)
    }
    
    private func getEndpointURL() throws -> URL {
        guard let url = URL(string: "https://spinchoicetime.com/config.php") else {
            throw NSError(domain: "ChoiceError", code: 0)
        }
        return url
    }
    
    private func prepareRequestData(baseData: [String: Any]) -> [String: Any] {
        var requestData = baseData
        requestData["os"] = "iOS"
        requestData["af_id"] = retrieveTrackingID()
        requestData["bundle_id"] = retrieveAppIdentifier()
        requestData["firebase_project_id"] = retrieveFirebaseID()
        requestData["store_id"] = retrieveAppStoreID()
        requestData["push_token"] = retrievePushToken()
        requestData["locale"] = retrieveLanguageCode()
        return requestData
    }
    
    private func serializeRequestData(requestData: [String: Any]) throws -> Data {
        guard let body = try? JSONSerialization.data(withJSONObject: requestData) else {
            throw NSError(domain: "ChoiceError", code: 1)
        }
        return body
    }
    
    private func buildRequest(endpoint: URL, body: Data) -> URLRequest {
        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = body
        return req
    }
    
    private func parseResponseData(responseData: Data) throws -> URL {
        guard let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
              let success = json["ok"] as? Bool, success,
              let choiceStr = json["url"] as? String,
              let choiceURL = URL(string: choiceStr) else {
            throw NSError(domain: "ChoiceError", code: 2)
        }
        return choiceURL
    }
}
