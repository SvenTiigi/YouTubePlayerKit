import Testing
import Foundation
@testable import YouTubePlayerKit

@MainActor
struct YouTubePlayerTests {
    
    @Test
    func logging() async {
        #expect(!YouTubePlayer.isLoggingEnabled)
        YouTubePlayer.isLoggingEnabled = true
        #expect(YouTubePlayer.isLoggingEnabled)
        YouTubePlayer.isLoggingEnabled = false
    }
    
    @Test
    func customInitialization() async {
        let source: YouTubePlayer.Source = .video(id: UUID().uuidString)
        let parameters = YouTubePlayer.Parameters(
            autoPlay: .random(),
            captionLanguage: UUID().uuidString,
            showCaptions: .random(),
            progressBarColor: YouTubePlayer.Parameters.ProgressBarColor.allCases.randomElement(),
            showControls: .random(),
            keyboardControlsDisabled: .random(),
            endTime: .init(value: .random(in: 40...60), unit: .seconds),
            showFullscreenButton: .random(),
            language: UUID().uuidString,
            showAnnotations: .random(),
            loopEnabled: .random(),
            showRelatedVideos: .random(),
            startTime: .init(value: .random(in: 1...10), unit: .seconds),
            referrer: UUID().uuidString
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
