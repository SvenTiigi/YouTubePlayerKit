import Foundation

// MARK: - YouTubePlayer

/// A YouTubePlayer
public final class YouTubePlayer: ObservableObject {
    
    // MARK: Properties
    
    /// The optional YouTubePlayer Source
    public internal(set) var source: Source?
    
    /// The YouTubePlayer Configuration
    public internal(set) var configuration: Configuration
    
    /// The  YouTubePlayerAPI
    weak var api: YouTubePlayerAPI? {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    // MARK: Initializer
    
    /// Creates a new instance of `YouTubePlayer`
    /// - Parameters:
    ///   - source: The optional YouTubePlayer Source. Default value `nil`
    ///   - configuration: The YouTubePlayer Configuration. Default value `.init()`
    public init(
        source: Source? = nil,
        configuration: Configuration = .init()
    ) {
        self.source = source
        self.configuration = configuration
    }
    
}

// MARK: - ExpressibleByStringLiteral

extension YouTubePlayer: ExpressibleByStringLiteral {
    
    /// Creates an instance initialized to the given string value.
    /// - Parameter value: The value of the new instance
    public convenience init(
        stringLiteral value: String
    ) {
        self.init(
            source: .url(value)
        )
    }
    
}

// MARK: - Equatable

extension YouTubePlayer: Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (
        lhs: YouTubePlayer,
        rhs: YouTubePlayer
    ) -> Bool {
        lhs.source == rhs.source
            && lhs.configuration == rhs.configuration
    }

}
