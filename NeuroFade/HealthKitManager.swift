import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    // HealthKit types we want to read
    private let typesToRead: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
        HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!
    ]
    
    @Published var isAuthorized = false
    @Published var errorMessage: String?
    
    private init() {}
    
    func requestAuthorization() async {
        do {
            // Check if HealthKit is available on this device
            guard HKHealthStore.isHealthDataAvailable() else {
                errorMessage = "HealthKit is not available on this device"
                return
            }
            
            // Request authorization
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            
            // Check if Apple Watch is configured
            if !isAppleWatchConfigured() {
                errorMessage = "Please configure your Apple Watch with Apple Health to collect heart rate and HRV data"
                return
            }
            
            isAuthorized = true
        } catch {
            errorMessage = "Failed to authorize HealthKit: \(error.localizedDescription)"
        }
    }
    
    private func isAppleWatchConfigured() -> Bool {
        // Check if Apple Watch is paired and configured
        let watchConfiguration = HKWatchConfiguration()
        return watchConfiguration.isPaired
    }
    
    func checkAuthorizationStatus() async {
        do {
            for type in typesToRead {
                let status = try await healthStore.authorizationStatus(for: type)
                if status != .sharingAuthorized {
                    isAuthorized = false
                    return
                }
            }
            isAuthorized = true
        } catch {
            errorMessage = "Failed to check authorization status: \(error.localizedDescription)"
            isAuthorized = false
        }
    }
} 