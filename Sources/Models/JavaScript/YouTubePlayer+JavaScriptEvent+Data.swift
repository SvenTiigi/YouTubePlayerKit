import Foundation

// MARK: - YouTubePlayer+JavaScriptEvent+Data

public extension YouTubePlayer.JavaScriptEvent {
    
    /// A YouTube player JavaScript event data payload.
    struct Data: Hashable, Sendable {
        
        // MARK: Properties
        
        /// The value.
        public let value: String
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer/JavaScriptEvent/Data``
        /// - Parameter value: The value
        public init(
            value: String
        ) {
            self.value = value
        }
        
    }
    
}

// MARK: - Convenience Initializer

public extension YouTubePlayer.JavaScriptEvent.Data {
    
    /// Creates a new instance of ``YouTubePlayer/JavaScriptEvent/Data``
    /// - Parameter urlQueryItem: The url query item.
    init?(
        urlQueryItem: URLQueryItem
    ) {
        // Verify value of query item is available and is not empty and not equal to "null"
        guard let value = urlQueryItem.value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty,
              value.lowercased() != "null" else {
            // Otherwise return out of function
            return nil
        }
        // Initialize with value
        self.init(value: value)
    }
    
}

// MARK: - Codable

extension YouTubePlayer.JavaScriptEvent.Data: Codable {
    
    /// Creates a new instance of ``YouTubePlayer/JavaScriptEvent/Data``
    /// - Parameter decoder: The decoder.
    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.singleValueContainer()
        self.init(
            value: try container.decode(String.self)
        )
    }
    
    /// Encode.
    /// - Parameter encoder: The encoder.
    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
    
}

extension YouTubePlayer.JavaScriptEvent.Data: CustomStringConvertible {
    
    public var description: String {
        self.value
    }
    
}

public extension YouTubePlayer.JavaScriptEvent.Data {
    
    func value<T: LosslessStringConvertible>(
        as type: T.Type
    ) -> T? {
        .init(self.value)
    }
    
}

public extension YouTubePlayer.JavaScriptEvent.Data {
    
    func jsonValue<D: Decodable>(
        as type: D.Type,
        jsonDecoder: JSONDecoder = .init()
    ) throws -> D {
        try jsonDecoder.decode(
            D.self,
            from: .init(self.value.utf8)
        )
    }
    
}
