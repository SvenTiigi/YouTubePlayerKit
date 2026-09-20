import SwiftUI

// MARK: - App

/// The App
@main
struct App {}

// MARK: - SwiftUI.App

extension App: SwiftUI.App {
    
    /// The content and behavior of the app
    var body: some Scene {
        WindowGroup {
            if ProcessInfo.processInfo.environment["YOUTUBEPLAYERKIT_TESTING"] == "1" {
                // Provide an application lifecycle without starting the example's live player.
                Color.clear
            } else {
                ContentView()
            }
        }
    }
    
}
