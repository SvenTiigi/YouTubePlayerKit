import Foundation
import Testing
@testable import YouTubePlayerKit

// MARK: - YouTubePlayerCommandTests

/// Verifies public Swift commands against the arguments received by a real JavaScript player.
@MainActor
@Suite(.serialized)
struct YouTubePlayerCommandTests {}

// MARK: - Playback

extension YouTubePlayerCommandTests {

    @Test("Playback commands preserve order, time units, and seek-ahead policy")
    func controlsPlayback() async throws {
        let fixture = YouTubePlayerTestFixture()
        try await fixture.waitUntilReady()
        try await fixture.clearCalls()
        try await fixture.player.play()
        try await fixture.player.pause()
        try await fixture.player.stop()
        try await fixture.player.seek(to: .init(value: 1.5, unit: .minutes))
        try await fixture.player.seek(
            to: .init(value: 2500, unit: .milliseconds),
            allowSeekAhead: false
        )
        try await fixture.player.set(playbackRate: .init(value: 1.5))
        #expect(try await fixture.calls() == [
            .init(name: "playVideo", arguments: []),
            .init(name: "pauseVideo", arguments: []),
            .init(name: "stopVideo", arguments: []),
            .init(name: "seekTo", arguments: [.number(90), .bool(true)]),
            .init(name: "seekTo", arguments: [.number(2.5), .bool(false)]),
            .init(name: "setPlaybackRate", arguments: [.number(1.5)])
        ])
    }

    @Test("Relative seeking combines the current time with the requested duration")
    func seeksRelativeToCurrentTime() async throws {
        let fixture = YouTubePlayerTestFixture()
        try await fixture.waitUntilReady()
        try await fixture.setResult(90, for: "getCurrentTime")
        try await fixture.clearCalls()
        try await fixture.player.fastForward(
            by: .init(value: 1, unit: .minutes),
            allowSeekAhead: false
        )
        try await fixture.player.rewind(by: .init(value: 500, unit: .milliseconds))
        #expect(try await fixture.calls() == [
            .init(name: "getCurrentTime", arguments: []),
            .init(name: "seekTo", arguments: [.number(150), .bool(false)]),
            .init(name: "getCurrentTime", arguments: []),
            .init(name: "seekTo", arguments: [.number(89.5), .bool(true)])
        ])
    }

    @Test("Typed playback getters convert real WebKit responses")
    func readsPlaybackValues() async throws {
        let fixture = YouTubePlayerTestFixture()
        try await fixture.waitUntilReady()
        try await fixture.setResult(123.5, for: "getDuration")
        try await fixture.setResult(1.25, for: "getPlaybackRate")
        #expect(try await fixture.player.getDuration() == .init(value: 123.5, unit: .seconds))
        #expect(try await fixture.player.getCurrentTime() == .init(value: 30, unit: .seconds))
        #expect(try await fixture.player.getPlaybackState() == .paused)
        #expect(try await fixture.player.getPlaybackRate() == .init(value: 1.25))
        #expect(try await fixture.player.getAvailablePlaybackRates().map(\.value) == [0.5, 1, 1.5, 2])
        #expect(try await fixture.player.getVideoLoadedFraction() == 0.75)
        #expect(try await fixture.player.getVideoURL() == "https://www.youtube.com/watch?v=first")
        #expect(try await fixture.player.getPlaybackMetadata() == .init(
            title: "Fixture",
            author: "Author",
            videoId: "first"
        ))
    }

}

// MARK: - Player Information and Thumbnails

extension YouTubePlayerCommandTests {

    @Test("Player information preserves future playback values and nested metadata")
    func readsPlayerInformation() async throws {
        let fixture = YouTubePlayerTestFixture()
        try await fixture.waitUntilReady()
        try await fixture.evaluate(
            """
            window.testPlayerResults.playerInfo = {
                muted: true,
                volume: 73,
                playerState: 99,
                playbackRate: 1.75,
                availablePlaybackRates: [1, 1.75],
                playbackQuality: 'future-quality',
                availableQualityLevels: ['hd720', 'future-quality'],
                currentTime: 12.5,
                duration: 123.75,
                videoEmbedCode: '<iframe>fixture</iframe>',
                videoUrl: 'https://www.youtube.com/watch?v=current',
                mediaReferenceTime: 10.25,
                playlistId: 'current-playlist',
                playlistIndex: 2,
                videoLoadedFraction: 0.5,
                videoData: {videoId: 'current', title: 'A 🌍 title', isLive: true},
                futureProperty: 'ignored'
            };
            """
        )
        let information = try await fixture.player.getInformation()
        #expect(information.muted)
        #expect(information.volume == 73)
        #expect(information.playerState.value == 99)
        #expect(information.playbackRate.value == 1.75)
        #expect(information.availablePlaybackRates.map(\.value) == [1, 1.75])
        #expect(information.playbackQuality.name == "future-quality")
        #expect(information.availableQualityLevels.map(\.name) == ["hd720", "future-quality"])
        #expect(information.currentTime == 12.5)
        #expect(information.duration == 123.75)
        #expect(information.videoEmbedCode == "<iframe>fixture</iframe>")
        #expect(information.videoUrl == "https://www.youtube.com/watch?v=current")
        #expect(information.mediaReferenceTime == 10.25)
        #expect(information.playlistId == "current-playlist")
        #expect(information.playlistIndex == 2)
        #expect(information.videoLoadedFraction == 0.5)
        #expect(information.videoBytesLoaded == nil)
        #expect(information.videoData == .init(title: "A 🌍 title", videoId: "current", isLive: true))
    }

