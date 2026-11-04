import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var reminder: BreakReminder

    @State private var intervalMinutes: Int = Int(BreakSettings.defaultInterval / 60)
    @State private var breakSeconds: Int = BreakSettings.defaultDuration
    @State private var launchAtLogin = LaunchAtLogin.isEnabled
    @State private var launchAtLoginError: String?
    @State private var showSavedConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Break Reminder Settings")
                .font(.headline)
                .padding(.bottom, 8)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Remind me every:")
                    .fontWeight(.medium)

                Stepper(value: $intervalMinutes, in: BreakSettings.intervalMinutes, step: 5) {
                    Text("\(intervalMinutes) minutes")
                        .frame(width: 140, alignment: .leading)
                }

                Text("Recommended: 20 minutes for the 20-20-20 rule")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Each break lasts:")
                    .fontWeight(.medium)

                Stepper(value: $breakSeconds, in: BreakSettings.durationSeconds, step: 10) {
                    Text("\(breakSeconds) seconds")
                        .frame(width: 140, alignment: .leading)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        applyLaunchAtLogin(newValue)
                    }

                if let launchAtLoginError {
                    Text(launchAtLoginError)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            Divider()

            HStack {
                Button("Save") {
                    reminder.updateSettings(
                        interval: TimeInterval(intervalMinutes * 60),
                        breakDuration: breakSeconds
                    )
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
                        .accessibilityLabel("Settings saved")
                }

                Spacer()
            }
            .animation(.easeInOut, value: showSavedConfirmation)
        }
        .padding()
        .frame(width: 350)
        .onAppear {
            intervalMinutes = Int(reminder.interval / 60)
            breakSeconds = reminder.breakDuration
            launchAtLogin = LaunchAtLogin.isEnabled
        }
    }

    private func applyLaunchAtLogin(_ enabled: Bool) {
        guard enabled != LaunchAtLogin.isEnabled else { return }
        do {
            try LaunchAtLogin.setEnabled(enabled)
            launchAtLoginError = nil
        } catch {
            launchAtLogin = LaunchAtLogin.isEnabled // revert the toggle
            launchAtLoginError = "Couldn't change the login item: \(error.localizedDescription)"
        }
    }
}
