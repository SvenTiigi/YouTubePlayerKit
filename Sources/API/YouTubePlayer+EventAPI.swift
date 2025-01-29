import Combine
import Foundation

// MARK: - Events (https://developers.google.com/youtube/iframe_api_reference#Events)

public extension YouTubePlayer {
    
    /// A Publisher that emits the current YouTube player source.
    var sourcePublisher: some Publisher<Source?, Never> {
        self.sourceSubject
            .receive(on: DispatchQueue.main)
    }
    
    /// The current YouTube player state.
    var state: State {
        self.stateSubject.value
    }
    
    /// A Publisher that emits the current YouTube player state.
    var statePublisher: some Publisher<State, Never> {
        self.stateSubject
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
    }
    
    /// The current YouTube player playback state, if available.
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
    
    /// A Boolean value that determines if the player is currently cued.
    var isCued: Bool {
        self.playbackState == .cued
    }
    
    /// A Boolean value that determines if the player is ended.
    var isEnded: Bool {
        self.playbackState == .ended
    }
    
    /// A Publisher that emits the current YouTube player playback state.
    var playbackStatePublisher: some Publisher<PlaybackState, Never> {
        self.playbackStateSubject
            .compactMap { $0 }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
    }
    
    /// The current YouTube player playback quality, if available.
    var playbackQuality: PlaybackQuality? {
        self.playbackQualitySubject.value
    }
    
    /// A Publisher that emits the current YouTube player playback quality.
    var playbackQualityPublisher: some Publisher<PlaybackQuality, Never> {
        self.playbackQualitySubject
            .compactMap { $0 }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
    }
    
    /// The current YouTube player playback rate, if available.
    var playbackRate: PlaybackRate? {
        self.playbackRateSubject.value
    }
    
    /// A Publisher that emits the current YouTube player playback rate.
    var playbackRatePublisher: some Publisher<PlaybackRate, Never> {
        self.playbackRateSubject
            .compactMap { $0 }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
    }
    
    /// A Publisher that emits whenever autoplay or scripted video playback features were blocked.
    var autoplayBlockedPublisher: some Publisher<Void, Never> {
        self.autoplayBlockedSubject
            .receive(on: DispatchQueue.main)
    }
    
}
