import Foundation

// MARK: - YouTubePlayer+JavaScriptEvent

public extension YouTubePlayer {
    
    /// A YouTubePlayer JavaScriptEvent
    struct JavaScriptEvent: Codable, Hashable, Sendable {
        
        // MARK: Properties
        
        /// The name.
        public var name: Name
        
        /// The data.
        public var data: Data?
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer.JavaScriptEvent``
        /// - Parameters:
        ///   - name: The name.
        ///   - data: The data. Default value `nil`
        public init(
            name: Name,
            data: Data? = nil
        ) {
            self.name = name
            self.data = data
        }
        
    }
    
}

// MARK: - CustomStringConvertible

extension YouTubePlayer.JavaScriptEvent: CustomStringConvertible {
    
    /// A textual representation of this instance.
    public var description: String {
        """
        Name: \(self.name.rawValue)
        Data: \(self.data?.value ?? "nil")
        """
    }
    
}
