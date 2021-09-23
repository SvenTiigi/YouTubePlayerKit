import Foundation
import SwiftUI

// MARK: - YouTubePlayer+PreferenceKey

public extension YouTubePlayer {
    
    /// A YouTubePlayer instance produced by a SwiftUI view
    struct PreferenceKey: SwiftUI.PreferenceKey {
        
        /// The default value of the preference.
        public static var defaultValue: YouTubePlayer?
        
        /// Combines a sequence of values by modifying the previously-accumulated
        /// value with the result of a closure that provides the next value.
        /// - Parameters:
        ///   - value: The value accumulated through previous calls to this method.
        ///   - nextValue: A closure that returns the next value in the sequence.
        public static func reduce(
            value: inout YouTubePlayer?,
            nextValue: () -> YouTubePlayer?
        ) {
            value = nextValue()
        }
        
    }
    
}
