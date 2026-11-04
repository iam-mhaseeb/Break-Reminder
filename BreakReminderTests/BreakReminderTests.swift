import Foundation
import Testing
@testable import BreakReminder

/// Returns an isolated `UserDefaults` so tests never touch the real preferences.
private func makeDefaults() -> UserDefaults {
    let name = "BreakReminderTests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defaults.removePersistentDomain(forName: name)
    return defaults
}

struct BreakSettingsTests {
    @Test func clampsIntervalToSupportedRange() {
        #expect(BreakSettings.clampedInterval(60) == 5 * 60)
        #expect(BreakSettings.clampedInterval(20 * 60) == 20 * 60)
        #expect(BreakSettings.clampedInterval(10 * 3600) == 60 * 60)
    }

    @Test func clampsDurationToSupportedRange() {
        #expect(BreakSettings.clampedDuration(1) == 20)
        #expect(BreakSettings.clampedDuration(60) == 60)
        #expect(BreakSettings.clampedDuration(9_999) == 300)
    }

    @Test func formatsTimeAsMinutesAndSeconds() {
        #expect(BreakSettings.formatTime(60) == "01:00")
        #expect(BreakSettings.formatTime(5) == "00:05")
        #expect(BreakSettings.formatTime(0) == "00:00")
        #expect(BreakSettings.formatTime(-3) == "00:00")
    }
}

@MainActor
struct BreakReminderTests {
    @Test func usesDefaultsWhenNothingIsStored() {
        let reminder = BreakReminder(defaults: makeDefaults())
        #expect(reminder.interval == BreakSettings.defaultInterval)
        #expect(reminder.breakDuration == BreakSettings.defaultDuration)
    }

    @Test func loadsAndClampsStoredValues() {
        let defaults = makeDefaults()
        defaults.set(10 * 60.0, forKey: BreakSettings.intervalKey)
        defaults.set(30, forKey: BreakSettings.durationKey)
        let reminder = BreakReminder(defaults: defaults)
        #expect(reminder.interval == 10 * 60)
        #expect(reminder.breakDuration == 30)

        defaults.set(1.0, forKey: BreakSettings.intervalKey)
        defaults.set(100_000, forKey: BreakSettings.durationKey)
        let clamped = BreakReminder(defaults: defaults)
        #expect(clamped.interval == 5 * 60)
        #expect(clamped.breakDuration == 300)
    }

    @Test func updateSettingsPersistsValues() {
        let defaults = makeDefaults()
        let reminder = BreakReminder(defaults: defaults)
        reminder.updateSettings(interval: 30 * 60, breakDuration: 90)

        #expect(reminder.interval == 30 * 60)
        #expect(reminder.breakDuration == 90)
        #expect(defaults.double(forKey: BreakSettings.intervalKey) == 30 * 60)
        #expect(defaults.integer(forKey: BreakSettings.durationKey) == 90)
    }

    @Test func startSchedulesNextBreakOneIntervalAway() throws {
        let reminder = BreakReminder(defaults: makeDefaults())
        reminder.start()
        defer { reminder.stop() }

        let next = try #require(reminder.nextBreakDate)
        let delay = next.timeIntervalSinceNow
        #expect(delay > reminder.interval - 5)
        #expect(delay <= reminder.interval)
    }

    @Test func snoozeReschedulesFiveMinutesAway() throws {
        let reminder = BreakReminder(defaults: makeDefaults())
        reminder.start()
        defer { reminder.stop() }

        reminder.snooze()
        let next = try #require(reminder.nextBreakDate)
        let delay = next.timeIntervalSinceNow
        #expect(delay > BreakSettings.snoozeInterval - 5)
        #expect(delay <= BreakSettings.snoozeInterval)
    }

    @Test func stopClearsTheSchedule() {
        let reminder = BreakReminder(defaults: makeDefaults())
        reminder.start()
        reminder.stop()
        #expect(reminder.nextBreakDate == nil)
    }

    @Test func changingSettingsWhileRunningReschedules() throws {
        let reminder = BreakReminder(defaults: makeDefaults())
        reminder.start()
        defer { reminder.stop() }

        reminder.updateSettings(interval: 5 * 60, breakDuration: 60)
        let delay = try #require(reminder.nextBreakDate).timeIntervalSinceNow
        #expect(delay <= 5 * 60)
    }
}
