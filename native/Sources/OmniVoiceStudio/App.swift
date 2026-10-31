import SwiftUI

@main
struct OmniVoiceApp: App {
    var body: some Scene {
        WindowGroup {
            ShellView()
        }
#if os(macOS)
        .windowStyle(.automatic)
#endif
    }
}
