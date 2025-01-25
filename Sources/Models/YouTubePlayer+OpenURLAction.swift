#if os(macOS)
import AppKit
#else
import UIKit
#endif

// MARK: - YouTubePlayer+OpenURLAction

public extension YouTubePlayer {
    
    /// A YouTube player open url action.
    struct OpenURLAction: Sendable {
        
        // MARK: Typealias
        
        /// An OpenURLAction Handler typealias representing a closure
        /// which takes in a URL which should be opened
        public typealias Handler = @MainActor (URL) async -> Void
        
        // MARK: Properties
        
        /// The Handler
        private let handler: Handler
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer.OpenURLAction``
        /// - Parameter handler: The handler closure which takes in a URL which should be opened
        public init(
            handler: @escaping Handler
        ) {
            self.handler = handler
        }
        
    }
    
}

// MARK: - Call as Function

public extension YouTubePlayer.OpenURLAction {
    
    /// Call OpenURLAction as function
    /// - Parameter url: The URL which should be opened
    func callAsFunction(
        _ url: URL
    ) async {
        await self.handler(url)
    }
    
}

// MARK: - Equatable

extension YouTubePlayer.OpenURLAction: Equatable {
    
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

extension YouTubePlayer.OpenURLAction: Hashable {
    
    /// Hashes the essential components of this value by feeding them into the given hasher.
    /// - Parameter hasher: The hasher to use when combining the components of this instance.
    public func hash(
        into hasher: inout Hasher
    ) {}
    
}

// MARK: - Default

public extension YouTubePlayer.OpenURLAction {
    
    /// The default OpenURLAction
    static let `default` = Self { url in
        #if os(macOS)
        _ = try? await NSWorkspace
            .shared
            .open(
                url,
                configuration: .init()
            )
        #else
        await UIApplication.shared.open(url)
        #endif
    }
    
}
