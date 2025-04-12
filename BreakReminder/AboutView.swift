import SwiftUI

struct AboutView: View {
    // Get app version from the bundle
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Image(nsImage: NSImage(named: NSImage.applicationIconName) ?? NSImage())
                .resizable()
                .frame(width: 64, height: 64)
                .padding(.top, 12)
            
            Text("Break Reminder")
                .font(.title)
                .bold()
            
            Text("Version \(appVersion) (\(buildNumber))")
                .font(.subheadline)
            
            Divider()
            
            Text("A simple app that reminds you to take breaks regularly to reduce eye strain and improve productivity.")
                .font(.body)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
            
            Divider()
            
            VStack(alignment: .center, spacing: 8) {
                Text("Created by Muhammad Haseeb")
                    .font(.subheadline)
                
                Button("mhaseeb.inbox@gmail.com") {
                    if let url = URL(string: "mailto:mhaseeb.inbox@gmail.com") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.link)
                .padding(.bottom, 12)
            }
        }
        .padding(25)
        .frame(width: 350, height: 350)
    }
}

#Preview {
    AboutView()
} 
