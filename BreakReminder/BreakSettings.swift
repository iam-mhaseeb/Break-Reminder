import Foundation

/// Central place for the user-facing settings: their `UserDefaults` keys,
/// defaults and allowed ranges.
enum BreakSettings {
    // MARK: UserDefaults keys
    static let intervalKey = "breakInterval"   // seconds between breaks
    static let durationKey = "breakDuration"   // seconds a break lasts

    // MARK: Defaults
    static let defaultInterval: TimeInterval = 20 * 60
    static let defaultDuration: Int = 60
    static let snoozeInterval: TimeInterval = 5 * 60

    // MARK: Allowed ranges
    static let intervalMinutes: ClosedRange<Int> = 5...60
    static let durationSeconds: ClosedRange<Int> = 20...300

    /// Clamps a break interval (in seconds) into the supported range.
    static func clampedInterval(_ seconds: TimeInterval) -> TimeInterval {
        let minutes = (seconds / 60).rounded()
        let clamped = min(max(Int(minutes), intervalMinutes.lowerBound), intervalMinutes.upperBound)
        return TimeInterval(clamped * 60)
    }

    /// Clamps a break duration (in seconds) into the supported range.
    static func clampedDuration(_ seconds: Int) -> Int {
        min(max(seconds, durationSeconds.lowerBound), durationSeconds.upperBound)
    }

    /// Formats seconds as `MM:SS`.
    static func formatTime(_ totalSeconds: Int) -> String {
        let value = max(totalSeconds, 0)
        return String(format: "%02d:%02d", value / 60, value % 60)
    }
}
