import SwiftUI
import ScreenTime
import UserNotifications

class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()
    private var store: STScreenTimeConfigurationStore?
    private var schedule: STSchedule?
    @Published var isAuthorized = false
    @Published var errorMessage: String?
    
    private init() {
        setupScreenTime()
    }
    
    private func setupScreenTime() {
        // Request Screen Time authorization
        STScreenTimeConfigurationStore.requestAuthorization { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to authorize Screen Time: \(error.localizedDescription)"
                    self?.isAuthorized = false
                } else {
                    self?.store = STScreenTimeConfigurationStore.shared
                    self?.schedule = STSchedule()
                    self?.isAuthorized = true
                }
            }
        }
    }
    
    func blockApps(_ appIdentifiers: Set<String>, duration: TimeInterval) {
        guard let store = store else {
            errorMessage = "Screen Time not initialized"
            return
        }
        
        guard isAuthorized else {
            errorMessage = "Screen Time not authorized"
            return
        }
        
        let schedule = STSchedule()
        schedule.startTime = Date()
        schedule.endTime = Date().addingTimeInterval(duration)
        
        let configuration = STConfiguration()
        configuration.schedule = schedule
        
        // Create app restrictions
        let restrictions = STAppRestrictions()
        restrictions.allowedApps = []
        restrictions.blockedApps = Array(appIdentifiers)
        
        configuration.appRestrictions = restrictions
        
        // Apply the configuration
        store.setConfiguration(configuration) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to set screen time configuration: \(error.localizedDescription)"
                } else {
                    self?.scheduleLocalNotification(for: duration)
                }
            }
        }
    }
    
    func removeRestrictions() {
        guard let store = store else {
            errorMessage = "Screen Time not initialized"
            return
        }
        
        guard isAuthorized else {
            errorMessage = "Screen Time not authorized"
            return
        }
        
        // Remove all restrictions
        let configuration = STConfiguration()
        configuration.schedule = nil
        configuration.appRestrictions = nil
        
        store.setConfiguration(configuration) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to remove screen time configuration: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func scheduleLocalNotification(for duration: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Focus Session Complete"
        content.body = "Your focus session has ended. App restrictions have been removed."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: false)
        let request = UNNotificationRequest(identifier: "focusSessionComplete", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    func requestAuthorization() {
        // Request Screen Time authorization
        STScreenTimeConfigurationStore.requestAuthorization { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to authorize Screen Time: \(error.localizedDescription)"
                    self?.isAuthorized = false
                } else {
                    self?.store = STScreenTimeConfigurationStore.shared
                    self?.schedule = STSchedule()
                    self?.isAuthorized = true
                }
            }
        }
        
        // Request notification authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Failed to authorize notifications: \(error.localizedDescription)")
            }
        }
    }
} 