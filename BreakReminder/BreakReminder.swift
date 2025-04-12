import Foundation
import UserNotifications

class BreakReminder: ObservableObject {
    static let shared = BreakReminder()
    
    private var timer: Timer?
    @Published var interval: TimeInterval
    
    // Keep track of active overlay window
    private var overlayWindow: BreakOverlayWindow?
    
    init() {
        // Default to 20 minutes (1200 seconds) if no value is stored
        let storedInterval = UserDefaults.standard.double(forKey: "breakInterval")
        self.interval = storedInterval > 0 ? storedInterval : 1200
    }

    func start() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }

        stop() // Stop any existing timer first
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.showOverlay()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func updateInterval(_ newInterval: TimeInterval) {
        interval = newInterval
        UserDefaults.standard.set(newInterval, forKey: "breakInterval")
        stop()
        start()
    }

    func snooze() {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.showOverlay()
            self.start()
        }
    }

    func showOverlay() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Check if there's already an active overlay window
            if let existingWindow = self.overlayWindow, existingWindow.isVisible {
                // Bring existing window to front instead of creating a new one
                existingWindow.makeKeyAndOrderFront(nil)
                return
            }
            
            // Close any existing window first
            self.overlayWindow?.close()
            
            // Create a new window
            self.overlayWindow = BreakOverlayWindow(reminder: self)
        }
    }
}
