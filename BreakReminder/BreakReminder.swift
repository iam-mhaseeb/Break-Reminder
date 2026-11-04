import AppKit
import Combine

/// Why a break overlay went away.
enum BreakOutcome {
    case completed    // the countdown ran out
    case skipped      // the user pressed Skip / Esc
    case snoozed      // the user asked to be reminded again soon
    case interrupted  // the system went to sleep / locked, etc.
}

/// Schedules breaks and owns the overlay that is shown for them.
///
/// The next break is always measured from the moment the previous one ended
/// (or was skipped / snoozed), so manual breaks and snoozes never stack up with
/// an old schedule.
@MainActor
final class BreakReminder: ObservableObject {
    static let shared = BreakReminder()

    /// Seconds between breaks.
    @Published private(set) var interval: TimeInterval
    /// Seconds a break lasts.
    @Published private(set) var breakDuration: Int
    /// When the next break is due, or `nil` if nothing is scheduled.
    private(set) var nextBreakDate: Date?

    private enum SuspendReason: Hashable { case sleep, screensSleep, locked }

    private let defaults: UserDefaults
    private var timer: Timer?
    private var overlay: BreakOverlayController?
    private var isRunning = false
    private var suspendReasons = Set<SuspendReason>()
    private var observers: [(center: NotificationCenter, token: NSObjectProtocol)] = []

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let storedInterval = defaults.double(forKey: BreakSettings.intervalKey)
        self.interval = storedInterval > 0
            ? BreakSettings.clampedInterval(storedInterval)
            : BreakSettings.defaultInterval

        let storedDuration = defaults.integer(forKey: BreakSettings.durationKey)
        self.breakDuration = storedDuration > 0
            ? BreakSettings.clampedDuration(storedDuration)
            : BreakSettings.defaultDuration
    }

    // MARK: - Lifecycle

    func start() {
        isRunning = true
        observeSystemEvents()
        guard suspendReasons.isEmpty else { return }
        schedule(after: interval)
    }

    func stop() {
        isRunning = false
        cancelTimer()
        overlay?.finish(.interrupted)
    }

    // MARK: - Settings

    func updateSettings(interval newInterval: TimeInterval, breakDuration newDuration: Int) {
        interval = BreakSettings.clampedInterval(newInterval)
        breakDuration = BreakSettings.clampedDuration(newDuration)
        defaults.set(interval, forKey: BreakSettings.intervalKey)
        defaults.set(breakDuration, forKey: BreakSettings.durationKey)

        // Re-schedule with the new interval, unless a break is on screen right now
        // (it will schedule the next one when it ends).
        if isRunning, overlay == nil, suspendReasons.isEmpty {
            schedule(after: interval)
        }
    }

    // MARK: - Breaks

    func snooze() {
        guard isRunning, suspendReasons.isEmpty else { return }
        schedule(after: BreakSettings.snoozeInterval)
    }

    func showOverlay() {
        // Already showing one: just bring it forward.
        if let overlay {
            overlay.bringToFront()
            return
        }

        cancelTimer() // paused while the break is on screen
        let controller = BreakOverlayController(duration: breakDuration) { [weak self] outcome in
            self?.breakEnded(outcome)
        }
        overlay = controller
        controller.present()
    }

    private func breakEnded(_ outcome: BreakOutcome) {
        overlay = nil
        guard isRunning, suspendReasons.isEmpty else { return }
        switch outcome {
        case .snoozed:
            schedule(after: BreakSettings.snoozeInterval)
        case .completed, .skipped:
            schedule(after: interval)
        case .interrupted:
            break // the caller decides when to schedule again
        }
    }

    // MARK: - Timer

    private func schedule(after delay: TimeInterval) {
        cancelTimer()
        nextBreakDate = Date().addingTimeInterval(delay)
        let newTimer = Timer(timeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.timerFired()
            }
        }
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
    }

    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
        nextBreakDate = nil
    }

    private func timerFired() {
        timer = nil
        nextBreakDate = nil
        showOverlay()
    }

    // MARK: - Sleep, wake and screen lock

    private func observeSystemEvents() {
        guard observers.isEmpty else { return }

        let workspace = NSWorkspace.shared.notificationCenter
        let distributed = DistributedNotificationCenter.default()

        func add(_ center: NotificationCenter,
                 _ name: Notification.Name,
                 _ handler: @escaping @MainActor (BreakReminder) -> Void) {
            let token = center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in
                    guard let self else { return }
                    handler(self)
                }
            }
            observers.append((center, token))
        }

        add(workspace, NSWorkspace.willSleepNotification) { $0.suspend(.sleep) }
        add(workspace, NSWorkspace.didWakeNotification) { $0.resume(.sleep) }
        add(workspace, NSWorkspace.screensDidSleepNotification) { $0.suspend(.screensSleep) }
        add(workspace, NSWorkspace.screensDidWakeNotification) { $0.resume(.screensSleep) }
        add(distributed, Notification.Name("com.apple.screenIsLocked")) { $0.suspend(.locked) }
        add(distributed, Notification.Name("com.apple.screenIsUnlocked")) { $0.resume(.locked) }
    }

    private func suspend(_ reason: SuspendReason) {
        suspendReasons.insert(reason)
        cancelTimer()
        overlay?.finish(.interrupted)
    }

    private func resume(_ reason: SuspendReason) {
        suspendReasons.remove(reason)
        // The user was away: start a fresh interval rather than breaking right away.
        if isRunning, suspendReasons.isEmpty, overlay == nil {
            schedule(after: interval)
        }
    }
}
