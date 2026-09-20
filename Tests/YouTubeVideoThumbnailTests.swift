import Foundation
import Testing
@testable import YouTubePlayerKit

// MARK: - YouTubeVideoThumbnailTests

struct YouTubeVideoThumbnailTests {

    @Test("Default and literal construction use the standard YouTube thumbnail URL")
    func defaultAndLiteralURLs() {
        let videoID = UUID().uuidString
        let thumbnail = YouTubeVideoThumbnail(videoID: videoID)
        let literal = YouTubeVideoThumbnail(stringLiteral: videoID)
        #expect(thumbnail == literal)
        #expect(thumbnail.url?.absoluteString == "https://img.youtube.com/vi/\(videoID)/sddefault.jpg")
    }

    @Test(
        "Each thumbnail resolution selects its corresponding image path",
        arguments: YouTubeVideoThumbnail.Resolution.allCases,
        ["img.youtube.com", "i.ytimg.com"]
    )
    func resolutionURLs(
        resolution: YouTubeVideoThumbnail.Resolution,
        host: String
    ) throws {
        let thumbnail = YouTubeVideoThumbnail(
            videoID: "video-id",
            resolution: resolution,
            host: host
        )
        let url = try #require(thumbnail.url)
        #expect(url.scheme == "https")
        #expect(url.host == host)
        #expect(url.path == "/vi/video-id/\(resolution.rawValue).jpg")
        #expect(try JSONDecoder().decode(YouTubeVideoThumbnail.self, from: JSONEncoder().encode(thumbnail)) == thumbnail)
    }

}
