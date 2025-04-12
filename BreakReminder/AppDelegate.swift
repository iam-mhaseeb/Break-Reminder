import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    private var reminder: BreakReminder?
    private var preferencesWindow: NSWindow?
    private var aboutWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Require macOS 13 or newer
        guard #available(macOS 13.0, *) else {
            let alert = NSAlert()
            alert.messageText = "Unsupported macOS Version"
            alert.informativeText = "Break Reminder requires macOS 13 (Ventura) or newer."
            alert.alertStyle = .critical
            alert.addButton(withTitle: "Quit")
            alert.runModal()
            NSApp.terminate(nil)
            return
        }
        
        // Get the same instance that's used in the SwiftUI environment
        reminder = BreakReminder.shared
        reminder?.start()
        
        // Hide the dock icon and set as accessory app
        NSApp.setActivationPolicy(.accessory)
        
        // Close any automatically opened windows
        for window in NSApp.windows {
            window.close()
        }

        // Set up the menu bar item
        setupStatusItem()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        reminder?.stop()
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "eye", accessibilityDescription: "Break Reminder")
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Take a Break Now", action: #selector(takeBreakNow), keyEquivalent: "b"))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(openPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "About Break Reminder", action: #selector(openAbout), keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApp.terminate), keyEquivalent: "q"))

        statusItem?.menu = menu
    }
    
    @objc func takeBreakNow() {
        reminder?.showOverlay()
    }

    @objc func openPreferences() {
        // Create and show preferences window if it doesn't exist
        if preferencesWindow == nil {
            let contentView = PreferencesView()
                .environmentObject(BreakReminder.shared)
            
            // Create a hosting controller for our SwiftUI view
            let hostingController = NSHostingController(rootView: contentView)
            
            // Configure the window
            preferencesWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 350, height: 220),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            
            preferencesWindow?.title = "Break Reminder Preferences"
            preferencesWindow?.contentViewController = hostingController
            preferencesWindow?.center()
            preferencesWindow?.isReleasedWhenClosed = false
            
            // Create notification observer for when the window is closed
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(preferencesWindowWillClose),
                name: NSWindow.willCloseNotification,
                object: preferencesWindow
            )
        }
        
        // Show and activate window
        preferencesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func preferencesWindowWillClose(notification: Notification) {
        // Optional: Handle window close event if needed
    }
    
    @objc func openAbout() {
        // Create and show about window if it doesn't exist
        if aboutWindow == nil {
            let contentView = AboutView()
            
            // Create a hosting controller for our SwiftUI view
            let hostingController = NSHostingController(rootView: contentView)
            
            // Configure the window
            aboutWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 380, height: 350),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            
            aboutWindow?.title = "About Break Reminder"
            aboutWindow?.contentViewController = hostingController
            aboutWindow?.center()
            aboutWindow?.isReleasedWhenClosed = false
            
            // Create notification observer for when the window is closed
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(aboutWindowWillClose),
                name: NSWindow.willCloseNotification,
                object: aboutWindow
            )
        }
        
        // Show and activate window
        aboutWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func aboutWindowWillClose(notification: Notification) {
        // Optional: Handle window close event if needed
    }
    
    @objc func openSystemSettings() {
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