    @Test("Malformed player information reports the required field and original JavaScript")
    func rejectsMalformedPlayerInformation() async throws {
        let fixture = YouTubePlayerTestFixture()
        try await fixture.waitUntilReady()
        try await fixture.setResult(["volume": 73], for: "playerInfo")
        await #expect {
            try await fixture.player.getInformation()
        } throws: { error in
            guard let error = error as? YouTubePlayer.APIError else {
                return false
            }
            #expect(error.javaScript?.contains("playerInfo") == true)
            #expect(error.javaScriptResponse?.contains("volume") == true)
            guard case .keyNotFound(let key, _) = error.underlyingError as? DecodingError else {
                Issue.record("Missing player information fields must preserve the decoding error")
                return false
            }
            #expect(key.stringValue == "muted")
            return true
        }
    }

    @Test("Thumbnail URLs use the currently playing metadata and requested resolution")
    func resolvesThumbnailURLFromCurrentMetadata() async throws {
        let fixture = YouTubePlayerTestFixture(source: .video(id: "original-source"))
        try await fixture.waitUntilReady()
        try await fixture.setResult(["video_id": "current-video"], for: "getVideoData")
        #expect(try await fixture.player.getVideoThumbnailURL()?.absoluteString ==
            "https://img.youtube.com/vi/current-video/sddefault.jpg")
        #expect(try await fixture.player.getVideoThumbnailURL(resolution: .maximum)?.absoluteString ==
            "https://img.youtube.com/vi/current-video/maxresdefault.jpg")
        #expect(fixture.player.source == .video(id: "original-source"))
    }

    @Test("Thumbnail wrappers handle missing identifiers and metadata failures before requesting an image")
    func handlesUnavailableThumbnailMetadata() async throws {
        let fixture = YouTubePlayerTestFixture(source: .video(id: "original-source"))
        try await fixture.waitUntilReady()
        try await fixture.setResult(["title": "No current video"], for: "getVideoData")
        #expect(try await fixture.player.getVideoThumbnailURL() == nil)
        #expect(try await fixture.player.getVideoThumbnailImage() == nil)
        try await fixture.setError("Metadata unavailable", for: "getVideoData")
        await #expect {
            try await fixture.player.getVideoThumbnailURL()
        } throws: { error in
            guard let error = error as? YouTubePlayer.APIError else {
                return false
            }
            #expect(error.reason?.contains("Metadata unavailable") == true)
            #expect(error.javaScript?.contains("getVideoData") == true)
            #expect(error.webKitErrorCode == .javaScriptExceptionOccurred)
            return true
        }
        await #expect {
            try await fixture.player.getVideoThumbnailImage()
        } throws: { error in
            guard let error = error as? YouTubePlayer.APIError else {
                return false
            }
            #expect(error.reason?.contains("Metadata unavailable") == true)
            #expect(error.javaScript?.contains("getVideoData") == true)
            #expect(error.webKitErrorCode == .javaScriptExceptionOccurred)
            return true
        }
    }

}

// MARK: - Queueing and Playlists

extension YouTubePlayerCommandTests {

