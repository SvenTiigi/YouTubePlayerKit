import Foundation
import Testing
@testable import YouTubePlayerKit

// MARK: - YouTubePlayerTests

@MainActor
struct YouTubePlayerTests {

    @Test(
        "Initialization applies explicit playback settings across fullscreen modes",
        arguments: [false, true],
        YouTubePlayer.FullscreenMode.allCases
    )
    func customInitialization(
        isEnabled: Bool,
        fullscreenMode: YouTubePlayer.FullscreenMode
    ) {
        let source = YouTubePlayer.Source.video(id: UUID().uuidString)
        let parameters = YouTubePlayer.Parameters(
            autoPlay: isEnabled,
            loopEnabled: isEnabled,
            startTime: isEnabled ? .init(value: 10, unit: .seconds) : nil,
            endTime: isEnabled ? .init(value: 60, unit: .seconds) : nil,
            showControls: isEnabled,
            showFullscreenButton: isEnabled,
            progressBarColor: isEnabled ? .white : .red,
            keyboardControlsDisabled: isEnabled,
            language: "de",
            captionLanguage: "en",
            showCaptions: isEnabled,
            restrictRelatedVideosToSameChannel: isEnabled,
            originURL: nil,
            referrerURL: nil
        )
        let configuration = YouTubePlayer.Configuration(
            fullscreenMode: fullscreenMode,
            allowsInlineMediaPlayback: isEnabled,
            allowsAirPlayForMediaPlayback: isEnabled,
            allowsPictureInPictureMediaPlayback: isEnabled,
            useNonPersistentWebsiteDataStore: isEnabled,
            automaticallyAdjustsContentInsets: isEnabled,
            customUserAgent: "YouTubePlayerKitTests"
        )
        let player = YouTubePlayer(
            source: source,
            parameters: parameters,
            configuration: configuration,
            isLoggingEnabled: isEnabled
        )
        #expect(player.source == source)
        #expect(player.parameters == parameters)
        #expect(player.configuration == configuration)
        #expect(player.isLoggingEnabled == isEnabled)
        #expect(player.state == .idle)
        #expect(player.playbackState == nil)
    }

    @Test("String initialization parses the source, player parameters, and inline configuration together")
    func parsesCompletePlayerURL() {
        let player: YouTubePlayer = "https://youtube.com/watch?v=video-id&autoplay=1&start=15&playsinline=0"
        #expect(player.source == .video(id: "video-id"))
        #expect(player.parameters.autoPlay == true)
        #expect(player.parameters.startTime == .init(value: 15, unit: .seconds))
        #expect(!player.configuration.allowsInlineMediaPlayback)
        #expect(!player.isLoggingEnabled)
        #expect(player.state == .idle)
    }

}
