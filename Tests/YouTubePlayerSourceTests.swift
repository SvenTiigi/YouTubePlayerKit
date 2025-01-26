import Foundation
import Testing
@testable import YouTubePlayerKit

struct YouTubePlayerSourceTests {
    
    @Test
    func videoURLs() throws {
        let videoID = UUID().uuidString
        #expect(
            YouTubePlayer.Source(urlString: "https://www.youtube.com/watch?v=\(videoID)")
            ==
            .video(id: videoID)
        )
        #expect(
            YouTubePlayer.Source(urlString: "https://youtu.be/\(videoID)")
            ==
            .video(id: videoID)
        )
        #expect(
            YouTubePlayer.Source(urlString: "https://www.youtube.com/embed/\(videoID)")
            ==
            .video(id: videoID)
        )
        #expect(
            YouTubePlayer.Source(urlString: "https://www.youtube.com/shorts/\(videoID)")
            ==
            .video(id: videoID)
        )
        #expect(
            YouTubePlayer.Source(urlString: "https://www.youtube.com/live/\(videoID)")
            ==
            .video(id: videoID)
        )
        #expect(
            YouTubePlayer.Source(urlString: "https://m.youtube.com/watch?v=\(videoID)")
            ==
            .video(id: videoID)
        )
        #expect(
            YouTubePlayer.Source(urlString: "https://music.youtube.com/watch?v=\(videoID)")
            ==
            .video(id: videoID)
        )
        #expect(
            YouTubePlayer.Source(urlString: "https://gaming.youtube.com/watch?v=\(videoID)")
            ==
            .video(id: videoID)
        )
        #expect(
            YouTubePlayer.Source(urlString: "https://www.youtube-nocookie.com/embed/\(videoID)")
            ==
            .video(id: videoID)
        )
        #expect(
            YouTubePlayer.Source(urlString: "https://www.youtube.com/watch?v=\(videoID)&t=123")
            ==
            .video(id: videoID)
        )
        #expect(
            YouTubePlayer.Source(urlString: "https://www.youtube.com/watch?v=\(videoID)&feature=share&t=123")
            ==
            .video(id: videoID)
        )
        #expect(
            YouTubePlayer.Source.video(id: videoID).url?.absoluteString
            ==
            "https://www.youtube.com/watch?v=\(videoID)"
        )
    }
    
    @Test
    func playlistURLs() throws {
        let playlistID = UUID().uuidString
        #expect(
            YouTubePlayer.Source(urlString: "https://www.youtube.com/playlist?list=\(playlistID)")
            ==
            .playlist(id: playlistID)
        )
        #expect(
            YouTubePlayer.Source(urlString: "https://www.youtube.com/watch?v=dQw4w9WgXcQ&list=\(playlistID)")
            ==
            .playlist(id: playlistID)
        )
        #expect(
            YouTubePlayer.Source(urlString: "https://www.youtube.com/watch?list=\(playlistID)&v=dQw4w9WgXcQ")
            ==
            .playlist(id: playlistID)
        )
        #expect(
            YouTubePlayer.Source(urlString: "https://www.youtube.com/embed/videoseries?list=\(playlistID)")
            ==
            .playlist(id: playlistID)
        )
        #expect(
            YouTubePlayer.Source.playlist(id: playlistID).url?.absoluteString
            ==
            "https://www.youtube.com/playlist?list=\(playlistID)"
        )
    }
    
    @Test
    func channelURLs() throws {
        let channelName = UUID().uuidString
        #expect(
            YouTubePlayer.Source(urlString: "https://www.youtube.com/channel/\(channelName)")
            ==
            .channel(name: channelName)
        )
        #expect(
            YouTubePlayer.Source(urlString: "https://www.youtube.com/c/\(channelName)")
            ==
            .channel(name: channelName)
        )
        #expect(
            YouTubePlayer.Source(urlString: "https://www.youtube.com/user/\(channelName)")
            ==
            .channel(name: channelName)
        )
        #expect(
            YouTubePlayer.Source(urlString: "https://www.youtube.com/@\(channelName)")
            ==
            .channel(name: channelName)
        )
        #expect(
            YouTubePlayer.Source.channel(name: channelName).url?.absoluteString
            ==
            "https://www.youtube.com/@\(channelName)"
        )
    }
    
    @Test(
        arguments: [
            "https://example.com/watch?v=dQw4w9WgXcQ",
            "https://www.youtube.com/watch",
            "not a url",
            ""
        ]
    )
    func invalidURLString(_ urlString: String) throws {
        #expect(YouTubePlayer.Source(urlString: urlString) == nil)
    }
    
    @Test
    func properties() throws {
        let id = UUID().uuidString
        let videoSource = YouTubePlayer.Source.video(id: id)
        #expect(videoSource.videoID == id)
        #expect(videoSource.playlistID == nil)
        #expect(videoSource.channelName == nil)
        let playlistSource = YouTubePlayer.Source.playlist(id: id)
        #expect(playlistSource.playlistID == id)
        #expect(playlistSource.videoID == nil)
        #expect(playlistSource.channelName == nil)
        let channelSource = YouTubePlayer.Source.channel(name: id)
        #expect(channelSource.channelName == id)
        #expect(channelSource.videoID == nil)
        #expect(channelSource.playlistID == nil)
    }
    
}
