import SwiftUI

struct BreakOverlayView: View {
    @ObservedObject var session: BreakSession
    /// `false` on secondary screens: they dim and show the countdown only.
    var showsControls: Bool = true
    var onSnooze: () -> Void
    var onSkip: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("Time to take a break 👀")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Text("Look away from your screen for a while")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))

                VStack(spacing: 5) {
                    Text(BreakSettings.formatTime(session.remainingSeconds))
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .accessibilityLabel("Break time remaining")
                        .accessibilityValue(BreakSettings.formatTime(session.remainingSeconds))

                    Text("Break will end automatically")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.vertical, 10)

                ProgressBar(progress: session.progress)
                    .frame(height: 8)
                    .padding(.horizontal, 40)
                    .accessibilityHidden(true)

                if showsControls {
                    HStack(spacing: 20) {
                        OverlayButton(title: "Snooze 5 min", color: .blue, action: onSnooze)
                            .help("Snooze for 5 minutes")

                        OverlayButton(title: "Skip", color: .gray, action: onSkip)
                            .keyboardShortcut(.cancelAction)
                            .help("Skip this break (Esc)")
                    }

                    Text("Press Esc to skip")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Progress bar for the break countdown.
struct ProgressBar: View {
    var progress: Double // 0.0 to 1.0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white.opacity(0.2))

                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.green.opacity(0.8))
                    .frame(width: geometry.size.width * CGFloat(min(max(progress, 0), 1)))
                    .animation(reduceMotion ? nil : .linear, value: progress)
            }
        }
    }
}

/// Button used on the overlay. The whole rounded rectangle is clickable.
struct OverlayButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .buttonStyle(OverlayButtonStyle(color: color))
    }
}

struct OverlayButtonStyle: ButtonStyle {
    let color: Color

    @State private var isHovered = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(minWidth: 120, minHeight: 44)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(configuration.isPressed ? 0.6 : (isHovered ? 0.95 : 0.8)))
            )
            .shadow(color: .black.opacity(0.3),
                    radius: configuration.isPressed ? 2 : 4,
                    x: 0,
                    y: configuration.isPressed ? 1 : 2)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1.0)
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .onHover { isHovered = $0 }
    }
}
