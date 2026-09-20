import Combine
import Foundation
import Testing
@testable import YouTubePlayerKit

// MARK: - YouTubePlayerLifecycleTests

@MainActor
@Suite(.serialized, .timeLimit(.minutes(1)))
struct YouTubePlayerLifecycleTests {

    @Test("Commands wait for readiness and execute exactly once")
    func waitsBeforeExecutingCommands() async throws {
        let fixture = YouTubePlayerTestFixture(automaticallyReady: false)
        try await fixture.waitForPage()
        try await fixture.clearCalls()
        var started = false
        var result: Result<Void, any Error>?
        let task = Task {
            started = true
            do {
                try await fixture.player.play()
                result = .success(())
            } catch {
                result = .failure(error)
            }
        }
        defer { task.cancel() }
        try await self.waitUntil { started }
        #expect(try await fixture.calls().isEmpty)
        #expect(result == nil)
        try await fixture.emit(name: .ready)
        try await self.waitUntil { result != nil }
        try #require(result).get()
        #expect(try await fixture.calls().map(\.name) == ["playVideo"])
    }

    @Test("Cancelling a readiness wait prevents later JavaScript execution")
    func cancelsPendingCommand() async throws {
        let fixture = YouTubePlayerTestFixture(automaticallyReady: false)
        try await fixture.waitForPage()
        try await fixture.clearCalls()
        var started = false
        var result: Result<Void, any Error>?
        let task = Task {
            started = true
            do {
                try await fixture.player.play()
                result = .success(())
            } catch {
                result = .failure(error)
            }
        }
        defer { task.cancel() }
        try await self.waitUntil { started }
        task.cancel()
        try await self.waitUntil { result != nil }
        guard case .failure(let error) = result else {
            Issue.record("A cancelled command must fail")
            return
        }
        #expect((error as? YouTubePlayer.APIError)?.underlyingError is CancellationError)
        try await fixture.emit(name: .ready)
        try await fixture.waitUntilReady()
        #expect(try await fixture.calls().isEmpty)
    }

    @Test("Already-cancelled commands do not execute even on a ready player")
    func rejectsAlreadyCancelledCommand() async throws {
        let fixture = YouTubePlayerTestFixture()
        try await fixture.waitUntilReady()
        try await fixture.clearCalls()
        let task = Task {
            try await fixture.player.play()
        }
        task.cancel()
        do {
            try await task.value
            Issue.record("A cancelled command must fail")
        } catch {
            #expect((error as? YouTubePlayer.APIError)?.underlyingError is CancellationError)
        }
        #expect(try await fixture.calls().isEmpty)
    }

    @Test("A readiness failure fails waiting commands and later recovery remains usable")
    func propagatesReadinessFailure() async throws {
        let fixture = YouTubePlayerTestFixture(automaticallyReady: false)
        try await fixture.waitForPage()
        try await fixture.clearCalls()
        var started = false
        var result: Result<Void, any Error>?
        let task = Task {
            started = true
            do {
                try await fixture.player.play()
                result = .success(())
            } catch {
                result = .failure(error)
            }
        }
        defer { task.cancel() }
        try await self.waitUntil { started }
        try await fixture.emit(name: .error, data: 100)
        try await self.waitUntil { result != nil }
        guard case .failure(let error) = result,
              let underlyingError = (error as? YouTubePlayer.APIError)?.underlyingError as? YouTubePlayer.Error else {
            Issue.record("The waiting command must retain the player error")
            return
        }
        #expect(YouTubePlayer.State.error(underlyingError) == .error(.notFound))
        #expect(try await fixture.calls().isEmpty)
        try await fixture.player.load(source: .video(id: "recovered-video"))
        #expect(fixture.player.source == .video(id: "recovered-video"))
    }

    @Test("Public reload replaces the document and observes fresh readiness")
    func reloadsReadyPlayer() async throws {
        let fixture = YouTubePlayerTestFixture()
        try await fixture.waitUntilReady()
        try await fixture.evaluate("window.previousDocument = true;")
        var states: [YouTubePlayer.State] = []
        let subscription = fixture.player.stateSubject.sink { states.append($0) }
        defer { subscription.cancel() }
        try await fixture.player.reload()
        #expect(states == [.ready, .idle, .ready])
        #expect(try await fixture.value(for: "window.previousDocument === true", as: Bool.self) == false)
        try await fixture.player.play()
        #expect(try await fixture.calls().contains { $0.name == "playVideo" })
    }

    @Test("Reloading an idle document does not wait for the old player to become ready")
    func reloadsIdlePlayer() async throws {
        let fixture = YouTubePlayerTestFixture(automaticallyReady: false)
        try await fixture.waitForPage()
        try await fixture.evaluate("window.previousDocument = true;")
        var result: Result<Void, any Error>?
        let task = Task {
            do {
                try await fixture.player.reload()
                result = .success(())
            } catch {
                result = .failure(error)
            }
        }
        defer { task.cancel() }
        try await self.waitForReplacementDocument(fixture)
        #expect(result == nil)
        try await fixture.emit(name: .ready)
        try await self.waitUntil { result != nil }
        try #require(result).get()
    }

