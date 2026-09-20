import Foundation
import Testing
import WebKit
@testable import YouTubePlayerKit

// MARK: - YouTubePlayerNavigationTests

@MainActor
@Suite(.serialized)
struct YouTubePlayerNavigationTests {

    @Test(
        "Internal and non-HTTP navigations remain inside WebKit",
        arguments: [
            "about:blank",
            "https://www.youtube.com/embed/video",
            "https://accounts.google.com/o/oauth2/auth",
            "https://content.googleapis.com/static/proxy.html",
            "https://tpc.googlesyndication.com/sodar/example.html",
            "data:text/html,local"
        ]
    )
    func allowsInternalNavigation(
        urlString: String
    ) async throws {
        var openedURLs: [URL] = []
        let fixture = YouTubePlayerTestFixture(openURLAction: .init { url, _ in openedURLs.append(url) })
        try await fixture.waitUntilReady()
        let url = try #require(URL(string: urlString))
        let policy = await fixture.player.webView.webView(
            fixture.player.webView,
            decidePolicyFor: TestNavigationAction(url: url)
        )
        #expect(policy == .allow)
        await self.flushTasks()
        #expect(openedURLs.isEmpty)
    }

    @Test("Requests without a URL are cancelled without calling the external handler")
    func cancelsMissingNavigationURL() async throws {
        let fixture = YouTubePlayerTestFixture(openURLAction: .init { _, _ in
            Issue.record("A missing URL must not invoke the external handler")
        })
        try await fixture.waitUntilReady()
        let policy = await fixture.player.webView.webView(
            fixture.player.webView,
            decidePolicyFor: TestNavigationAction(url: nil)
        )
        #expect(policy == .cancel)
    }

    @Test("External HTTP navigation is cancelled and routed to the injected action exactly once")
    func routesExternalNavigation() async throws {
        var openedURLs: [URL] = []
        let fixture = YouTubePlayerTestFixture(openURLAction: .init { url, _ in openedURLs.append(url) })
        try await fixture.waitUntilReady()
        let url = try #require(URL(string: "https://example.org/article"))
        let policy = await fixture.player.webView.webView(
            fixture.player.webView,
            decidePolicyFor: TestNavigationAction(url: url)
        )
        #expect(policy == .cancel)
        try await self.waitUntil { openedURLs.count == 1 }
        await self.flushTasks()
        #expect(openedURLs == [url])
    }

    @Test("Popup requests route once and never create a second WebKit view")
    func routesPopupWithoutCreatingWebView() async throws {
        var openedURLs: [URL] = []
        let fixture = YouTubePlayerTestFixture(openURLAction: .init { url, _ in openedURLs.append(url) })
        try await fixture.waitUntilReady()
        let url = try #require(URL(string: "https://example.org/popup"))
        let createdView = fixture.player.webView.webView(
            fixture.player.webView,
            createWebViewWith: .init(),
            for: TestNavigationAction(url: url),
            windowFeatures: .init()
        )
        #expect(createdView == nil)
        try await self.waitUntil { openedURLs.count == 1 }
        await self.flushTasks()
        #expect(openedURLs == [url])
    }

    @Test("A different YouTube video opens inside the existing player")
    func loadsYouTubeNavigationInPlayer() async throws {
        var openedURLs: [URL] = []
        let fixture = YouTubePlayerTestFixture(
            source: .video(id: "first"),
            openURLAction: .init { url, _ in openedURLs.append(url) }
        )
        try await fixture.waitUntilReady()
        try await fixture.clearCalls()
        let url = try #require(URL(string: "https://www.youtube.com/watch?v=second"))
        await fixture.player.configuration.openURLAction(url: url, player: fixture.player)
        #expect(openedURLs.isEmpty)
        #expect(fixture.player.source == .video(id: "second"))
        #expect(try await fixture.calls() == [.init(name: "loadVideoById", arguments: [.object(["videoId": .string("second")])])])
    }

    @Test("Failed internal video loads fall back to the injected external action without changing source")
    func fallsBackAfterFailedVideoLoad() async throws {
        var openedURLs: [URL] = []
        let fixture = YouTubePlayerTestFixture(
            source: .video(id: "first"),
            openURLAction: .init { url, _ in openedURLs.append(url) }
        )
        try await fixture.waitUntilReady()
        try await fixture.setError("Unable to load the requested video", for: "loadVideoById")
        try await fixture.clearCalls()
        let url = try #require(URL(string: "https://www.youtube.com/watch?v=second"))
        await fixture.player.configuration.openURLAction(url: url, player: fixture.player)
        #expect(openedURLs == [url])
        #expect(fixture.player.source == .video(id: "first"))
        #expect(try await fixture.calls().map(\.name) == ["loadVideoById"])
    }

    @Test("Opening the current video delegates externally without reloading it")
    func opensCurrentVideoExternally() async throws {
        var openedURLs: [URL] = []
        let fixture = YouTubePlayerTestFixture(
            source: .video(id: "first"),
            openURLAction: .init { url, _ in openedURLs.append(url) }
        )
        try await fixture.waitUntilReady()
        try await fixture.clearCalls()
        let url = try #require(URL(string: "https://www.youtube.com/watch?v=first"))
        await fixture.player.configuration.openURLAction(url: url, player: fixture.player)
        #expect(openedURLs == [url])
        #expect(try await fixture.calls().isEmpty)
    }

}

// MARK: - Async Observation

private extension YouTubePlayerNavigationTests {

    /// Waits for a delegate-created task to invoke the injected action.
    func waitUntil(
        _ condition: () -> Bool
    ) async throws {
        let deadline = Date().addingTimeInterval(5)
        while !condition(), Date() < deadline {
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        try #require(condition(), "The navigation action did not complete within five seconds")
    }

    /// Drains queued main-actor work before asserting that no extra action occurred.
    func flushTasks() async {
        for _ in 0..<3 {
            await withCheckedContinuation { continuation in
                DispatchQueue.main.async { continuation.resume() }
            }
        }
    }

}

// MARK: - TestNavigationAction

/// Supplies a controlled navigation request to the real delegate implementation.
@MainActor
private final class TestNavigationAction: WKNavigationAction {

    // MARK: Properties

    /// The request supplied to the delegate.
    private let testRequest: URLRequest

    /// The request supplied to the delegate.
    override var request: URLRequest {
        return self.testRequest
    }

    // MARK: Initializer

    /// Creates a navigation action, including the missing-URL case.
    /// - Parameter url: The URL to navigate to.
    init(
        url: URL?
    ) {
        var request = URLRequest(url: URL(fileURLWithPath: "/"))
        request.url = url
        self.testRequest = request
        super.init()
    }

}
