import Cocoa
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var statusItem: NSStatusItem?
    private var reminder: BreakReminder { BreakReminder.shared }
    private var preferencesWindow: NSWindow?
    private var aboutWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Menu bar only: no Dock icon. (Also set via LSUIElement in the build settings.)
        NSApp.setActivationPolicy(.accessory)

        setupStatusItem()
        reminder.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        reminder.stop()
    }

    // MARK: - Menu bar

    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            let image = NSImage(systemSymbolName: "eye", accessibilityDescription: "Break Reminder")
            image?.isTemplate = true // adapts to light / dark menu bars
            button.image = image
        }

        let menu = NSMenu()
        menu.addItem(makeItem("Take a Break Now", #selector(takeBreakNow), key: "b"))
        menu.addItem(.separator())
        menu.addItem(makeItem("Preferences...", #selector(openPreferences), key: ","))
        menu.addItem(makeItem("About Break Reminder", #selector(openAbout)))
        menu.addItem(.separator())

        let quit = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quit.target = NSApp
        menu.addItem(quit)

        item.menu = menu
        statusItem = item
    }

    private func makeItem(_ title: String, _ action: Selector, key: String = "") -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        return item
    }

    // MARK: - Actions

    @objc private func takeBreakNow() {
        reminder.showOverlay()
    }

    @objc private func openPreferences() {
        if preferencesWindow == nil {
            preferencesWindow = makeWindow(
                title: "Break Reminder Preferences",
                content: PreferencesView().environmentObject(reminder)
            )
        }
        show(preferencesWindow)
    }

    @objc private func openAbout() {
        if aboutWindow == nil {
            aboutWindow = makeWindow(title: "About Break Reminder", content: AboutView())
        }
        show(aboutWindow)
    }

    // MARK: - Windows

    private func makeWindow<Content: View>(title: String, content: Content) -> NSWindow {
        let window = NSWindow(
            contentRect: .zero,
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = title
        window.contentViewController = NSHostingController(rootView: content)
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.center()
        return window
    }

    private func show(_ window: NSWindow?) {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // Drop closed windows so they are rebuilt (with fresh state) next time.
    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        if window === preferencesWindow { preferencesWindow = nil }
        if window === aboutWindow { aboutWindow = nil }
    }
}
