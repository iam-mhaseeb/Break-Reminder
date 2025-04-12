import SwiftUI

@main
struct BreakReminderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var reminder = BreakReminder.shared
    @State private var isMenuBarVisible = false // Always false since we manage it in AppDelegate

    var body: some Scene {
        // Use MenuBarExtra instead of WindowGroup to create a menu bar app without any windows
        MenuBarExtra("Break Reminder", systemImage: "eye", isInserted: $isMenuBarVisible) {
            // Menu content comes from AppDelegate
            EmptyView()
        }
        // Using $isMenuBarVisible (a Binding<Bool>) instead of just false
    }
}
