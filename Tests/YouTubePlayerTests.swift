import Testing
import Foundation
@testable import YouTubePlayerKit

@MainActor
struct YouTubePlayerTests {
    
    @Test
    func logging() async {
        let player = YouTubePlayer()
        #expect(YouTubePlayer.Logger.category(player) == nil)
        #expect(!YouTubePlayer.isLoggingEnabled)
        YouTubePlayer.isLoggingEnabled = true
        #expect(YouTubePlayer.Logger.category(player) != nil)
        #expect(YouTubePlayer.isLoggingEnabled)
        YouTubePlayer.isLoggingEnabled = false
    }
    
    @Test
    func customInitialization() async {
        let source: YouTubePlayer.Source = .video(id: UUID().uuidString)
        let parameters = YouTubePlayer.Parameters(
            autoPlay: .random(),
            loopEnabled: .random(),
            startTime: Bool.random() ? .init(value: .random(in: 1...10), unit: .seconds) : nil,
            endTime: Bool.random() ? .init(value: .random(in: 40...60), unit: .seconds) : nil,
            showControls: .random(),
            showFullscreenButton: .random(),
            progressBarColor: YouTubePlayer.Parameters.ProgressBarColor.allCases.randomElement(),
            keyboardControlsDisabled: .random(),
            language: UUID().uuidString,
            captionLanguage: UUID().uuidString,
            showCaptions: .random(),
            restrictRelatedVideosToSameChannel: .random(),
            referrer: Bool.random() ? .init(string: "https://\(UUID().uuidString)") : nil
        )
        let configuration = YouTubePlayer.Configuration(
            fullscreenMode: YouTubePlayer.FullscreenMode.allCases.randomElement() ?? .system,
            allowsInlineMediaPlayback: .random(),
            allowsPictureInPictureMediaPlayback: .random(),
            useNonPersistentWebsiteDataStore: .random(),
            automaticallyAdjustsContentInsets: .random(),
            customUserAgent: UUID().uuidString,
            openURLAction: .default
        )
        let youTubePlayer = YouTubePlayer(
            source: source,
            parameters: parameters,
            configuration: configuration
        )
        #expect(youTubePlayer.source == source)
        #expect(youTubePlayer.parameters == parameters)
        #expect(youTubePlayer.configuration == configuration)
        #expect(youTubePlayer.state == .idle)
        #expect(youTubePlayer.playbackState == nil)
        #expect(!youTubePlayer.isPlaying)
        #expect(!youTubePlayer.isPaused)
        #expect(!youTubePlayer.isBuffering)
        #expect(!youTubePlayer.isEnded)
        #expect(youTubePlayer.playbackQuality == nil)
        #expect(youTubePlayer.playbackRate == nil)
    }
    
    @Test
    func stringLiteralInitialization() async {
        let videoID = UUID().uuidString
        let youTubePlayer = YouTubePlayer(stringLiteral: "https://youtube.com/watch?v=\(videoID)")
        #expect(youTubePlayer.source == .video(id: videoID))
    }
    
}