    @Test("Loading and cueing videos serialize identifiers safely and omit unspecified options")
    func loadsAndCuesVideo() async throws {
        let fixture = YouTubePlayerTestFixture(source: .video(id: "original"))
        try await fixture.waitUntilReady()
        try await fixture.clearCalls()
        let identifier = "video'\\\"🌍"
        try await fixture.player.load(
            source: .video(id: identifier),
            startTime: .init(value: 1.5, unit: .minutes),
            endTime: .init(value: 2, unit: .minutes),
            index: 7
        )
        #expect(fixture.player.source == .video(id: identifier))
        try await fixture.player.cue(source: .video(id: "next"))
        #expect(fixture.player.source == .video(id: "next"))
        #expect(try await fixture.calls() == [
            .init(name: "loadVideoById", arguments: [.object([
                "videoId": .string(identifier),
                "startSeconds": .number(90),
                "endSeconds": .number(120)
            ])]),
            .init(name: "cueVideoById", arguments: [.object(["videoId": .string("next")])])
        ])
    }

    @Test(
        "Playlist sources use the correct list type and queueing options",
        arguments: [
            YouTubePlayer.Source.videos(ids: ["first", "second"]),
            .playlist(id: "PLfixture"),
            .channel(name: "channel")
        ]
    )
    func loadsAndCuesPlaylistSources(
        source: YouTubePlayer.Source
    ) async throws {
        let fixture = YouTubePlayerTestFixture()
        try await fixture.waitUntilReady()
        try await fixture.clearCalls()
        try await fixture.player.load(
            source: source,
            startTime: .init(value: 1500, unit: .milliseconds),
            endTime: .init(value: 10, unit: .seconds),
            index: 2
        )
        #expect(fixture.player.source == source)
        try await fixture.player.cue(source: source)
        let list: String
        let listType: String
        switch source {
        case .videos:
            list = "first,second"
            listType = "playlist"
        case .playlist:
            list = "PLfixture"
            listType = "playlist"
        case .channel:
            list = "channel"
            listType = "user_uploads"
        case .video:
            Issue.record("Unexpected single-video fixture")
            return
        }
        #expect(try await fixture.calls() == [
            .init(name: "loadPlaylist", arguments: [.object([
                "list": .string(list),
                "listType": .string(listType),
                "startSeconds": .number(1.5),
                "index": .number(2)
            ])]),
            .init(name: "cuePlaylist", arguments: [.object([
                "list": .string(list),
                "listType": .string(listType)
            ])])
        ])
    }

    @Test("Failed loading and cueing preserve the previous source and retain JavaScript error context")
    func preservesSourceOnQueueFailure() async throws {
        let original = YouTubePlayer.Source.video(id: "original")
        let fixture = YouTubePlayerTestFixture(source: original)
        try await fixture.waitUntilReady()
        try await fixture.setError("Load rejected", for: "loadVideoById")
        await #expect {
            try await fixture.player.load(source: .video(id: "replacement"))
        } throws: { error in
            guard let error = error as? YouTubePlayer.APIError else {
                return false
            }
            #expect(error.reason?.contains("Load rejected") == true)
            #expect(error.javaScript?.contains("loadVideoById") == true)
            #expect(error.underlyingError != nil)
            return true
        }
        #expect(fixture.player.source == original)
        try await fixture.setError("Cue rejected", for: "cuePlaylist")
        await #expect {
            try await fixture.player.cue(source: .playlist(id: "replacement"))
        } throws: { error in
            guard let error = error as? YouTubePlayer.APIError else {
                return false
            }
            #expect(error.reason?.contains("Cue rejected") == true)
            #expect(error.javaScript?.contains("cuePlaylist") == true)
            return true
        }
        #expect(fixture.player.source == original)
        try await fixture.setError(nil, for: "loadVideoById")
        try await fixture.player.load(source: .video(id: "recovered"))
        #expect(fixture.player.source == .video(id: "recovered"))
    }

    @Test("Unencodable queueing parameters fail before JavaScript and preserve the source")
    func rejectsUnencodableQueueingParameters() async throws {
        let original = YouTubePlayer.Source.video(id: "original")
        let fixture = YouTubePlayerTestFixture(source: original)
        try await fixture.waitUntilReady()
        try await fixture.clearCalls()
        await #expect {
            try await fixture.player.load(
                source: .video(id: "replacement"),
                startTime: .init(value: .nan, unit: .seconds)
            )
        } throws: { error in
            guard let error = error as? YouTubePlayer.APIError else {
                return false
            }
            #expect(error.reason == "Failed to encode parameter to update the source")
            #expect(error.underlyingError is EncodingError)
            return true
        }
        #expect(fixture.player.source == original)
        #expect(try await fixture.calls().isEmpty)
    }

    @Test("Playlist navigation and getters preserve indices, flags, and optional results")
    func controlsPlaylist() async throws {
        let fixture = YouTubePlayerTestFixture()
        try await fixture.waitUntilReady()
        try await fixture.clearCalls()
        try await fixture.player.nextVideoInPlaylist()
        try await fixture.player.previousVideoInPlaylist()
        try await fixture.player.playVideoInPlaylist(at: 3)
        try await fixture.player.setLoopPlaylist(enabled: true)
        try await fixture.player.setShufflePlaylist(enabled: false)
        #expect(try await fixture.player.getPlaylist() == ["first", "second"])
        #expect(try await fixture.player.getPlaylistIndex() == 0)
        #expect(try await fixture.player.getPlaylistID() == "playlist")
        #expect(try await fixture.calls() == [
            .init(name: "nextVideo", arguments: []),
            .init(name: "previousVideo", arguments: []),
            .init(name: "playVideoAt", arguments: [.number(3)]),
            .init(name: "setLoop", arguments: [.bool(true)]),
            .init(name: "setShuffle", arguments: [.bool(false)]),
            .init(name: "getPlaylist", arguments: []),
            .init(name: "getPlaylistIndex", arguments: []),
            .init(name: "getPlaylistId", arguments: [])
        ])
        try await fixture.setResult(YouTubePlayerTestFixture.JSONValue.null, for: "getPlaylist")
        #expect(try await fixture.player.getPlaylist() == nil)
    }

}

