import SwiftUI
import YouTubePlayerKit

// MARK: - App

/// The App
@main
struct App {
    
    /// Creates a new instance of ``App``
    @MainActor
    init() {
        YouTubePlayer.isLoggingEnabled = true
    }
    
}

// MARK: - SwiftUI.App

extension App: SwiftUI.App {
    
    /// The content and behavior of the app
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
}
