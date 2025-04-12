import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    private var reminder: BreakReminder?

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
        menu.addItem(NSMenuItem(title: "Open Settings...", action: #selector(openSystemSettings), keyEquivalent: ","))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApp.terminate), keyEquivalent: "q"))

        statusItem?.menu = menu
    }
    
    @objc func takeBreakNow() {
        reminder?.showOverlay()
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
