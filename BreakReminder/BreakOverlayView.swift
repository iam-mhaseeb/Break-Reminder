import SwiftUI

struct BreakOverlayView: View {
    let window: NSWindow
    let reminder: BreakReminder
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                Text("Time to take a break 👀")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Look away from your screen for a while")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                
                HStack(spacing: 20) {
                    // Snooze button
                    CustomButton(
                        title: "Snooze 5 min",
                        backgroundColor: Color.blue.opacity(0.8),
                        action: {
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
                            window.close()
                        }
                    )
                    .help("Skip this break")
                }
            }
            .padding(40)
            .background(Color.black.opacity(0.5))
            .cornerRadius(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
