import Foundation
import Testing
@testable import YouTubePlayerKit

struct YouTubePlayerSourceTests {
    
    @Test("Source identity reflects its video identifiers, playlist identifier, or channel name")
    func identifiableConformance() throws {
        let id = UUID().uuidString
        #expect(YouTubePlayer.Source.video(id: id).id == id)
        #expect(YouTubePlayer.Source.videos(ids: [id, id]).id == "\(id),\(id)")
        #expect(YouTubePlayer.Source.playlist(id: id).id == id)
        #expect(YouTubePlayer.Source.channel(name: id).id == id)
    }
    
    @Test("An array literal creates a source containing the supplied video identifiers")
    func arrayLiteralExpression() throws {
        let id = UUID().uuidString
        let source: YouTubePlayer.Source = [id]
        #expect(source == .videos(ids: [id]))
    }
    
    @Test("A single-video source exposes only its video identifier")
    func videoIDProperty() throws {
        let id = UUID().uuidString
        let source: YouTubePlayer.Source = .video(id: id)
        #expect(source.videoID == id)
        #expect(source.videoIDs == nil)
        #expect(source.playlistID == nil)
        #expect(source.channelName == nil)
    }
    
    @Test("A multiple-video source exposes only its video identifiers")
    func videoIDsProperty() throws {
        let id = UUID().uuidString
        let source: YouTubePlayer.Source = .videos(ids: [id])
        #expect(source.videoID == nil)
        #expect(source.videoIDs == [id])
        #expect(source.playlistID == nil)
        #expect(source.channelName == nil)
    }
    
    @Test("A playlist source exposes only its playlist identifier")
    func playlistIDProperty() throws {
        let id = UUID().uuidString
        let source: YouTubePlayer.Source = .playlist(id: id)
        #expect(source.videoID == nil)
        #expect(source.videoIDs == nil)
        #expect(source.playlistID == id)
        #expect(source.channelName == nil)
    }
    
    @Test("A channel source exposes only its channel name")
    func channelNameProperty() throws {
        let id = UUID().uuidString
        let source: YouTubePlayer.Source = .channel(name: id)
        #expect(source.videoID == nil)
        #expect(source.videoIDs == nil)
        #expect(source.playlistID == nil)
        #expect(source.channelName == id)
    }
    
