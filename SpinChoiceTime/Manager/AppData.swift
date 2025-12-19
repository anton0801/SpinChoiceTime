import Foundation
import Combine

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