    @Test("Public reload propagates a player error from the replacement document")
    func propagatesReloadFailure() async throws {
        let fixture = YouTubePlayerTestFixture(automaticallyReady: false)
        try await fixture.waitForPage()
        try await fixture.emit(name: .ready)
        try await fixture.waitUntilReady()
        try await fixture.evaluate("window.previousDocument = true;")
        var result: Result<Void, any Error>?
        let task = Task {
            do {
                try await fixture.player.reload()
                result = .success(())
            } catch {
                result = .failure(error)
            }
        }
        defer { task.cancel() }
        try await self.waitForReplacementDocument(fixture)
        try await fixture.emit(name: .iFrameApiFailedToLoad)
        try await self.waitUntil { result != nil }
        guard case .failure(let error) = result,
              let playerError = error as? YouTubePlayer.Error else {
            Issue.record("Reload must propagate the replacement document's error")
            return
        }
        #expect(YouTubePlayer.State.error(playerError) == .error(.iFrameApiFailedToLoad))
    }

    @Test("Cancelling reload throws instead of reporting success")
    func cancelsReload() async throws {
        let fixture = YouTubePlayerTestFixture(automaticallyReady: false)
        try await fixture.waitForPage()
        try await fixture.evaluate("window.previousDocument = true;")
        var result: Result<Void, any Error>?
        let task = Task {
            do {
                try await fixture.player.reload()
                result = .success(())
            } catch {
                result = .failure(error)
            }
        }
        defer { task.cancel() }
        try await self.waitForReplacementDocument(fixture)
        task.cancel()
        try await self.waitUntil { result != nil }
        guard case .failure(let error) = result else {
            Issue.record("Cancelled reload must fail")
            return
        }
        #expect(error is CancellationError)
    }

    @Test("Cancelled readiness waits release the player and WebView")
    func releasesCancelledPlayer() async throws {
        weak var releasedPlayer: YouTubePlayer?
        weak var releasedWebView: YouTubePlayerWebView?
        do {
            let fixture = YouTubePlayerTestFixture(automaticallyReady: false)
            try await fixture.waitForPage()
            releasedPlayer = fixture.player
            releasedWebView = fixture.player.webView
            var started = false
            var finished = false
            let task = Task { [player = fixture.player] in
                started = true
                try? await player.play()
                finished = true
            }
            try await self.waitUntil { started }
            task.cancel()
            try await self.waitUntil { finished }
        }
        try await self.waitUntil { releasedPlayer == nil && releasedWebView == nil }
    }

    @Test("Cancellation after dispatch does not leave Swift source behind a successful JavaScript load")
    func preservesDispatchedSourceUpdate() async throws {
        let fixture = YouTubePlayerTestFixture(source: .video(id: "original"))
        try await fixture.waitUntilReady()
        try await fixture.evaluate(
            """
            Object.defineProperty(window.testPlayerResults, 'loadVideoById', {
                get() {
                    sendYouTubePlayerEvent('onCancelOperation');
                    return null;
                }
            });
            """
        )
        var task: Task<Void, any Error>?
        var didComplete = false
        var cancelledBeforeCompletion = false
        let subscription = fixture.player.webView.eventSubject.sink { event in
            if event.playerEvent?.name == "onCancelOperation" {
                cancelledBeforeCompletion = !didComplete
                task?.cancel()
            }
        }
        defer { subscription.cancel() }
        task = Task {
            defer { didComplete = true }
            try await fixture.player.load(source: .video(id: "replacement"))
        }
        try await task?.value
        #expect(cancelledBeforeCompletion)
        #expect(task?.isCancelled == true)
        #expect(fixture.player.source == .video(id: "replacement"))
    }

    @Test("Cancellation during destruction still replaces the destroyed player document")
    func replacesDocumentAfterCancelledDestruction() async throws {
        let fixture = YouTubePlayerTestFixture()
        try await fixture.waitUntilReady()
        try await fixture.evaluate(
            """
            window.previousDocument = true;
            Object.defineProperty(window.testPlayerResults, 'destroy', {
                get() {
                    sendYouTubePlayerEvent('onCancelOperation');
                    return null;
                }
            });
            """
        )
        var task: Task<Void, any Error>?
        var didComplete = false
        var cancelledBeforeCompletion = false
        let subscription = fixture.player.webView.eventSubject.sink { event in
            if event.playerEvent?.name == "onCancelOperation" {
                cancelledBeforeCompletion = !didComplete
                task?.cancel()
            }
        }
        defer { subscription.cancel() }
        task = Task {
            defer { didComplete = true }
            try await fixture.player.reload()
        }
        do {
            try await task?.value
            Issue.record("Reload must report cancellation to its caller")
        } catch {
            #expect(error is CancellationError)
        }
        #expect(cancelledBeforeCompletion)
        try await self.waitForReplacementDocument(fixture)
        try await fixture.waitUntilReady()
        try await fixture.player.play()
    }

}

// MARK: - Waiting

private extension YouTubePlayerLifecycleTests {

    /// Waits for a main-actor condition without leaving failed operations suspended indefinitely.
    /// - Parameter condition: The condition to observe.
    func waitUntil(
        _ condition: () -> Bool
    ) async throws {
        let deadline = Date().addingTimeInterval(5)
        while !condition(), Date() < deadline {
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        try #require(condition(), "The lifecycle operation did not complete within five seconds")
    }

    /// Waits until reload has replaced a marked document and installed its local API.
    /// - Parameter fixture: The player fixture.
    func waitForReplacementDocument(
        _ fixture: YouTubePlayerTestFixture
    ) async throws {
        let deadline = Date().addingTimeInterval(5)
        while Date() < deadline {
            let replaced = try? await fixture.value(
                for: "document.readyState === 'complete' && window.previousDocument !== true && typeof youtubePlayer === 'object'",
                as: Bool.self
            )
            if replaced == true {
                return
            }
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        try #require(Bool(false), "Reload did not replace the old document within five seconds")
    }

}
