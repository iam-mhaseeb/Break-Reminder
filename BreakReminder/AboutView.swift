import SwiftUI

struct AboutView: View {
    private static let email = "hello@muhammadhaseeb.me"
    private static let website = "https://muhammadhaseeb.me"

    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            // A copy, so resizing it never changes the shared application icon.
            Image(nsImage: (NSApp.applicationIconImage.copy() as? NSImage) ?? NSImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 128, height: 128)
                .padding(.top, 12)
                .accessibilityHidden(true)

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

                Link("muhammadhaseeb.me", destination: URL(string: Self.website)!)

                Link(Self.email, destination: URL(string: "mailto:\(Self.email)")!)
                    .padding(.bottom, 12)
            }
        }
        .padding(25)
        .frame(width: 400, height: 450)
    }
}

#Preview {
    AboutView()
}
