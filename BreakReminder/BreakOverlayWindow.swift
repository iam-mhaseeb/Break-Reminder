import Cocoa
import SwiftUI

class BreakOverlayWindow: NSWindow {
    init(reminder: BreakReminder = BreakReminder.shared) {
        let screen = NSScreen.main!
        let screenFrame = screen.frame

        super.init(
            contentRect: screenFrame, // Use the full screen frame, not just visible frame
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        // Set highest possible level to appear above everything
        self.level = .screenSaver // Higher than statusBar, will cover everything
        
        // Configure window appearance
        self.isOpaque = false
        self.backgroundColor = NSColor.clear // Use clear to let the SwiftUI view handle the color
        self.hasShadow = false
        
        // Configure window behavior
        self.ignoresMouseEvents = false
        // Set collection behavior to cover full screen
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .fullScreenPrimary]
        
        // Ensure the window covers the entire screen including menu bar and dock
        self.setFrame(screenFrame, display: true)
        
        // Set the presentation options to hide the menu bar
        NSApplication.shared.presentationOptions.insert(.autoHideMenuBar)
        
        // Configure accessibility
        self.title = "Break Reminder" // For accessibility

        let hostingView = NSHostingView(rootView: BreakOverlayView(window: self, reminder: reminder))
        self.contentView = hostingView
        
        // Show the window without making it key initially
        self.orderFront(nil)
        
        // Make key after a short delay to ensure it's in front
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.makeKeyAndOrderFront(nil)
        }
    }
    
    // Restore presentation options when window is closed
    override func close() {
        // Reset presentation options to default
        NSApplication.shared.presentationOptions.remove(.autoHideMenuBar)
        super.close()
    }
    
    // Override to allow becoming key window
    override var canBecomeKey: Bool {
        return true
    }
    
    // Override to allow becoming main window
    override var canBecomeMain: Bool {
        return true
    }
}
