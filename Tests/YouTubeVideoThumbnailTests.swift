import Testing
import Foundation
@testable import YouTubePlayerKit

struct YouTubeVideoThumbnailTests {
    
    @Test
    func defaultInitialization() {
        let videoID = UUID().uuidString
        let videoThumbnail = YouTubeVideoThumbnail(videoID: videoID)
        #expect(videoThumbnail.videoID == videoID)
        #expect(videoThumbnail.resolution == .standard)
        #expect(videoThumbnail.host == "img.youtube.com")
    }
    
    @Test
    func stringLiteralInitialization() {
        let videoID = UUID().uuidString
        let videoThumbnail = YouTubeVideoThumbnail(stringLiteral: videoID)
        #expect(videoThumbnail.videoID == videoID)
        #expect(videoThumbnail.resolution == .standard)
        #expect(videoThumbnail.host == "img.youtube.com")
    }
    
    @Test
    func customInitialization() {
        let videoID = UUID().uuidString
        let resolution = YouTubeVideoThumbnail.Resolution.allCases.randomElement() ?? .default
        let host = UUID().uuidString.components(separatedBy: "-").first ?? "host"
        let videoThumbnail = YouTubeVideoThumbnail(
            videoID: videoID,
            resolution: resolution,
            host: host
        )
        #expect(videoThumbnail.videoID == videoID)
        #expect(videoThumbnail.resolution == resolution)
        #expect(videoThumbnail.host == host)
    }
    
    @Test
    func url() {
        let videoID = UUID().uuidString
        let resolution = YouTubeVideoThumbnail.Resolution.allCases.randomElement() ?? .default
        let host = UUID().uuidString.components(separatedBy: "-").first ?? "host"
        let videoThumbnail = YouTubeVideoThumbnail(
            videoID: videoID,
            resolution: resolution,
            host: host
        )
        #expect(videoThumbnail.url == URL(string: "https://\(host)/vi/\(videoID)/\(resolution.rawValue).jpg"))
    }
    
    @MainActor
    @Test(
        arguments: YouTubeVideoThumbnail.Resolution.allCases
    )
    func image(
        resolution: YouTubeVideoThumbnail.Resolution
    ) async throws {
        let videoThumbnail = YouTubeVideoThumbnail(
            videoID: "psL_5RIBqnY",
            resolution: resolution
        )
        #expect(try await videoThumbnail.image() != nil)
    }
    
    @MainActor
    @Test
    func imageWithInvalidVideoID() async throws {
        let videoThumbnail = YouTubeVideoThumbnail(videoID: UUID().uuidString)
        #expect(try await videoThumbnail.image() == nil)
    }
    
}
