import Foundation
import Combine

class EEGSimulator: ObservableObject {
    @Published var alpha: Double = 0.0
    @Published var beta: Double = 0.0
    @Published var currentState: String = "Distracted"
    
    private var timer: Timer?
    
    func startSimulation() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.alpha = Double.random(in: 0.3...2.0)
            self.beta = Double.random(in: 0.2...1.5)
            self.evaluateState()
        }
    }
    
    private func evaluateState() {
        if alpha > 1.5 {
            currentState = "Calm"
        } else if beta > 1.0 {
            currentState = "Focused"
        } else {
            currentState = "Distracted"
        }
    }
    
    func stopSimulation() {
        timer?.invalidate()
        timer = nil
    }
}
