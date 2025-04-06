struct NeuroStatsView: View {
    @EnvironmentObject var eegSimulator: EEGSimulator
    @EnvironmentObject var hrvSimulator: HRVSimulator

    var body: some View {
        VStack(spacing: 20) {
            Text("🧠 EEG State: \(eegSimulator.currentState)")
            Text("Alpha: \(String(format: "%.2f", eegSimulator.alpha))")
            Text("Beta: \(String(format: "%.2f", eegSimulator.beta))")
            
            Text("❤️ HRV Stress: \(hrvSimulator.stressLevel)")
            Text("HRV Score: \(Int(hrvSimulator.hrv))")
        }
        .padding()
    }
}
