import XCTest
@testable import YouTubePlayerKit

final class YouTubePlayerHTMLTests: XCTestCase {
    
    func testInit() throws {
        let input = UUID().uuidString
        let youTubePlayerOptions = YouTubePlayer.Options(json: input)
        let youTubePlayerHTML = try YouTubePlayer.HTML(options: youTubePlayerOptions)
        XCTAssert(youTubePlayerHTML.contents.contains(input))
    }
    
    func testUnavailableResourceError() {
        XCTAssertThrowsError(
            try YouTubePlayer.HTML(
                options: .init(json: .init()),
                resource: .init(
                    fileName: "UnavailableResource",
                    fileExtension: "unavailable"
                )
            )
        )
    }
    
}
