import Combine
import Foundation

// MARK: - YouTubePlayer

/// A YouTubePlayer
public final class YouTubePlayer: ObservableObject {
    
    // MARK: Properties
    
    /// The optional YouTubePlayer Source
    @Published
    public var source: Source? {
        didSet {
            // Verify Source has changed
            guard oldValue != self.source else {
                // Otherwise return out of function
                return
            }
            // Load Source
            self.load(
                source: self.source
            )
        }
    }
    
    /// The YouTubePlayer Configuration
    @Published
    public var configuration: Configuration {
        didSet {
            // Verify Configuration has changed
            guard oldValue != self.configuration else {
                // Otherwise return out of function
                return
            }
            // Update Configuration
            self.update(
                configuration: self.configuration
            )
        }
    }
    
    /// The YouTubePlayerAPI
    weak var api: YouTubePlayerAPI? {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    /// The Cancellables
    var cancellables = Set<AnyCancellable>()
    
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

// MARK: - Hashable

extension YouTubePlayer: Hashable {
    
    /// Hashes the essential components of this value by feeding them into the given hasher.
    /// - Parameter hasher: The hasher to use when combining the components of this instance.
    public func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(self.source)
        hasher.combine(self.configuration)
    }
    
}