    @Test("A video source generates a watch URL unless its identifier is empty")
    func videoURLGeneration() throws {
        let id = UUID().uuidString
        #expect(
            YouTubePlayer.Source.video(id: id).url?.absoluteString
            ==
            "https://www.youtube.com/watch?v=\(id)"
        )
        #expect(YouTubePlayer.Source.video(id: .init()).url == nil)
    }
    
    @Test("A multiple-video source generates an ordered watch URL unless its list is empty")
    func videosURLGeneration() throws {
        let id = UUID().uuidString
        #expect(
            YouTubePlayer.Source.videos(ids: [id, id]).url?.absoluteString
            ==
            "https://www.youtube.com/watch_videos?video_ids=\(id),\(id)"
        )
        #expect(YouTubePlayer.Source.videos(ids: .init()).url == nil)
    }
    
    @Test("A playlist source generates a playlist URL unless its identifier is empty")
    func playlistURLGeneration() throws {
        let id = UUID().uuidString
        #expect(
            YouTubePlayer.Source.playlist(id: id).url?.absoluteString
            ==
            "https://www.youtube.com/playlist?list=\(id)"
        )
        #expect(YouTubePlayer.Source.playlist(id: .init()).url == nil)
    }
    
    @Test("A channel source generates a handle URL unless its name is empty")
    func channelURLGeneration() throws {
        let id = UUID().uuidString
        #expect(
            YouTubePlayer.Source.channel(name: id).url?.absoluteString
            ==
            "https://www.youtube.com/@\(id)"
        )
        #expect(YouTubePlayer.Source.channel(name: .init()).url == nil)
    }
    
    @Test(
        "Supported YouTube video URL formats resolve to the same video source",
        arguments: [
            "https://youtu.be/VIDEO_ID",
            "https://www.youtube.com/watch?v=VIDEO_ID",
            "https://www.youtube.com/embed/VIDEO_ID",
            "https://www.youtube.com/shorts/VIDEO_ID",
            "https://www.youtube.com/live/VIDEO_ID",
            "https://www.youtube.com/v/VIDEO_ID",
            "https://www.youtube.com/e/VIDEO_ID"
        ]
    )
    func videoURLParsing(_ urlString: String) throws {
        #expect(YouTubePlayer.Source(urlString: urlString) == .video(id: "VIDEO_ID"))
    }
    
    @Test(
        "A watch-videos URL preserves the order of its video identifiers",
        arguments: [
            "https://www.youtube.com/watch_videos?video_ids=VIDEO_ID_1,VIDEO_ID_2"
        ]
    )
    func videosURLParsing(_ urlString: String) throws {
        #expect(
            YouTubePlayer.Source(urlString: urlString)
            ==
            .videos(ids: ["VIDEO_ID_1", "VIDEO_ID_2"])
        )
    }
    
    @Test(
        "Playlist, watch, and embedded-series URLs resolve to the specified playlist",
        arguments: [
            "https://www.youtube.com/playlist?list=PLAYLIST_ID",
            "https://www.youtube.com/watch?v=abc&list=PLAYLIST_ID",
            "https://www.youtube.com/embed/videoseries?list=PLAYLIST_ID"
        ]
    )
    func playlistURLParsing(_ urlString: String) throws {
        #expect(YouTubePlayer.Source(urlString: urlString) == .playlist(id: "PLAYLIST_ID"))
    }
    
    @Test(
        "Supported YouTube channel URL formats resolve to the same channel source",
        arguments: [
            "https://www.youtube.com/channel/CHANNEL_NAME",
            "https://www.youtube.com/c/CHANNEL_NAME",
            "https://www.youtube.com/user/CHANNEL_NAME",
            "https://www.youtube.com/@CHANNEL_NAME",
            "https://www.youtube.com/feed/CHANNEL_NAME"
        ]
    )
    func channelURLParsing(_ urlString: String) throws {
        #expect(YouTubePlayer.Source(urlString: urlString) == .channel(name: "CHANNEL_NAME"))
    }
    
    @Test(
        "Malformed URLs and URLs with missing source identifiers are rejected",
        arguments: [
            "https://www.youtube.com/watch",
            "https://www.youtube.com/watch?v=",
            "https://www.youtube.com/playlist?list=",
            "https://www.youtube.com/@",
            "not a url",
            ""
        ]
    )
    func invalidURLParsing(_ urlString: String) throws {
        #expect(YouTubePlayer.Source(urlString: urlString) == nil)
    }

    @Test(
        "Source parsing accepts supported YouTube hosts and HTTP schemes",
        arguments: [
            "https://youtube.com/watch?v=VIDEO_ID",
            "http://www.youtube.com/watch?v=VIDEO_ID",
            "https://m.youtube.com/watch?v=VIDEO_ID",
            "https://www.youtube-nocookie.com/embed/VIDEO_ID",
            "https://YOUTU.BE/VIDEO_ID"
        ]
    )
    func acceptsYouTubeHosts(
        urlString: String
    ) {
        #expect(YouTubePlayer.Source(urlString: urlString) == .video(id: "VIDEO_ID"))
    }

    @Test(
        "YouTube-shaped URLs on unrelated hosts and unsupported schemes are rejected",
        arguments: [
            "https://example.com/watch?v=VIDEO_ID",
            "https://youtube.com.evil.example/watch?v=VIDEO_ID",
            "https://notyoutube.com/embed/VIDEO_ID",
            "https://www.youtube-nocookie.com.evil.example/embed/VIDEO_ID",
            "https://youtu.be.evil.example/VIDEO_ID",
            "https://www.youtu.be/VIDEO_ID",
            "https://youtube.com@evil.example/watch?v=VIDEO_ID",
            "ftp://youtube.com/watch?v=VIDEO_ID",
            "file:///watch?v=VIDEO_ID",
            "youtube://youtube.com/watch?v=VIDEO_ID"
        ]
    )
    func rejectsMisleadingURLs(
        urlString: String
    ) {
        #expect(YouTubePlayer.Source(urlString: urlString) == nil)
    }

    @Test("Escaped query identifiers round-trip without turning into additional parameters")
    func preservesEscapedIdentifiers() throws {
        let identifier = "video+id&list=other?#fragment"
        let source = YouTubePlayer.Source.video(id: identifier)
        let url = try #require(source.url)
        #expect(YouTubePlayer.Source(url: url) == source)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        #expect(components.queryItems?.count == 1)
        #expect(components.queryItems?.first?.value == identifier)
        #expect(components.fragment == nil)
    }

    @Test("Playlist selection takes precedence over a video and duplicate values retain their first occurrence")
    func resolvesConflictingParameters() {
        #expect(
            YouTubePlayer.Source(urlString: "https://youtube.com/watch?v=first&v=second&list=playlist&list=other")
            == .playlist(id: "playlist")
        )
        #expect(
            YouTubePlayer.Source(urlString: "https://youtube.com/watch?v=first&v=second&list=")
            == .video(id: "first")
        )
    }

    @Test(
        "Missing and empty source query values do not create a playable source",
        arguments: [
            "https://youtube.com/watch?v",
            "https://youtube.com/watch?v=&v=second",
            "https://youtube.com/watch_videos?video_ids=",
            "https://youtube.com/playlist?list",
            "https://youtu.be/"
        ]
    )
    func rejectsEmptySourceValues(
        urlString: String
    ) {
        #expect(YouTubePlayer.Source(urlString: urlString) == nil)
    }
    
}
