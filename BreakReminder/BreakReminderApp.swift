import AppKit

/// Entry point. Break Reminder is a pure menu bar app with no SwiftUI scenes,
/// so it starts AppKit directly and lets `AppDelegate` build everything.
@main
enum BreakReminderApp {
    @MainActor
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
}
