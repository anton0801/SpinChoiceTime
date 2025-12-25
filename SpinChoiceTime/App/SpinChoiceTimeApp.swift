import SwiftUI
import Combine
import Firebase
import UserNotifications
import AppsFlyerLib
import AppTrackingTransparency


struct AppConstants {
    static let appsFlyerAppID = "6756783600"
    static let appsFlyerDevKey = "qaGomUbKcyU2sNcvBQnase"
}

@main
struct SpinChoiceTimeApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegateForApp
    
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate, AppsFlyerLibDelegate, MessagingDelegate, UNUserNotificationCenterDelegate, DeepLinkDelegate {
    
    private var deeplinkData: [AnyHashable: Any] = [:]
    private var conversionData: [AnyHashable: Any] = [:]
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    @objc private func initiateTracking() {
        if #available(iOS 14.0, *) {
            AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
            ATTrackingManager.requestTrackingAuthorization { _ in
                DispatchQueue.main.async {
                    AppsFlyerLib.shared().start()
                }
            }
        }
    }
    
    func application(_ app: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initializeFirebase()
        assignDelegates()
        enableRemoteNotifications()
        processLaunchNotifications(launchOptions: launchOptions)
        setupAppsFlyer()
        registerObservers()
        return true
    }
    
    private var mergeTimer: Timer?
    private let trackingSentKey = "trackingDataSent"
    
    private func initializeFirebase() {
        FirebaseApp.configure()
    }
    
    private func assignDelegates() {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
    }
    
    private func enableRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    private func processLaunchNotifications(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if let notificationInfo = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            handleNotificationPayload(notificationInfo)
        }
    }
    
    private func setupAppsFlyer() {
        AppsFlyerLib.shared().appsFlyerDevKey = AppConstants.appsFlyerDevKey
        AppsFlyerLib.shared().appleAppID = AppConstants.appsFlyerAppID
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().deepLinkDelegate = self
    }
    
    private func registerObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(initiateTracking),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        handleNotificationPayload(response.notification.request.content.userInfo)
        completionHandler()
    }
    
    func didResolveDeepLink(_ result: DeepLinkResult) {
        guard case .found = result.status,
              let deeplinkObject = result.deepLink else { return }
        guard !UserDefaults.standard.bool(forKey: trackingSentKey) else { return }
        
        deeplinkData = deeplinkObject.clickEvent
        NotificationCenter.default.post(name: Notification.Name("deeplink_values"), object: nil, userInfo: ["deeplinksData": deeplinkData])
        mergeTimer?.invalidate()
        
        if !conversionData.isEmpty {
            dispatchMergedData()
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        handleNotificationPayload(userInfo)
        completionHandler(.newData)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { [weak self] token, error in
            guard error == nil, let activeToken = token else { return }
            self?.storeToken(activeToken)
        }
    }
    
    private func storeToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "fcm_token")
        UserDefaults.standard.set(token, forKey: "push_token")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let infoPayload = notification.request.content.userInfo
        handleNotificationPayload(infoPayload)
        completionHandler([.banner, .sound])
    }
    
    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        conversionData = data
        initiateMergeTimer()
        if !deeplinkData.isEmpty {
            dispatchMergedData()
        }
    }
    
    func onConversionDataFail(_ error: Error) {
        dispatchData(data: [:])
    }
}

extension AppDelegate {
    
    private func initiateMergeTimer() {
        mergeTimer?.invalidate()
        mergeTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            self?.dispatchMergedData()
        }
    }
    
    private func handleNotificationPayload(_ info: [AnyHashable: Any]) {
        let extractor = SpinPushExtractor()
        if let urlString = extractor.extract(info: info) {
            UserDefaults.standard.set(urlString, forKey: "temp_url")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                NotificationCenter.default.post(
                    name: NSNotification.Name("LoadTempURL"),
                    object: nil,
                    userInfo: ["temp_url": urlString]
                )
            }
        }
    }
    
    private func dispatchData(data: [AnyHashable: Any]) {
        NotificationCenter.default.post(
            name: Notification.Name("ConversionDataReceived"),
            object: nil,
            userInfo: ["conversionData": data]
        )
    }
    
    private func dispatchMergedData() {
        var mergedData = conversionData
        for (key, value) in deeplinkData {
            if mergedData[key] == nil {
                mergedData[key] = value
            }
        }
        dispatchData(data: mergedData)
        UserDefaults.standard.set(true, forKey: trackingSentKey)
    }
}

struct SpinPushExtractor {
    func extract(info: [AnyHashable: Any]) -> String? {
        var parsedLink: String?
        if let link = info["url"] as? String {
            parsedLink = link
        } else if let subInfo = info["data"] as? [String: Any],
                  let subLink = subInfo["url"] as? String {
            parsedLink = subLink
        }
        if let activeLink = parsedLink {
            return activeLink
        }
        return nil
    }
}


struct TrackingBuilder {
    private var appID = ""
    private var devKey = ""
    private var uid = ""
    private let endpoint = "https://gcdsdk.appsflyer.com/install_data/v4.0/"
    
    func assignAppID(_ id: String) -> Self { duplicate(appID: id) }
    func assignDevKey(_ key: String) -> Self { duplicate(devKey: key) }
    func assignUID(_ id: String) -> Self { duplicate(uid: id) }
    
    func generate() -> URL? {
        guard !appID.isEmpty, !devKey.isEmpty, !uid.isEmpty else { return nil }
        var parts = URLComponents(string: endpoint + "id" + appID)!
        parts.queryItems = [
            URLQueryItem(name: "devkey", value: devKey),
            URLQueryItem(name: "device_id", value: uid)
        ]
        return parts.url
    }
    
    private func duplicate(appID: String = "", devKey: String = "", uid: String = "") -> Self {
        var instance = self
        if !appID.isEmpty { instance.appID = appID }
        if !devKey.isEmpty { instance.devKey = devKey }
        if !uid.isEmpty { instance.uid = uid }
        return instance
    }
}
