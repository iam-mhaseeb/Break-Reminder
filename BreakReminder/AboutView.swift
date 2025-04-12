import SwiftUI

struct AboutView: View {
    // Get app version from the bundle
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            // Try multiple methods to load the app icon
            if let customIcon = loadAppIcon() {
                Image(nsImage: customIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 128, height: 128)
                    .padding(.top, 12)
            } else {
                // Fallback to system application icon
                Image(nsImage: NSImage(named: NSImage.applicationIconName) ?? NSImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 128, height: 128)
                    .padding(.top, 12)
            }
            
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
        .frame(width: 400, height: 450)
    }
    
    // Helper function to load the app icon from multiple sources
    private func loadAppIcon() -> NSImage? {
        // Try loading from asset catalog first
        if let iconFromAssets = NSImage(named: "AppIcon") {
            return iconFromAssets
        }
        
        // Try loading from bundle resources
        if let iconPath = Bundle.main.path(forResource: "icon", ofType: "png"),
           let iconFromFile = NSImage(contentsOfFile: iconPath) {
            return iconFromFile
        }
        
        // Try loading named image
        if let iconNamed = NSImage(named: "icon") {
            return iconNamed
        }
        
        // Try loading the highest resolution icon from the app bundle
        if let appIconSet = NSImage(named: NSImage.applicationIconName) {
            // Ensure we get the best representation
            let size = NSSize(width: 512, height: 512)
            appIconSet.size = size
            return appIconSet
        }
        
        return nil
    }
}

#Preview {
    AboutView()
} 
