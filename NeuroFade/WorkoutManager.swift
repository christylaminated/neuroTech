import Foundation
import HealthKit
import Combine

class WorkoutManager: ObservableObject {
    static let shared = WorkoutManager()
    private let healthStore = HKHealthStore()
    
    @Published var isWorkoutActive = false
    @Published var heartRate: Double = 0
    @Published var hrv: Double = 0
    @Published var workoutStartTime: Date?
    
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?
    private var heartRateQuery: HKQuery?
    private var hrvQuery: HKQuery?
    
    private init() {}
    
    func startWorkout() async {
        do {
            // Configure workout session
            let configuration = HKWorkoutConfiguration()
            configuration.activityType = .mindAndBody
            configuration.locationType = .indoor
            
            // Create and start workout session
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            workoutBuilder = workoutSession?.associatedWorkoutBuilder()
            
            workoutBuilder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
            
            // Start the workout session
            try await workoutSession?.startActivity(with: Date())
            try await workoutBuilder?.beginCollection(withStart: Date())
            
            isWorkoutActive = true
            workoutStartTime = Date()
            
            // Start queries for heart rate and HRV
            startHeartRateQuery()
            startHRVQuery()
            
        } catch {
            print("Error starting workout: \(error.localizedDescription)")
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
            print("Error stopping workout: \(error.localizedDescription)")
        }
    }
    
    private func startHeartRateQuery() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            guard let samples = samples as? [HKQuantitySample] else { return }
            
            // Get the most recent heart rate
            if let lastSample = samples.last {
                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                let heartRate = lastSample.quantity.doubleValue(for: heartRateUnit)
                DispatchQueue.main.async {
                    self?.heartRate = heartRate
                }
            }
        }
        
        query.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
            guard let samples = samples as? [HKQuantitySample] else { return }
            
            if let lastSample = samples.last {
                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                let heartRate = lastSample.quantity.doubleValue(for: heartRateUnit)
                DispatchQueue.main.async {
                    self?.heartRate = heartRate
                }
            }
        }
        
        healthStore.execute(query)
        heartRateQuery = query
    }
    
    private func startHRVQuery() {
        let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        
        let query = HKAnchoredObjectQuery(
            type: hrvType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            guard let samples = samples as? [HKQuantitySample] else { return }
            
            // Get the most recent HRV
            if let lastSample = samples.last {
                let hrv = lastSample.quantity.doubleValue(for: .secondUnit())
                DispatchQueue.main.async {
                    self?.hrv = hrv
                }
            }
        }
        
        query.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
            guard let samples = samples as? [HKQuantitySample] else { return }
            
            if let lastSample = samples.last {
                let hrv = lastSample.quantity.doubleValue(for: .secondUnit())
                DispatchQueue.main.async {
                    self?.hrv = hrv
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