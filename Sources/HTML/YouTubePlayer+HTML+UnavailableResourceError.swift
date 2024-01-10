import Foundation

// MARK: - YouTubePlayer+HTML+UnavailableResourceError

extension YouTubePlayer.HTML {
    
    /// An unavailable Resource Error
    struct UnavailableResourceError: Swift.Error, Codable, Hashable, Sendable {
        
        /// The Resource that is unavailable
        let resource: Resource
        
    }
    
}
