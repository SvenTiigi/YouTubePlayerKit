import Foundation
import Testing
@testable import YouTubePlayerKit

// MARK: - YouTubePlayerJavaScriptEvaluationResponseConverterTests

struct YouTubePlayerJavaScriptEvaluationResponseConverterTests {

    @Test("Type casting preserves arrays returned by JavaScript")
    func castsJavaScriptResponse() throws {
        let converter = YouTubePlayer.JavaScriptEvaluationResponseConverter<[String]>.typeCast(to: [String].self)
        let result = try converter(
            javaScript: "player.getPlaylist();",
            javaScriptResponse: ["first", "second"]
        )
        #expect(result == ["first", "second"])
    }

    @Test("A failed type cast retains the executed script and response")
    func preservesTypeCastFailureContext() {
        let converter = YouTubePlayer.JavaScriptEvaluationResponseConverter<Int>.typeCast(to: Int.self)
        #expect {
            try converter(
                javaScript: "player.getVolume();",
                javaScriptResponse: "unexpected"
            )
        } throws: { error in
            guard let error = error as? YouTubePlayer.APIError else {
                return false
            }
            return error.javaScript == "player.getVolume();"
                && error.javaScriptResponse == "unexpected"
                && error.reason?.contains("Type-Cast failed") == true
        }
    }

    @Test("Missing responses fail required casts")
    func rejectsMissingResponse() {
        let converter = YouTubePlayer.JavaScriptEvaluationResponseConverter<Int>.typeCast(to: Int.self)
        #expect(throws: YouTubePlayer.APIError.self) {
            try converter(
                javaScript: "player.getVolume();",
                javaScriptResponse: nil
            )
        }
    }

    @Test("Void conversion permits both absent and nonempty return values")
    func ignoresUnusedResponse() throws {
        let converter = YouTubePlayer.JavaScriptEvaluationResponseConverter<Void>.void
        try converter(
            javaScript: "player.playVideo();",
            javaScriptResponse: nil
        )
        try converter(
            javaScript: "player.playVideo();",
            javaScriptResponse: ["unexpected": true]
        )
    }

    @Test("Decoding handles WebKit dictionaries and ignores future metadata fields")
    func decodesPlaybackMetadata() throws {
        let converter = YouTubePlayer.JavaScriptEvaluationResponseConverter<[String: Any]>
            .typeCast(to: [String: Any].self)
            .decode(as: YouTubePlayer.PlaybackMetadata.self)
        let metadata = try converter(
            javaScript: "player.getVideoData();",
            javaScriptResponse: [
                "videoId": "video-id",
                "title": "Video title",
                "isLive": true,
                "futureMetadata": ["enabled": true]
            ]
        )
        #expect(metadata.videoId == "video-id")
        #expect(metadata.title == "Video title")
        #expect(metadata.isLive == true)
        #expect(metadata.author == nil)
    }

    @Test("Decoding uses a caller-provided decoder configuration")
    func usesConfiguredDecoder() throws {
        let converter = YouTubePlayer.JavaScriptEvaluationResponseConverter<[String: Any]>
            .typeCast(to: [String: Any].self)
            .decode(
                as: YouTubePlayer.PlaybackMetadata.self,
                decoder: {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    return decoder
                }()
            )
        let metadata = try converter(
            javaScript: "player.getVideoData();",
            javaScriptResponse: ["video_id": "video-id", "is_live": true]
        )
        #expect(metadata.videoId == "video-id")
        #expect(metadata.isLive == true)
    }

    @Test("Invalid model fields retain their decoding error and JavaScript context")
    func preservesDecodingFailureContext() {
        let converter = YouTubePlayer.JavaScriptEvaluationResponseConverter<[String: Any]>
            .typeCast(to: [String: Any].self)
            .decode(as: YouTubePlayer.VolumeState.self)
        #expect {
            try converter(
                javaScript: "player.getVolumeState();",
                javaScriptResponse: ["muted": "invalid"]
            )
        } throws: { error in
            guard let error = error as? YouTubePlayer.APIError else {
                return false
            }
            return error.javaScript == "player.getVolumeState();"
                && error.underlyingError is DecodingError
                && error.reason?.hasPrefix("Decoding failed:") == true
        }
    }

    @Test(
        "Non-JSON dictionary values produce a contextual error without crashing",
        arguments: [false, true]
    )
    func preservesSerializationFailureContext(
        usesNonFiniteNumber: Bool
    ) {
        let converter = YouTubePlayer.JavaScriptEvaluationResponseConverter<[String: Any]>
            .typeCast(to: [String: Any].self)
            .decode(as: YouTubePlayer.PlaybackMetadata.self)
        let response: [String: Any] = [
            "title": usesNonFiniteNumber ? Double.nan : Date(timeIntervalSince1970: 0)
        ]
        #expect {
            try converter(
                javaScript: "player.getVideoData();",
                javaScriptResponse: response
            )
        } throws: { error in
            guard let error = error as? YouTubePlayer.APIError else {
                return false
            }
            return error.javaScript == "player.getVideoData();"
                && error.javaScriptResponse?.contains("title") == true
                && error.reason == "Malformed JSON"
        }
    }

}
