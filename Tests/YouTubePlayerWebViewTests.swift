import Combine
import XCTest
@testable import YouTubePlayerKit

final class YouTubePlayerWebViewTests: XCTestCase {
    
    let player = YouTubePlayer(
        source: .url("https://www.youtube.com/watch?v=psL_5RIBqnY"),
        configuration: .init()
    )
    
    var cancellables = Set<AnyCancellable>()
    
    func testReady() {
    }
    
}
