import AppKit
import SwiftUI

/// Shows the break overlay on every connected screen and tears it down again.
///
/// The controller owns the countdown and the presentation options (hidden Dock
/// and menu bar), so everything is restored in exactly one place no matter how
/// the break ends.
@MainActor
final class BreakOverlayController {
    private let session: BreakSession
    private let onFinish: (BreakOutcome) -> Void

    private var windows: [BreakOverlayWindow] = []
    private var savedPresentationOptions: NSApplication.PresentationOptions = []
    private var observers: [NSObjectProtocol] = []
    private var isFinished = false

    init(duration: Int, onFinish: @escaping (BreakOutcome) -> Void) {
        self.onFinish = onFinish
        var completion: (() -> Void)?
        self.session = BreakSession(duration: duration) { completion?() }
        completion = { [weak self] in self?.finish(.completed) }
    }

    func present() {
        savedPresentationOptions = NSApplication.shared.presentationOptions
        buildWindows()
        applyPresentationOptions()
        NSApp.activate(ignoringOtherApps: true)
        session.start()

        // Keep the overlay correct if displays are plugged in / removed, or if
        // the app is re-activated by something else.
        let center = NotificationCenter.default
        observers.append(center.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.rebuildWindows() }
        })
        observers.append(center.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.applyPresentationOptions() }
        })
    }

    func bringToFront() {
        NSApp.activate(ignoringOtherApps: true)
        windows.first(where: { $0.isMainScreenWindow })?.makeKeyAndOrderFront(nil)
    }

    /// Ends the break. Safe to call more than once.
    func finish(_ outcome: BreakOutcome) {
        guard !isFinished else { return }
        isFinished = true

        session.stop()
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
        observers.removeAll()

        windows.forEach { $0.close() }
        windows.removeAll()
        NSApplication.shared.presentationOptions = savedPresentationOptions

        onFinish(outcome)
    }

    // MARK: - Windows

    private func buildWindows() {
        let screens = NSScreen.screens
        let mainScreen = NSScreen.main ?? screens.first
        windows = screens.map { screen in
            let window = BreakOverlayWindow(screen: screen)
            window.isMainScreenWindow = (screen == mainScreen)
            window.onEscape = { [weak self] in self?.finish(.skipped) }
            window.contentView = NSHostingView(rootView: BreakOverlayView(
                session: session,
                showsControls: window.isMainScreenWindow,
                onSnooze: { [weak self] in self?.finish(.snoozed) },
                onSkip: { [weak self] in self?.finish(.skipped) }
            ))
            return window
        }

        for window in windows {
            if window.isMainScreenWindow {
                window.makeKeyAndOrderFront(nil)
            } else {
                window.orderFrontRegardless()
            }
        }
    }

    private func rebuildWindows() {
        guard !isFinished else { return }
        windows.forEach { $0.close() }
        windows.removeAll()
        buildWindows()
        applyPresentationOptions()
    }

    private func applyPresentationOptions() {
        guard !isFinished else { return }
        NSApplication.shared.presentationOptions = [.hideMenuBar, .hideDock]
    }
}
