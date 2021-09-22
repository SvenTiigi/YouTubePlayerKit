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
    ///   - resource: The Resource. Default value `.default`
    init?(
        options: YouTubePlayer.Options,
        bundle: Bundle = .module,
        resource: Resource = .default
    ) {
        // Try to retrieve HTML contents
        let html = bundle.url(
            forResource: resource.fileName,
            withExtension: resource.fileExtension
        )
        .flatMap { url in
            try? String(
                contentsOf: url,
                encoding: .utf8
            )
        }
        // Verify HTML contents is available
        guard var htmlContents = html else {
            // Otherwise return nil
            return nil
        }
        // Format HTML contents string
        // with YouTubePlayer Options JSON
        htmlContents = .init(
            format: htmlContents,
            options.json
        )
        // Initialize HTML contents
        self.contents = htmlContents
    }
    
}
