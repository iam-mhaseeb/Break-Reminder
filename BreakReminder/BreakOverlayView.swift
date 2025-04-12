import SwiftUI

struct BreakOverlayView: View {
    let window: NSWindow
    let reminder: BreakReminder
    
    // Timer state variables
    @State private var remainingSeconds = 60 // 1 minute countdown
    @State private var timer: Timer? = nil
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Black background covering entire screen
                Color.black.opacity(0.7)
                    .ignoresSafeArea(.all)
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .position(x: geometry.size.width/2, y: geometry.size.height/2)

                VStack(spacing: 30) {
                    Text("Time to take a break 👀")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Look away from your screen for a while")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    // Countdown timer display
                    VStack(spacing: 5) {
                        Text("\(formatTime(remainingSeconds))")
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Text("Break will end automatically")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.vertical, 10)
                    
                    // Progress bar
                    ProgressBar(progress: Double(60 - remainingSeconds) / 60.0)
                        .frame(height: 8)
                        .padding(.horizontal, 40)
                    
                    HStack(spacing: 20) {
                        // Snooze button
                        CustomButton(
                            title: "Snooze 5 min",
                            backgroundColor: Color.blue.opacity(0.8),
                            action: {
                                stopTimer()
                                reminder.snooze()
                                window.close()
                            }
                        )
                        .help("Snooze for 5 minutes")

                        // Skip button
                        CustomButton(
                            title: "Skip",
                            backgroundColor: Color.gray.opacity(0.8),
                            action: {
                                stopTimer()
                                window.close()
                            }
                        )
                        .help("Skip this break")
                    }
                }
                .padding(40)
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height,
                alignment: .center
            )
            .ignoresSafeArea(.all)
        }
        .ignoresSafeArea(.all) // Ignore safe areas to extend to the edge of the screen
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    // Start the countdown timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                stopTimer()
                window.close()
            }
        }
    }
    
    // Stop and invalidate the timer
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // Format seconds into MM:SS
    private func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// Progress bar for visual timer representation
struct ProgressBar: View {
    var progress: Double // 0.0 to 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color.white.opacity(0.2))
                    .cornerRadius(5)
                
                Rectangle()
                    .frame(width: geometry.size.width * CGFloat(progress))
                    .foregroundColor(Color.green.opacity(0.8))
                    .cornerRadius(5)
                    .animation(.linear, value: progress)
            }
        }
    }
}

// Custom button that ensures the entire area is clickable
struct CustomButton: View {
    let title: String
    let backgroundColor: Color
    let action: () -> Void
    
    @State private var isHovered = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .frame(minWidth: 120, minHeight: 44)
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isPressed ? backgroundColor.opacity(0.7) : 
                              isHovered ? backgroundColor.opacity(0.9) : backgroundColor)
                )
                .shadow(color: .black.opacity(0.3), 
                        radius: isPressed ? 2 : 4, 
                        x: 0, 
                        y: isPressed ? 1 : 2)
                .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle to have full control
        .contentShape(Rectangle()) // Ensures the entire area is clickable
        .onHover { hovering in
            isHovered = hovering
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
