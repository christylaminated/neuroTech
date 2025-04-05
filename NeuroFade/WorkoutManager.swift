import Foundation
import HealthKit
import Combine

protocol WorkoutManagerDelegate: AnyObject {
    func workoutManager(_ manager: WorkoutManager, didUpdateHeartRate heartRate: Double)
    func workoutManager(_ manager: WorkoutManager, didUpdateHRV hrv: Double)
    func workoutManager(_ manager: WorkoutManager, didFailWithError error: Error)
}

class WorkoutManager: NSObject, ObservableObject {
    static let shared = WorkoutManager()
    private let healthStore = HKHealthStore()
    weak var delegate: WorkoutManagerDelegate?
    
    @Published var isWorkoutActive = false
    @Published var heartRate: Double = 0
    @Published var hrv: Double = 0
    @Published var workoutStartTime: Date?
    @Published var errorMessage: String?
    
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKWorkoutBuilder?
    private var heartRateQuery: HKQuery?
    private var hrvQuery: HKQuery?
    
    private override init() {
        super.init()
    }
    
    func startWorkout() async {
        do {
            // First ensure we have workout authorization
            let healthKitManager = HealthKitManager.shared
            let isAuthorized = await healthKitManager.requestWorkoutAuthorization()
            
            guard isAuthorized else {
                throw NSError(domain: "WorkoutManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Workout authorization failed"])
            }
            
            // Configure workout session
            let configuration = HKWorkoutConfiguration()
            configuration.activityType = .mindAndBody
            configuration.locationType = .indoor
            
            // Create and start workout session
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            workoutBuilder = HKWorkoutBuilder(healthStore: healthStore, configuration: configuration, device: .local())
            
            // Set the workout session delegate
            workoutSession?.delegate = self
            
            // Start the workout session
            try await workoutSession?.startActivity(with: Date())
            try await workoutBuilder?.beginCollection(withStart: Date())
            
            isWorkoutActive = true
            workoutStartTime = Date()
            
            // Start queries for heart rate and HRV
            startHeartRateQuery()
            startHRVQuery()
            
        } catch {
            errorMessage = "Error starting workout: \(error.localizedDescription)"
            delegate?.workoutManager(self, didFailWithError: error)
        }
    }
    
    func stopWorkout() async {
        do {
            // End the workout session
            try await workoutSession?.end()
            try await workoutBuilder?.endCollection(withEnd: Date())
            
            // Save the workout
            if let workout = workoutBuilder?.workout {
                try await healthStore.save(workout)
            }
            
            isWorkoutActive = false
            workoutStartTime = nil
            
            // Stop queries
            stopQueries()
            
        } catch {
            errorMessage = "Error stopping workout: \(error.localizedDescription)"
            delegate?.workoutManager(self, didFailWithError: error)
        }
    }
    
    private func startHeartRateQuery() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            errorMessage = "Heart rate type not available"
            return
        }
        
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            guard let self = self else { return }
            guard let samples = samples as? [HKQuantitySample] else { return }
            
            // Get the most recent heart rate
            if let lastSample = samples.last {
                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                let heartRate = lastSample.quantity.doubleValue(for: heartRateUnit)
                DispatchQueue.main.async {
                    self.heartRate = heartRate
                    self.delegate?.workoutManager(self, didUpdateHeartRate: heartRate)
                }
            }
        }
        
        query.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
            guard let self = self else { return }
            guard let samples = samples as? [HKQuantitySample] else { return }
            
            if let lastSample = samples.last {
                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                let heartRate = lastSample.quantity.doubleValue(for: heartRateUnit)
                DispatchQueue.main.async {
                    self.heartRate = heartRate
                    self.delegate?.workoutManager(self, didUpdateHeartRate: heartRate)
                }
            }
        }
        
        healthStore.execute(query)
        heartRateQuery = query
    }
    
    private func startHRVQuery() {
        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            errorMessage = "HRV type not available"
            return
        }
        
        let query = HKAnchoredObjectQuery(
            type: hrvType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            guard let self = self else { return }
            guard let samples = samples as? [HKQuantitySample] else { return }
            
            // Get the most recent HRV
            if let lastSample = samples.last {
                let hrv = lastSample.quantity.doubleValue(for: .secondUnit())
                DispatchQueue.main.async {
                    self.hrv = hrv
                    self.delegate?.workoutManager(self, didUpdateHRV: hrv)
                }
            }
        }
        
        query.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
            guard let self = self else { return }
            guard let samples = samples as? [HKQuantitySample] else { return }
            
            if let lastSample = samples.last {
                let hrv = lastSample.quantity.doubleValue(for: .secondUnit())
                DispatchQueue.main.async {
                    self.hrv = hrv
                    self.delegate?.workoutManager(self, didUpdateHRV: hrv)
                }
            }
        }
        
        healthStore.execute(query)
        hrvQuery = query
    }
    
    private func stopQueries() {
        if let heartRateQuery = heartRateQuery {
            healthStore.stop(heartRateQuery)
        }
        if let hrvQuery = hrvQuery {
            healthStore.stop(hrvQuery)
        }
        heartRateQuery = nil
        hrvQuery = nil
    }
}

// MARK: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        // Handle workout session state changes
        DispatchQueue.main.async {
            self.isWorkoutActive = toState == .running
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        // Handle workout session errors
        DispatchQueue.main.async {
            self.errorMessage = "Workout session failed: \(error.localizedDescription)"
            self.isWorkoutActive = false
            self.delegate?.workoutManager(self, didFailWithError: error)
        }
    }
} 