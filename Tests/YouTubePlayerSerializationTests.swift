import Foundation
import Testing
@testable import YouTubePlayerKit

// MARK: - YouTubePlayerSerializationTests

@MainActor
struct YouTubePlayerSerializationTests {

    @Test("Decoding an empty player restores documented defaults without starting playback")
    func decodesPlayerDefaults() throws {
        let player = try JSONDecoder().decode(
            YouTubePlayer.self,
            from: Data("{}".utf8)
        )
        #expect(player.source == nil)
        #expect(player.parameters == .init())
        #expect(player.configuration == .init())
        #expect(!player.isLoggingEnabled)
        #expect(player.state == .idle)
        #expect(player.playbackState == nil)
    }

    @Test("Player decoding honors source and parameter wire formats and tolerates additional fields")
    func decodesConfiguredPlayer() throws {
        let player = try JSONDecoder().decode(
            YouTubePlayer.self,
            from: Data(#"{"source":["first","second"],"parameters":{"autoplay":1,"start":12.5},"isLoggingEnabled":true,"futureField":42}"#.utf8)
        )
        #expect(player.source == .videos(ids: ["first", "second"]))
        #expect(player.parameters.autoPlay == true)
        #expect(player.parameters.startTime == .init(value: 12.5, unit: .seconds))
        #expect(player.isLoggingEnabled)
        #expect(player.configuration == .init())
        #expect(player.state == .idle)
    }

    @Test("Malformed player parameters propagate decoding failures")
    func rejectsMalformedPlayerParameters() {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(
                YouTubePlayer.self,
                from: Data(#"{"parameters":{"autoplay":2}}"#.utf8)
            )
        }
    }

    @Test(
        "Configuration serialization retains media settings and additional callback subscriptions",
        arguments: YouTubePlayer.FullscreenMode.allCases
    )
    func roundTripsConfiguration(
        fullscreenMode: YouTubePlayer.FullscreenMode
    ) throws {
        let configuration = YouTubePlayer.Configuration(
            fullscreenMode: fullscreenMode,
            allowsInlineMediaPlayback: false,
            allowsAirPlayForMediaPlayback: false,
            allowsPictureInPictureMediaPlayback: true,
            useNonPersistentWebsiteDataStore: true,
            automaticallyAdjustsContentInsets: false,
            customUserAgent: "YouTubePlayerKitTests/3.0",
            htmlBuilder: .init(
                youTubePlayerScriptMessageHandlerName: "custom-handler",
                additionalEventNames: ["onFutureEvent"]
            )
        )
        let data = try JSONEncoder().encode(configuration)
        let decoded = try JSONDecoder().decode(
            YouTubePlayer.Configuration.self,
            from: data
        )
        #expect(decoded == configuration)
        let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(object["openURLAction"] == nil)
    }

    @Test(
        "Source decoding accepts API list and playlist representations",
        arguments: [
            (#"{"listType":"playlist","list":"PL-example"}"#, YouTubePlayer.Source.playlist(id: "PL-example")),
            (#"{"listType":"user_uploads","list":"channel"}"#, .channel(name: "channel")),
            (#"{"playlist":"first"}"#, .video(id: "first")),
            (#"{"playlist":"first,second"}"#, .videos(ids: ["first", "second"]))
        ]
    )
    func decodesSourceWireFormats(
        json: String,
        expectedSource: YouTubePlayer.Source
    ) throws {
        let source = try JSONDecoder().decode(
            YouTubePlayer.Source.self,
            from: Data(json.utf8)
        )
        #expect(source == expectedSource)
        #expect(try JSONDecoder().decode(YouTubePlayer.Source.self, from: JSONEncoder().encode(source)) == source)
    }

    @Test(
        "Unsupported source JSON produces a decoding error",
        arguments: ["[]", "{}", "42", "null", #""not a source""#]
    )
    func rejectsUnsupportedSourceRepresentations(
        json: String
    ) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(
                YouTubePlayer.Source.self,
                from: Data(json.utf8)
            )
        }
    }

}
