import Foundation

// MARK: - YouTubePlayer+HTML

extension YouTubePlayer {
    
    /// The YouTubePlayer HTML
    struct HTML: Hashable {
        
        /// The HTML contents
        let contents: String
        
    }
    
}

// MARK: - HTML+init

extension YouTubePlayer.HTML {
    
    /// Creates a new instance of `YouTubePlayer.HTML` if available
    /// - Parameters:
    ///   - options: The YouTubePlayer Options
    ///   - bundle: The Bundle. Default value `.module`
    init?(
        options: YouTubePlayer.Options,
        from bundle: Bundle = .module
    ) {
        // Try to retrieve HTML contents
        let html = bundle.url(
            forResource: "YouTubePlayer",
            withExtension: "html"
        )
        .flatMap { url in
            try? String(
                contentsOf: url,
                encoding: .utf8
            )
        }
        // Verify HTML contents is available
        guard var html = html else {
            // Otherwise return nil
            return nil
        }
        // Replace Tokenizer with Options
        html = html.replacingOccurrences(
            of: "YOUTUBE_PLAYER_CONFIGURATION",
            with: options.json
        )
        // Initialize HTML contents
        self.contents = html
    }
    
}
