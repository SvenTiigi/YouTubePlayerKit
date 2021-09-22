import Foundation

// MARK: - YouTubePlayerWebView+loadPlayer

extension YouTubePlayerWebView {
    
    /// Load Player
    /// - Returns: A Bool value if the YouTube player was successfully loaded
    @discardableResult
    func loadPlayer() -> Bool {
        // Set YouTubePlayerAPI on current Player
        self.player.api = self
        // Update user interaction enabled state.
        // If no configuration is provided `true` value will be used
        self.isUserInteractionEnabled = self.player.configuration.isUserInteractionEnabled ?? true
        // Try to initialize YouTubePlayer Options
        guard let youTubePlayerOptions = try? YouTubePlayer.Options(
            player: self.player,
            originURL: self.originURL
        ) else {
            // Otherwise return failure
            return false
        }
        // Verify YouTube Player HTML is available
        guard let youTubePlayerHTML = YouTubePlayer.HTML(
            options: youTubePlayerOptions
        ) else {
            // Otherwise return failure
            return false
        }
        // Load HTML string
        self.loadHTMLString(
            youTubePlayerHTML.contents,
            baseURL: self.originURL
        )
        // Return success
        return true
    }
    
}
