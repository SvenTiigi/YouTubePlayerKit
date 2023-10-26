import XCTest
@testable import YouTubePlayerKit

final class YouTubePlayerSourceTests: XCTestCase {
    
    func testURLs() throws {
        let testCandidate = UUID().uuidString
        XCTAssertEqual(
            YouTubePlayer.Source.url("https://youtube.com/watch?v=\(testCandidate)"),
            .video(id: testCandidate)
        )
        XCTAssertEqual(
            YouTubePlayer.Source.url("https://youtu.be/\(testCandidate)"),
            .video(id: testCandidate)
        )
        XCTAssertEqual(
            YouTubePlayer.Source.url("https://youtube.com/_/\(testCandidate)"),
            .video(id: testCandidate)
        )
        XCTAssertEqual(
            YouTubePlayer.Source.url("https://youtube.com/c/\(testCandidate)"),
            .channel(name: testCandidate)
        )
        XCTAssertEqual(
            YouTubePlayer.Source.url("https://youtube.com/user/\(testCandidate)"),
            .channel(name: testCandidate)
        )
    }
    
}
