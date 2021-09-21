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
        let expectation = self.expectation(description: #function)
        let webView = YouTubePlayerWebView(
            player: self.player
        )
        webView
            .statePublisher
            .filter { $0 == .ready }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        self.wait(for: [expectation], timeout: 30)
    }
    
}
