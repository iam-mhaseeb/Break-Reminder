import AppKit

/// A borderless, screen-covering window that sits above everything else.
final class BreakOverlayWindow: NSWindow {
    /// Called when the user presses Esc.
    var onEscape: (() -> Void)?
    /// Only the window on the main screen shows the Snooze / Skip buttons.
    var isMainScreenWindow = false

    init(screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        // The controller owns the window; AppKit must not release it on close.
        isReleasedWhenClosed = false

        level = .screenSaver
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        ignoresMouseEvents = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        title = "Break Reminder" // for accessibility
        setFrame(screen.frame, display: true)
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Esc
            onEscape?()
        } else {
            super.keyDown(with: event)
        }
    }

    override func cancelOperation(_ sender: Any?) {
        onEscape?()
    }
}
