import Foundation

// MARK: - YouTubePlayer+HTML+Resource

extension YouTubePlayer.HTML {
    
    /// A YouTubePlayer HTML Resource
    struct Resource: Codable, Hashable, Sendable {
        
        /// The file name
        let fileName: String
        
        /// The file extension
        let fileExtension: String
        
    }
    
}

// MARK: - Resource+default

extension YouTubePlayer.HTML.Resource {
    
    /// The default Resource
    static let `default` = Self(
        fileName: "YouTubePlayer",
        fileExtension: "html"
    )
    
}
