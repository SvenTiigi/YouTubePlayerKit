import Foundation

// MARK: - YouTubePlayer+HTML+UnavailableResourceError

extension YouTubePlayer.HTML {
    
    /// An unavailable Resource Error
    struct UnavailableResourceError: Swift.Error, Codable, Hashable {
        
        /// The Resource that is unavailable
        let resource: Resource
        
    }
    
}
