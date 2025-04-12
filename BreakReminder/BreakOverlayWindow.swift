import Cocoa
import SwiftUI

class BreakOverlayWindow: NSWindow {
    init(reminder: BreakReminder = BreakReminder.shared) {
        let screen = NSScreen.main!
        let rect = screen.frame

        super.init(
            contentRect: rect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        // Set level higher than regular windows but lower than system dialogs
        self.level = .floating
        
        // Configure window appearance
        self.isOpaque = false
        self.backgroundColor = NSColor.clear // Use clear to let the SwiftUI view handle the color
        self.hasShadow = false
        
        // Configure window behavior
        self.ignoresMouseEvents = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
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
    
    // Override to allow becoming key window
    override var canBecomeKey: Bool {
        return true
    }
    
    // Override to allow becoming main window
    override var canBecomeMain: Bool {
        return true
    }
}
