import Foundation
import Combine

class HRVSimulator: ObservableObject {
    @Published var hrv: Double = 0.0
    @Published var stressLevel: String = "High Stress"
    
    private var timer: Timer?
    
    func startSimulation() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.hrv = Double.random(in: 30...90)
            self.evaluateStressLevel()
        }
    }
    
    private func evaluateStressLevel() {
        if hrv > 60 {
            stressLevel = "Relaxed"
        } else {
            stressLevel = "Stressed"
        }
    }
    
    func stopSimulation() {
        timer?.invalidate()
        timer = nil
    }
}
