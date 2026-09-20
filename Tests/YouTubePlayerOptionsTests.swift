import Foundation
import Testing
@testable import YouTubePlayerKit

// MARK: - YouTubePlayerOptionsTests

struct YouTubePlayerOptionsTests {

    @Test(
        "Looping one video repeats its identifier through the playlist parameter",
        arguments: [true, false]
    )
    func encodesSingleVideoLoop(
        isLooping: Bool
    ) throws {
        let object = try self.encode(
            source: .video(id: "video-id"),
            parameters: .init(loopEnabled: isLooping)
        )
        let parameters = try #require(object["playerVars"] as? [String: Any])
        #expect(object["videoId"] as? String == "video-id")
        #expect(parameters["loop"] as? Int == (isLooping ? 1 : 0))
        #expect(parameters["playlist"] as? String == (isLooping ? "video-id" : nil))
        #expect(parameters["list"] == nil)
    }

    @Test("A multi-video source preserves playlist order")
    func encodesVideoSequence() throws {
        let object = try self.encode(source: .videos(ids: ["first", "second", "third"]))
        let parameters = try #require(object["playerVars"] as? [String: Any])
        #expect(object["videoId"] == nil)
        #expect(parameters["playlist"] as? String == "first,second,third")
        #expect(parameters["listType"] == nil)
    }

    @Test(
        "Playlist identifiers receive a prefix only when needed",
        arguments: [
            ("example", "PLexample"),
            ("PLexample", "PLexample"),
            ("plexample", "plexample")
        ]
    )
    func normalizesPlaylistIdentifier(
        identifier: String,
        expectedIdentifier: String
    ) throws {
        let object = try self.encode(source: .playlist(id: identifier))
        let parameters = try #require(object["playerVars"] as? [String: Any])
        #expect(parameters["list"] as? String == expectedIdentifier)
        #expect(parameters["listType"] as? String == "playlist")
        #expect(object["videoId"] == nil)
    }

    @Test("Channel sources use the uploads list type")
    func encodesChannelUploads() throws {
        let object = try self.encode(source: .channel(name: "channel-name"))
        let parameters = try #require(object["playerVars"] as? [String: Any])
        #expect(parameters["list"] as? String == "channel-name")
        #expect(parameters["listType"] as? String == "user_uploads")
    }

    @Test("Duration units are converted to whole seconds and booleans become API bits")
    func encodesDurationAndBooleanParameters() throws {
        let object = try self.encode(
            parameters: .init(
                autoPlay: true,
                startTime: .init(value: 1.5, unit: .minutes),
                endTime: .init(value: 125.75, unit: .seconds),
                showControls: false,
                originURL: nil
            ),
            allowsInlineMediaPlayback: false
        )
        let parameters = try #require(object["playerVars"] as? [String: Any])
        #expect(parameters["start"] as? Int == 90)
        #expect(parameters["end"] as? Int == 125)
        #expect(parameters["autoplay"] as? Int == 1)
        #expect(parameters["controls"] as? Int == 0)
        #expect(parameters["playsinline"] as? Int == 0)
        #expect(parameters["enablejsapi"] as? Int == 1)
        #expect(parameters["origin"] == nil)
        #expect(parameters["loop"] == nil)
    }

    @Test("Default options enable the bridge and register player callbacks without iFrame bootstrap events")
    func encodesPlayerBootstrapOptions() throws {
        let object = try self.encode()
        let parameters = try #require(object["playerVars"] as? [String: Any])
        let events = try #require(object["events"] as? [String: String])
        #expect(object["width"] as? String == "100%")
        #expect(object["height"] as? String == "100%")
        #expect(object["videoId"] == nil)
        #expect(parameters["playsinline"] as? Int == 1)
        #expect(parameters["enablejsapi"] as? Int == 1)
        #expect(events["onReady"] == "onReady")
        #expect(events["onStateChange"] == "onStateChange")
        #expect(events["onError"] == "onError")
        #expect(events[YouTubePlayer.Event.Name.iFrameApiReady.rawValue] == nil)
        #expect(events[YouTubePlayer.Event.Name.iFrameApiFailedToLoad.rawValue] == nil)
    }

}

// MARK: - Fixtures

private extension YouTubePlayerOptionsTests {

    /// Encodes options into the JSON object consumed by the iFrame player.
    func encode(
        source: YouTubePlayer.Source? = nil,
        parameters: YouTubePlayer.Parameters = .init(),
        allowsInlineMediaPlayback: Bool = true
    ) throws -> [String: Any] {
        let options = YouTubePlayer.Options(
            source: source,
            parameters: parameters
        )
        let data = try options.jsonEncode(
            configuration: .init(allowsInlineMediaPlayback: allowsInlineMediaPlayback)
        )
        return try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

}
