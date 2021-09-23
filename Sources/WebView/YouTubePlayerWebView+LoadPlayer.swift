import Foundation

// MARK: - YouTubePlayerWebView+loadPlayer

extension YouTubePlayerWebView {
    
    /// Load the YouTubePlayer to this WKWebView
    /// - Returns: A Bool value if the YouTube player has been successfully loaded
    @discardableResult
    func loadPlayer() -> Bool {
        // Declare YouTubePlayer HTML
        let youTubePlayerHTML: YouTubePlayer.HTML
        do {
            // Try to initialize YouTubePlayer HTML
            youTubePlayerHTML = try .init(
                options: .init(
                    player: self.player,
                    originURL: self.originURL
                )
            )
        } catch {
            // Send setup failed error and return out of function
            self.playerStateSubject.send(.error(.setupFailed))
            // Return false as setup has failed
            return false
        }
        #if !os(macOS)
        // Update user interaction enabled state.
        // If no configuration is provided `true` value will be used
        self.isUserInteractionEnabled = self.player.configuration.isUserInteractionEnabled ?? true
        #endif
        // Load HTML string
        self.loadHTMLString(
            youTubePlayerHTML.contents,
            baseURL: self.originURL
        )
        // Return success
        return true
    }
    
}
