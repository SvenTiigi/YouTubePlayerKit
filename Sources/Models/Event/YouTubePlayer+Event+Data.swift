import Foundation

// MARK: - YouTubePlayer+Event+Data

public extension YouTubePlayer.Event {
    
    /// A YouTube player event data payload.
    struct Data: Hashable, Sendable {
        
        // MARK: Properties
        
        /// The value.
        public let value: String
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer/Event/Data``
        /// - Parameter value: The value
        public init(
            value: String
        ) {
            self.value = value
        }
        
    }
    
}

// MARK: - Convenience Initializer

public extension YouTubePlayer.Event.Data {
    
    /// Creates a new instance of ``YouTubePlayer/Event/Data``
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

extension YouTubePlayer.Event.Data: Codable {
    
    /// Creates a new instance of ``YouTubePlayer/Event/Data``
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

// MARK: - CustomStringConvertible

extension YouTubePlayer.Event.Data: CustomStringConvertible {
    
    /// A textual representation of this instance.
    public var description: String {
        self.value
    }
    
}

// MARK: - LosslessStringConvertible Value

public extension YouTubePlayer.Event.Data {
    
    /// Returns the value as the given `LosslessStringConvertible` type.
    /// - Parameter type: The type.
    func value<T: LosslessStringConvertible>(
        as type: T.Type
    ) -> T? {
        .init(self.value)
    }
    
}

// MARK: - JSON Value

public extension YouTubePlayer.Event.Data {
    
    /// Decodes the value into the specified `Decodable` type using the provided `JSONDecoder`.
    /// - Parameters:
    ///   - type: The `Decodable` type.
    ///   - jsonDecoder: The `JSONDecoder`. Default value `.init()`
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
