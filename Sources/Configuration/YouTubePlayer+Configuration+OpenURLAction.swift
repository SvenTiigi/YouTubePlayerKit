import Foundation

// MARK: - YouTubePlayer+Configuration+OpenURLAction

public extension YouTubePlayer.Configuration {
    
    /// A YouTubePlayer Configuration OpenURLAction
    struct OpenURLAction {
        
        // MARK: Typealias
        
        /// An OpenURLAction Handler typealias representing a closure
        /// which takes in a URL which should be opened
        public typealias Handler = (URL) -> Void
        
        // MARK: Properties
        
        /// The Handler
        private let handler: Handler
        
        // MARK: Initializer
        
        /// Creates a new instance of `YouTubePlayer.Configuration.OpenURLAction`
        /// - Parameter handler: The handler closure which takes in a URL which should be opened
        public init(
            handler: @escaping Handler
        ) {
            self.handler = handler
        }
        
        // MARK: Call as Function
        
        /// Call OpenURLAction as function
        /// - Parameter url: The URL which should be opened
        public func callAsFunction(
            _ url: URL
        ) {
            self.handler(url)
        }
        
    }
    
}

// MARK: - Equatable

extension YouTubePlayer.Configuration.OpenURLAction: Equatable {
    
    /// Returns a Boolean value indicating whether two `YouTubePlayer.State` are equal
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        true
    }
    
}

// MARK: - Hashable

extension YouTubePlayer.Configuration.OpenURLAction: Hashable {
    
    /// Hashes the essential components of this value by feeding them into the given hasher.
    /// - Parameter hasher: The hasher to use when combining the components of this instance.
    public func hash(
        into hasher: inout Hasher
    ) {}
    
}
