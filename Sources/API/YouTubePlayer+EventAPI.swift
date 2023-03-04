import Combine
import Foundation

/// The YouTubePlayer Event API
/// - Read more: https://developers.google.com/youtube/iframe_api_reference#Events
public extension YouTubePlayer {
    
    /// The current YouTubePlayer State, if available
    var state: State? {
        self.playerStateSubject.value
    }
    
    /// A Publisher that emits the current YouTubePlayer State
    var statePublisher: AnyPublisher<State, Never> {
        self.playerStateSubject
            .compactMap { $0 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    /// The current YouTubePlayer PlaybackState, if available
    var playbackState: PlaybackState? {
        self.playbackStateSubject.value
    }

    /// A Boolean value that determines if the player is currently playing.
    var isPlaying: Bool {
        self.playbackState == .playing
    }
    
    /// A Boolean value that determines if the player is currently paused.
    var isPaused: Bool {
        self.playbackState == .paused
    }
    
    /// A Boolean value that determines if the player is currently buffering.
    var isBuffering: Bool {
        self.playbackState == .buffering
    }
    
    /// A Boolean value that determines if the player is ended.
    var isEnded: Bool {
        self.playbackState == .ended
    }
    
    /// A Publisher that emits the current YouTubePlayer PlaybackState
    var playbackStatePublisher: AnyPublisher<PlaybackState, Never> {
        self.playbackStateSubject
            .compactMap { $0 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    /// The current YouTubePlayer PlaybackQuality, if available
    var playbackQuality: PlaybackQuality? {
        self.playbackQualitySubject.value
    }
    
    /// A Publisher that emits the current YouTubePlayer PlaybackQuality
    var playbackQualityPublisher: AnyPublisher<PlaybackQuality, Never> {
        self.playbackQualitySubject
            .compactMap { $0 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    /// The current YouTubePlayer PlaybackRate, if available
    var playbackRate: PlaybackRate? {
        self.playbackRateSubject.value
    }
    
    /// A Publisher that emits the current YouTubePlayer PlaybackRate
    var playbackRatePublisher: AnyPublisher<PlaybackRate, Never> {
        self.playbackRateSubject
            .compactMap { $0 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
}
