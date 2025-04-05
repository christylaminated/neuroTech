import SwiftUI
import Charts

struct MetricData: Identifiable {
    let id = UUID()
    let date: Date
    let eegLevel: Double
    let ecgLevel: Double
}

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isFocusing = false
    @State private var selectedDuration: TimeInterval = 25 * 60 // Default 25 minutes
    @State private var timeRemaining: TimeInterval = 25 * 60
    @State private var timer: Timer?
    @State private var coinTimer: Timer?
    @State private var showingDurationPicker = false
    @StateObject private var workoutManager = WorkoutManager.shared
    @State private var isStartingWorkout = false
    
    // Mock data for the last 7 days
    let weekData: [MetricData] = {
        let calendar = Calendar.current
        let today = Date()
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            return MetricData(
                date: date,
                eegLevel: Double.random(in: 60...95),
                ecgLevel: Double.random(in: 65...90)
            )
        }.reversed()
    }()
    
    var body: some View {
        VStack(spacing: 30) {
            // Heart Rate Display
            VStack {
                Text("\(Int(workoutManager.heartRate))")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.red)
                Text("BPM")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 5)
            )
            
            // HRV Display
            VStack {
                Text("HRV")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text(String(format: "%.1f ms", workoutManager.hrv * 1000))
                    .font(.title)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 3)
            )
            
            // Workout Controls
            Button(action: {
                isStartingWorkout = true
                Task {
                    if workoutManager.isWorkoutActive {
                        await workoutManager.stopWorkout()
                    } else {
                        await workoutManager.startWorkout()
                    }
                    isStartingWorkout = false
                }
            }) {
                HStack {
                    Image(systemName: workoutManager.isWorkoutActive ? "stop.fill" : "play.fill")
                    Text(workoutManager.isWorkoutActive ? "Stop Session" : "Start Session")
                }
                .font(.title2)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(workoutManager.isWorkoutActive ? Color.red : Color.green)
                .cornerRadius(15)
            }
            .disabled(isStartingWorkout)
            
            if let startTime = workoutManager.workoutStartTime {
                Text("Session Duration: \(formatDuration(startTime))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
    
    private func formatDuration(_ startTime: Date) -> String {
        let duration = Int(Date().timeIntervalSince(startTime))
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func toggleFocus() {
        isFocusing.toggle()
        if isFocusing {
            timeRemaining = selectedDuration
            startTimer()
            startCoinTimer()
        } else {
            stopTimer()
            stopCoinTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
                isFocusing = false
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        timeRemaining = 25 * 60
    }
    
    private func startCoinTimer() {
        coinTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            // Earn a coin every minute while focusing
            authManager.incrementNeurocoins()
        }
    }
    
    private func stopCoinTimer() {
        coinTimer?.invalidate()
        coinTimer = nil
    }
    
    private func timeString(from seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

struct DurationPickerView: View {
    @Binding var duration: TimeInterval
    @Binding var isPresented: Bool
    
    let durations: [(label: String, minutes: Double)] = [
        ("25 min", 25),
        ("45 min", 45),
        ("1 hour", 60),
        ("1.5 hours", 90),
        ("2 hours", 120)
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(durations, id: \.minutes) { duration in
                    Button(action: {
                        self.duration = duration.minutes * 60
                        isPresented = false
                    }) {
                        HStack {
                            Text(duration.label)
                            Spacer()
                            if self.duration == duration.minutes * 60 {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Duration")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
}
