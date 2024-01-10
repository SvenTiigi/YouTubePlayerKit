import Foundation

// MARK: - YouTubePlayer+HTML

extension YouTubePlayer {
    
    /// The YouTubePlayer HTML
    struct HTML: Codable, Hashable, Sendable {
        
        /// The HTML contents
        let contents: String
        
    }
    
}

// MARK: - HTML+init

extension YouTubePlayer.HTML {
    
    /// Creates a new instance of `YouTubePlayer.HTML` or throws an error
    /// - Parameters:
    ///   - options: The YouTubePlayer Options
    ///   - bundle: The Bundle. Default value `.module`
    ///   - resource: The Resource. Default value `.default`
    init(
        options: YouTubePlayer.Options,
        bundle: Bundle = .module,
        resource: Resource = .default
    ) throws {
        // Verify URL for Resource is available
        guard let resourceURL = bundle.url(
            forResource: resource.fileName,
            withExtension: resource.fileExtension
        ) else {
            // Otherwise throw an UnavailableResourceError
            throw UnavailableResourceError(
                resource: resource
            )
        }
        // Retrieve the HTML contents from the resource url
        var htmlContents = try String(
            contentsOf: resourceURL,
            encoding: .utf8
        )
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
