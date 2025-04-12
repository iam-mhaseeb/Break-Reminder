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
        
        // Register for activation notifications - helps with handling focus issues
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc func applicationDidBecomeActive(_ notification: Notification) {
        // When app becomes active, if there's an overlay window visible,
        // reapply the presentation options to ensure menu bar and dock stay hidden
        for window in NSApp.windows {
            if let breakWindow = window as? BreakOverlayWindow, breakWindow.isVisible {
                // Force the window to the front and reapply key status
                breakWindow.makeKeyAndOrderFront(nil)
                // Use consistent presentation options (no mixed auto/non-auto options)
                NSApplication.shared.presentationOptions = [.hideMenuBar, .hideDock]
                break
            }
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        reminder?.stop()
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            // First try to load from app icon assets
            if let iconImage = NSImage(named: "AppIcon") {
                // Resize the image to fit in the menu bar
                iconImage.size = NSSize(width: 18, height: 18)
                button.image = iconImage
            } 
            // Then try to load from named assets
            else if let iconImage = NSImage(named: "icon") {
                iconImage.size = NSSize(width: 18, height: 18)
                button.image = iconImage
            }
            // Finally try loading from bundle resources
            else if let iconPath = Bundle.main.path(forResource: "icon", ofType: "png"),
                    let iconImage = NSImage(contentsOfFile: iconPath) {
                iconImage.size = NSSize(width: 18, height: 18)
                button.image = iconImage
            }
            // Fallback to system symbol if custom icon can't be loaded
            else {
                button.image = NSImage(systemSymbolName: "eye", accessibilityDescription: "Break Reminder")
            }
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
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 450),
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
            let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.haseeb.BreakReminder"
            
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
