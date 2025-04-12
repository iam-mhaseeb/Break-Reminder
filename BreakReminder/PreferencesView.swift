import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var reminder: BreakReminder
    @State private var interval: Double = UserDefaults.standard.double(forKey: "breakInterval") == 0 ? 20 : UserDefaults.standard.double(forKey: "breakInterval") / 60

    var body: some View {
        VStack(alignment: .leading) {
            Text("Remind me every:")
            HStack {
                Stepper(value: $interval, in: 5...60, step: 5) {
                    Text("\(Int(interval)) minutes")
                }
            }
            .padding(.bottom, 20)

            Button("Save") {
                let seconds = interval * 60
                UserDefaults.standard.set(seconds, forKey: "breakInterval")
                reminder.updateInterval(seconds)
            }
        }
        .padding()
        .frame(width: 300)
        .onAppear {
            interval = reminder.interval / 60
        }
    }
}
