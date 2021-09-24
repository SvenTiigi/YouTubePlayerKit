import XCTest
@testable import YouTubePlayerKit

final class YouTubePlayerSourceTests: XCTestCase {
    
    func testURLs() throws {
        let urls = [
            "https://youtube.com/watch?v=psL_5RIBqnY",
            "https://youtu.be/psL_5RIBqnY",
            "https://youtube.com/embed/psL_5RIBqnY",
            "https://youtube.com/c/iJustine",
            "https://youtube.com/user/iJustine",
        ]
        for url in urls {
            XCTAssertNotNil(YouTubePlayer.Source.url(url))
        }
    }
    
}