// MARK: - Volume, Captions, and Modules

extension YouTubePlayerCommandTests {

    @Test("Volume commands and getters preserve Boolean and numeric responses")
    func controlsVolume() async throws {
        let fixture = YouTubePlayerTestFixture()
        try await fixture.waitUntilReady()
        try await fixture.clearCalls()
        try await fixture.player.mute()
        try await fixture.player.unmute()
        try await fixture.setResult(true, for: "isMuted")
        try await fixture.setResult(73, for: "getVolume")
        #expect(try await fixture.player.isMuted())
        #expect(try await fixture.player.getVolume() == 73)
        #expect(try await fixture.calls() == [
            .init(name: "mute", arguments: []),
            .init(name: "unMute", arguments: []),
            .init(name: "isMuted", arguments: []),
            .init(name: "getVolume", arguments: [])
        ])
    }

    @Test("Captions commands send the expected module options and structured language code")
    func configuresCaptions() async throws {
        let fixture = YouTubePlayerTestFixture()
        try await fixture.waitUntilReady()
        try await fixture.clearCalls()
        try await fixture.player.setCaptions(fontSize: .large)
        try await fixture.player.reloadCaptions()
        try await fixture.player.setCaptions(languageCode: "de-DE")
        #expect(try await fixture.calls() == [
            .init(name: "setOption", arguments: [.string("captions"), .string("fontSize"), .number(2)]),
            .init(name: "setOption", arguments: [.string("captions"), .string("reload"), .bool(true)]),
            .init(name: "setOption", arguments: [
                .string("captions"), .string("track"), .object(["languageCode": .string("de-DE")])
            ])
        ])
    }

    @Test("Module getters distinguish module enumeration from options and option values")
    func readsModuleOptions() async throws {
        let fixture = YouTubePlayerTestFixture()
        try await fixture.waitUntilReady()
        try await fixture.clearCalls()
        #expect(try await fixture.player.getModules() == [.captions])
        try await fixture.setResult(["fontSize", "track"], for: "getOptions")
        #expect(try await fixture.player.getModuleOptions(for: .captions) == [.fontSize, .track])
        try await fixture.setResult(2, for: "getOption")
        let fontSize = try await fixture.player.getModuleOption(
            module: .captions,
            option: .fontSize,
            converter: .typeCast(to: Int.self)
        )
        #expect(fontSize == 2)
        #expect(try await fixture.calls() == [
            .init(name: "getOptions", arguments: []),
            .init(name: "getOptions", arguments: [.string("captions")]),
            .init(name: "getOption", arguments: [.string("captions"), .string("fontSize")])
        ])
    }

    @Test("Captions getters decode API dictionaries into domain models")
    func decodesCaptionModels() async throws {
        let fixture = YouTubePlayerTestFixture()
        try await fixture.waitUntilReady()
        try await fixture.clearCalls()
        let track = YouTubePlayer.CaptionsTrack(
            id: "de",
            videoSubtitlesSystemID: ".de",
            isDefault: true,
            languageCode: "de",
            languageName: "Deutsch"
        )
        try await fixture.setResult(track, for: "getOption")
        #expect(try await fixture.player.getCaptionsTrack() == track)
        try await fixture.setResult([track], for: "getOption")
        #expect(try await fixture.player.getCaptionsTracks() == [track])
        let language = YouTubePlayer.CaptionsTranslationLanguage(
            languageCode: "en",
            languageName: "English"
        )
        try await fixture.setResult([language], for: "getOption")
        #expect(try await fixture.player.getCaptionsTranslationLanguages() == [language])
        #expect(try await fixture.calls() == [
            .init(name: "getOption", arguments: [.string("captions"), .string("track")]),
            .init(name: "getOption", arguments: [.string("captions"), .string("tracklist")]),
            .init(name: "getOption", arguments: [.string("captions"), .string("translationLanguages")])
        ])
    }

}

