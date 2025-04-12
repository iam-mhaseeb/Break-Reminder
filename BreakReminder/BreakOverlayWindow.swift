import Cocoa
import SwiftUI

class BreakOverlayWindow: NSWindow {
    // Store the original presentation options to restore them properly
    private var originalPresentationOptions: NSApplication.PresentationOptions?
    
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
        
        // Store original presentation options before modifying them
        originalPresentationOptions = NSApplication.shared.presentationOptions
        
        // Set presentation options to ensure menu bar and dock are hidden
        // Use only hideMenuBar and hideDock (not the auto variants) to avoid the exception
        NSApplication.shared.presentationOptions = [.hideMenuBar, .hideDock]
        
        // Configure accessibility
        self.title = "Break Reminder" // For accessibility

        let hostingView = NSHostingView(rootView: BreakOverlayView(window: self, reminder: reminder))
        self.contentView = hostingView
        
        // Show the window without making it key initially
        self.orderFront(nil)
        
        // Make key after a short delay to ensure it's in front
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.makeKeyAndOrderFront(nil)
            
            // Force hiding again after a short delay to handle edge cases
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                // Only apply if window is still open
                if self?.isVisible == true {
                    NSApplication.shared.presentationOptions = [.hideMenuBar, .hideDock]
                }
            }
        }
    }
    
    // Restore presentation options when window is closed
    override func close() {
        // Properly restore the original presentation options
        if let originalOptions = originalPresentationOptions {
            NSApplication.shared.presentationOptions = originalOptions
        } else {
            // If for some reason original options weren't captured, reset to defaults
            NSApplication.shared.presentationOptions = []
        }
        
        super.close()
    }
    
    // Handle application becoming active/inactive to maintain hiding
    override func becomeKey() {
        super.becomeKey()
        // Re-apply hiding when window becomes key
        NSApplication.shared.presentationOptions = [.hideMenuBar, .hideDock]
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
