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
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    @State private var isFocusing = false
    @State private var selectedDuration: TimeInterval = 25 * 60
    @State private var timeRemaining: TimeInterval = 25 * 60
    @State private var timer: Timer?
    @State private var coinTimer: Timer?
    @State private var showingDurationPicker = false
    @State private var showingAuthorizationAlert = false
    
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
                Text("YOUR FOCUS")
                    .appText(size: AppStyle.titleSize)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                
                // Metrics Chart
                VStack(alignment: .leading, spacing: 16) {
                    Text("Weekly Metrics")
                        .appText()
                    
                    Chart {
                        ForEach(weekData) { data in
                            LineMark(
                                x: .value("Date", data.date),
                                y: .value("EEG", data.eegLevel)
                            )
                            .foregroundStyle(.white)
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
                        Text("EEG").appText()
                        Circle()
                            .fill(.green)
                            .frame(width: 8, height: 8)
                        Text("ECG").appText()
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
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
                            .appText(size: AppStyle.titleSize)
                    }
                    Text("Neurocoins Earned")
                        .appText()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Timer Display and Controls
                VStack(spacing: 16) {
                    if isFocusing {
                        Text(timeString(from: timeRemaining))
                            .appText(size: 50)
                            .monospacedDigit()
                    } else {
                        Button(action: { showingDurationPicker = true }) {
                            HStack {
                                Text(timeString(from: selectedDuration))
                                Image(systemName: "clock")
                            }
                        }
                        .appButton()
                    }
                    
                    Button(action: toggleFocus) {
                        Text(isFocusing ? "End Focus Session" : "Start Focus Session")
                    }
                    .appButton()
                    .disabled(!screenTimeManager.isAuthorized)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .appBackground(imageName: "home")
        .sheet(isPresented: $showingDurationPicker) {
            DurationPickerView(duration: $selectedDuration, isPresented: $showingDurationPicker)
        }
        .alert("Screen Time Authorization Required", isPresented: $showingAuthorizationAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Authorize") {
                screenTimeManager.requestAuthorization()
            }
        } message: {
            Text("NeuroFade needs Screen Time authorization to block apps during focus sessions.")
        }
        .alert("Error", isPresented: .constant(screenTimeManager.errorMessage != nil)) {
            Button("OK", role: .cancel) {
                screenTimeManager.errorMessage = nil
            }
        } message: {
            if let error = screenTimeManager.errorMessage {
                Text(error)
            }
        }
        .onAppear {
            if !screenTimeManager.isAuthorized {
                showingAuthorizationAlert = true
            }
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
            startAppRestrictions()
        } else {
            stopTimer()
            stopCoinTimer()
            stopAppRestrictions()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
                isFocusing = false
                stopAppRestrictions()
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
            authManager.incrementNeurocoins()
        }
    }
    
    private func stopCoinTimer() {
        coinTimer?.invalidate()
        coinTimer = nil
    }
    
    private func startAppRestrictions() {
        if let blockedApps = UserDefaults.standard.array(forKey: "blockedApps") as? [String] {
            screenTimeManager.blockApps(Set(blockedApps), duration: selectedDuration)
        }
    }
    
    private func stopAppRestrictions() {
        screenTimeManager.removeRestrictions()
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
                                .appText()
                            Spacer()
                            if self.duration == duration.minutes * 60 {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .background(.ultraThinMaterial)
            .navigationTitle("Select Duration")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            }
            .appButton())
        }
        .appBackground(imageName: "home")
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
}
