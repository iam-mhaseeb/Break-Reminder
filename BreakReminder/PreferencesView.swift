import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var reminder: BreakReminder
    @State private var interval: Double = UserDefaults.standard.double(forKey: "breakInterval") == 0 ? 20 : UserDefaults.standard.double(forKey: "breakInterval") / 60
    @State private var showSavedConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Break Reminder Settings")
                .font(.headline)
                .padding(.bottom, 8)
            
            Divider()
            
            // Break interval setting
            VStack(alignment: .leading, spacing: 8) {
                Text("Remind me every:")
                    .fontWeight(.medium)
                
                HStack {
                    Stepper(value: $interval, in: 5...60, step: 5) {
                        Text("\(Int(interval)) minutes")
                            .frame(width: 100, alignment: .leading)
                    }
                }
                
                Text("Recommended: 20 minutes for the 20-20-20 rule")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Save button
            HStack {
                Button("Save") {
                    let seconds = interval * 60
                    UserDefaults.standard.set(seconds, forKey: "breakInterval")
                    reminder.updateInterval(seconds)
                    
                    // Show confirmation message
                    showSavedConfirmation = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSavedConfirmation = false
                    }
                }
                .keyboardShortcut(.defaultAction)
                
                if showSavedConfirmation {
                    Text("Settings saved!")
                        .foregroundColor(.green)
                        .transition(.opacity)
                        .animation(.easeInOut, value: showSavedConfirmation)
                }
                
                Spacer()
                
                Button("Notification Settings...") {
                    openSystemNotificationSettings()
                }
                .help("Open system notification settings for this app")
            }
        }
        .padding()
        .frame(width: 350)
        .onAppear {
            interval = reminder.interval / 60
        }
    }
    
    private func openSystemNotificationSettings() {
        if #available(macOS 13.0, *) {
            let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.yourcompany.BreakReminder"
            
            // Try to open the notification settings for this app
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications?\(bundleIdentifier)") {
                NSWorkspace.shared.open(url)
            } else {
                // Fallback to general settings
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:")!)
            }
        }
    }
}