// MARK: - Evaluation and Errors

extension YouTubePlayerCommandTests {

    @Test("Public evaluation converts values, normalizes null, and discards unsupported void results")
    func evaluatesPublicJavaScript() async throws {
        let fixture = YouTubePlayerTestFixture()
        try await fixture.waitUntilReady()
        let answer: Int = try await fixture.player.evaluate(
            javaScript: "6 * 7",
            converter: .typeCast()
        )
        #expect(answer == 42)
        let values: [String] = try await fixture.player.evaluate(
            javaScript: "['one', '🌍']",
            converter: .typeCast()
        )
        #expect(values == ["one", "🌍"])
        let optionalValue: String? = try await fixture.player.evaluate(
            javaScript: "null",
            converter: .typeCast()
        )
        #expect(optionalValue == nil)
        try await fixture.player.evaluate(javaScript: "window.testVoidEffect = 42; (() => {})")
        #expect(try await fixture.value(for: "window.testVoidEffect", as: Int.self) == 42)
    }

    @Test("Conversion errors include the executed JavaScript and the incompatible response")
    func reportsConversionFailure() async throws {
        let fixture = YouTubePlayerTestFixture()
        try await fixture.waitUntilReady()
        try await fixture.setResult("not a duration", for: "getDuration")
        await #expect {
            try await fixture.player.getDuration()
        } throws: { error in
            guard let error = error as? YouTubePlayer.APIError else {
                return false
            }
            #expect(error.javaScript?.contains("getDuration") == true)
            #expect(error.javaScriptResponse == "not a duration")
            #expect(error.reason?.contains("Double") == true)
            return true
        }
    }

    @Test("JavaScript exceptions preserve WebKit error details through public evaluation")
    func reportsJavaScriptException() async throws {
        let fixture = YouTubePlayerTestFixture()
        try await fixture.waitUntilReady()
        await #expect {
            try await fixture.player.evaluate(javaScript: "throw new Error('fixture failure')")
        } throws: { error in
            guard let error = error as? YouTubePlayer.APIError else {
                return false
            }
            #expect(error.reason?.contains("fixture failure") == true)
            #expect(error.javaScript?.contains("throw new Error") == true)
            #expect(error.javaScriptResponse == nil)
            #expect(error.webKitErrorCode == .javaScriptExceptionOccurred)
            return true
        }
    }

    @Test("Embed-code retrieval falls back to player information and preserves the original failure if both fail")
    func fallsBackForEmbedCode() async throws {
        let fixture = YouTubePlayerTestFixture()
        try await fixture.waitUntilReady()
        try await fixture.setResult("<iframe>direct</iframe>", for: "getVideoEmbedCode")
        #expect(try await fixture.player.getVideoEmbedCode() == "<iframe>direct</iframe>")
        try await fixture.setError("Invalid player dimensions", for: "getVideoEmbedCode")
        try await fixture.setResult(
            YouTubePlayerTestFixture.JSONValue.object([
                "muted": .bool(false),
                "volume": .number(50),
                "playerState": .number(2),
                "playbackRate": .number(1),
                "availablePlaybackRates": .array([.number(1)]),
                "playbackQuality": .string("hd720"),
                "availableQualityLevels": .array([.string("hd720")]),
                "currentTime": .number(30),
                "duration": .number(120),
                "videoEmbedCode": .string("<iframe>fallback</iframe>"),
                "videoUrl": .string("https://www.youtube.com/watch?v=first"),
                "mediaReferenceTime": .number(0),
                "videoData": .object(["title": .string("Fixture")])
            ]),
            for: "playerInfo"
        )
        #expect(try await fixture.player.getVideoEmbedCode() == "<iframe>fallback</iframe>")
        try await fixture.setResult(YouTubePlayerTestFixture.JSONValue.null, for: "playerInfo")
        await #expect {
            try await fixture.player.getVideoEmbedCode()
        } throws: { error in
            guard let error = error as? YouTubePlayer.APIError else {
                return false
            }
            #expect(error.reason?.contains("Invalid player dimensions") == true)
            #expect(error.javaScript?.contains("getVideoEmbedCode") == true)
            return true
        }
    }

}
