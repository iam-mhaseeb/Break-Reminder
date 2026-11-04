import Foundation
import Combine

/// Countdown state for one break. A single session is shared by the overlay
/// windows on every screen so they always show the same time.
@MainActor
final class BreakSession: ObservableObject {
    let duration: Int
    @Published private(set) var remainingSeconds: Int

    private var timer: Timer?
    private let onComplete: () -> Void

    init(duration: Int, onComplete: @escaping () -> Void) {
        self.duration = duration
        self.remainingSeconds = duration
        self.onComplete = onComplete
    }

    /// 0.0 at the start of the break, 1.0 when it is over.
    var progress: Double {
        guard duration > 0 else { return 1 }
        return Double(duration - remainingSeconds) / Double(duration)
    }

    func start() {
        stop()
        let newTimer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard timer != nil else { return }
        if remainingSeconds > 0 {
            remainingSeconds -= 1
        }
        if remainingSeconds == 0 {
            stop()
            onComplete()
        }
    }
}
