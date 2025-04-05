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
        ScrollView {
            VStack(spacing: 24) {
                // Centered Title
                Text("YOUR FOCUS")
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                
                // Metrics Chart
                VStack(alignment: .leading, spacing: 16) {
                    Text("Weekly Metrics")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Chart {
                        ForEach(weekData) { data in
                            LineMark(
                                x: .value("Date", data.date),
                                y: .value("EEG", data.eegLevel)
                            )
                            .foregroundStyle(.blue)
                            .interpolationMethod(.catmullRom)
                            
                            LineMark(
                                x: .value("Date", data.date),
                                y: .value("ECG", data.ecgLevel)
                            )
                            .foregroundStyle(.green)
                            .interpolationMethod(.catmullRom)
                        }
                    }
                    .frame(height: 200)
                    
                    HStack {
                        Circle()
                            .fill(.blue)
                            .frame(width: 8, height: 8)
                        Text("EEG")
                        Circle()
                            .fill(.green)
                            .frame(width: 8, height: 8)
                        Text("ECG")
                    }
                    .font(.caption)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding(.horizontal)
                
                // Coins Display
                VStack(spacing: 8) {
                    HStack {
                        Image("coin")
                            .resizable()
                            .renderingMode(.original)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                        Text("\(authManager.neurocoins)")
                            .font(.title)
                            .bold()
                    }
                    Text("Neurocoins Earned")
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding(.horizontal)
                
                // Timer Display and Controls
                VStack(spacing: 16) {
                    if isFocusing {
                        Text(timeString(from: timeRemaining))
                            .font(.system(size: 50, weight: .bold))
                            .monospacedDigit()
                    } else {
                        Button(action: { showingDurationPicker = true }) {
                            HStack {
                                Text(timeString(from: selectedDuration))
                                    .font(.title2)
                                Image(systemName: "clock")
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    
                    Button(action: toggleFocus) {
                        Text(isFocusing ? "End Focus Session" : "Start Focus Session")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFocusing ? Color.red : Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color.gray.opacity(0.1))
        .sheet(isPresented: $showingDurationPicker) {
            DurationPickerView(duration: $selectedDuration, isPresented: $showingDurationPicker)
        }
        .onDisappear {
            stopTimer()
        }
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
