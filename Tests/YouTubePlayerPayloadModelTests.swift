import Foundation
import Testing
@testable import YouTubePlayerKit

// MARK: - YouTubePlayerPayloadModelTests

struct YouTubePlayerPayloadModelTests {

    @Test("Caption tracks decode API field names and retain an unfamiliar language code")
    func decodesCaptionTrackFields() throws {
        let track = try JSONDecoder().decode(
            YouTubePlayer.CaptionsTrack.self,
            from: Data(#"{"id":"track-id","vss_id":".future","is_default":true,"is_servable":false,"is_translateable":true,"languageCode":"x-future-language","languageName":"Future language","futureField":42}"#.utf8)
        )
        #expect(track.videoSubtitlesSystemID == ".future")
        #expect(track.isDefault == true)
        #expect(track.isServable == false)
        #expect(track.isTranslateable == true)
        #expect(track.languageCode.id == "x-future-language")
        #expect(track.name == nil)
        #expect(try JSONDecoder().decode(YouTubePlayer.CaptionsTrack.self, from: JSONEncoder().encode(track)) == track)
    }

    @Test("Minimal caption tracks permit absent optional metadata and require language identity")
    func decodesMinimalCaptionTrack() throws {
        let track = try JSONDecoder().decode(
            YouTubePlayer.CaptionsTrack.self,
            from: Data(#"{"languageCode":"en","languageName":"English"}"#.utf8)
        )
        #expect(track.languageCode == .english)
        #expect(track.id == nil)
        #expect(track.isDefault == nil)
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(
                YouTubePlayer.CaptionsTrack.self,
                from: Data(#"{"languageName":"English"}"#.utf8)
            )
        }
    }

    @Test("Caption language localization uses the explicitly requested locale")
    func localizesCaptionLanguage() {
        #expect(YouTubePlayer.CaptionsLanguageCode.german.localizedString(locale: .init(identifier: "en_US")) == "German")
        #expect(YouTubePlayer.CaptionsLanguageCode.german.localizedString(locale: .init(identifier: "de_DE")) == "Deutsch")
    }

    @Test("Volume payloads accept omitted optional fields and retain API key names")
    func decodesVolumeState() throws {
        let muted = try JSONDecoder().decode(
            YouTubePlayer.VolumeState.self,
            from: Data(#"{"muted":true,"futureField":42}"#.utf8)
        )
        #expect(muted == .init(isMuted: true))
        let state = YouTubePlayer.VolumeState(
            isMuted: false,
            volume: 75,
            isUnstorable: true
        )
        let data = try JSONEncoder().encode(state)
        let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(object["muted"] as? Bool == false)
        #expect(object["unstorable"] as? Bool == true)
        #expect(object["volume"] as? Int == 75)
        #expect(try JSONDecoder().decode(YouTubePlayer.VolumeState.self, from: data) == state)
    }

    @Test(
        "Volume payloads require a Boolean muted field",
        arguments: ["{}", #"{"muted":"true"}"#, #"{"muted":true,"volume":"75"}"#]
    )
    func rejectsMalformedVolumePayload(
        json: String
    ) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(
                YouTubePlayer.VolumeState.self,
                from: Data(json.utf8)
            )
        }
    }

    @Test("Fullscreen serialization converts duration units and retains fractional seconds")
    func roundTripsFullscreenTime() throws {
        let state = YouTubePlayer.FullscreenState(
            isFullscreen: true,
            videoID: "video-id",
            time: .init(value: 1.125, unit: .minutes)
        )
        let data = try JSONEncoder().encode(state)
        let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(object["time"] as? Double == 67.5)
        #expect(object["videoId"] as? String == "video-id")
        #expect(object["fullscreen"] as? Bool == true)
        let decoded = try JSONDecoder().decode(
            YouTubePlayer.FullscreenState.self,
            from: data
        )
        #expect(decoded.time == .init(value: 67.5, unit: .seconds))
        #expect(decoded == state)
    }

    @Test("Fullscreen events do not require a video identifier or playback time")
    func decodesMinimalFullscreenState() throws {
        let state = try JSONDecoder().decode(
            YouTubePlayer.FullscreenState.self,
            from: Data(#"{"fullscreen":false,"futureField":42}"#.utf8)
        )
        #expect(state == .init(isFullscreen: false))
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(
                YouTubePlayer.FullscreenState.self,
                from: Data(#"{"fullscreen":1}"#.utf8)
            )
        }
    }

    @Test("Unknown playback values survive decoding and encoding without becoming known defaults")
    func preservesUnknownPlaybackValues() throws {
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        let state = try decoder.decode(
            YouTubePlayer.PlaybackState.self,
            from: Data("999".utf8)
        )
        let quality = try decoder.decode(
            YouTubePlayer.PlaybackQuality.self,
            from: Data(#""future-quality""#.utf8)
        )
        let rate = try decoder.decode(
            YouTubePlayer.PlaybackRate.self,
            from: Data("2.75".utf8)
        )
        #expect(state.value == 999)
        #expect(state.description == "Unknown: 999")
        #expect(quality.name == "future-quality")
        #expect(quality != .unknown)
        #expect(rate > .double)
        #expect(rate.description == "2.75x")
        #expect(try decoder.decode(Int.self, from: encoder.encode(state)) == 999)
        #expect(try decoder.decode(String.self, from: encoder.encode(quality)) == "future-quality")
        #expect(try decoder.decode(Double.self, from: encoder.encode(rate)) == 2.75)
    }

}
