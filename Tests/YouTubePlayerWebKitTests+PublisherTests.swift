import Combine
import Foundation
import Testing
@testable import YouTubePlayerKit

// MARK: - YouTubePlayerWebKitTests.PublisherTests

extension YouTubePlayerWebKitTests {

    @MainActor
    struct PublisherTests {}

}

// MARK: - Tests

extension YouTubePlayerWebKitTests.PublisherTests {

    @Test("State publishers deliver initial values and suppress consecutive duplicates")
    func publishesDistinctStateTransitions() async throws {
        let player = self.makePlayer()
        var states: [YouTubePlayer.State] = []
        var playbackStates: [YouTubePlayer.PlaybackState] = []
        let stateSubscription = player.statePublisher.sink { states.append($0) }
        let playbackSubscription = player.playbackStatePublisher.sink { playbackStates.append($0) }
        defer {
            stateSubscription.cancel()
            playbackSubscription.cancel()
        }
        await self.flushEvents()
        #expect(states == [.idle])
        #expect(playbackStates.isEmpty)
        self.send(.ready, to: player)
        self.send(.ready, to: player)
        self.send(.stateChange, data: "1", to: player)
        self.send(.stateChange, data: "1", to: player)
        self.send(.stateChange, data: "2", to: player)
        self.send(.stateChange, data: "2", to: player)
        self.send(.stateChange, data: "1", to: player)
        await self.flushEvents()
        #expect(states == [.idle, .ready])
        #expect(playbackStates == [.playing, .paused, .playing])
        #expect(player.isPlaying)
        #expect(!player.isPaused && !player.isBuffering && !player.isCued && !player.isEnded)
        var lateStates: [YouTubePlayer.PlaybackState] = []
        let lateSubscription = player.playbackStatePublisher.sink { lateStates.append($0) }
        defer { lateSubscription.cancel() }
        await self.flushEvents()
        #expect(lateStates == [.playing])
    }

    @Test("Player errors recover on playback while malformed and future payloads remain observable")
    func recoversFromErrorsWithoutDiscardingRawEvents() async {
        let player = self.makePlayer()
        var states: [YouTubePlayer.State] = []
        var events: [YouTubePlayer.Event] = []
        let stateSubscription = player.statePublisher.sink { states.append($0) }
        let eventSubscription = player.eventPublisher.sink { events.append($0) }
        defer {
            stateSubscription.cancel()
            eventSubscription.cancel()
        }
        self.send(.error, data: "100", to: player)
        self.send(.stateChange, data: "-1", to: player)
        self.send(.error, data: "not-a-number", to: player)
        self.send(.error, data: "999", to: player)
        self.send(.stateChange, data: "not-a-number", to: player)
        self.send("onFutureEvent", data: "opaque payload", to: player)
        await self.flushEvents()
        #expect(player.state == .error(.notFound))
        #expect(player.playbackState == .unstarted)
        self.send(.stateChange, data: "1", to: player)
        await self.flushEvents()
        #expect(states == [.idle, .error(.notFound), .ready])
        #expect(player.playbackState == .playing)
        #expect(events.count == 7)
        #expect(events[5].name == "onFutureEvent")
        #expect(events[5].data?.value == "opaque payload")
    }

    @Test("WebKit failures update lifecycle state without appearing as player events")
    func publishesNavigationAndContentProcessFailures() async {
        let player = self.makePlayer()
        var states: [YouTubePlayer.State] = []
        var events: [YouTubePlayer.Event] = []
        let stateSubscription = player.statePublisher.sink { states.append($0) }
        let eventSubscription = player.eventPublisher.sink { events.append($0) }
        defer {
            stateSubscription.cancel()
            eventSubscription.cancel()
        }
        let error = URLError(.networkConnectionLost)
        player.webView.eventSubject.send(.didFailProvisionalNavigation(error))
        player.webView.eventSubject.send(.didFailNavigation(error))
        player.webView.eventSubject.send(.webContentProcessDidTerminate)
        self.send(.ready, to: player)
        await self.flushEvents()
        #expect(states == [
            .idle,
            .error(.didFailProvisionalNavigation(error)),
            .error(.didFailNavigation(error)),
            .error(.webContentProcessDidTerminate),
            .ready
        ])
        #expect(events.map(\.name) == [.ready])
    }

    @Test("Time, quality, volume, fullscreen, and autoplay publishers filter and convert their own events")
    func filtersAndConvertsEventPayloads() async {
        let player = self.makePlayer()
        var times: [Measurement<UnitDuration>] = []
        var qualities: [YouTubePlayer.PlaybackQuality] = []
        var volumes: [YouTubePlayer.VolumeState] = []
        var fullscreenStates: [YouTubePlayer.FullscreenState] = []
        var autoplayCount = 0
        let subscriptions: [AnyCancellable] = [
            player.currentTimePublisher.sink { times.append($0) },
            player.playbackQualityPublisher.sink { qualities.append($0) },
            player.volumeStatePublisher.sink { volumes.append($0) },
            player.fullscreenStatePublisher.sink { fullscreenStates.append($0) },
            player.autoplayBlockedPublisher.sink { autoplayCount += 1 }
        ]
        defer { subscriptions.forEach { $0.cancel() } }
        self.send(.videoProgress, data: "12.5", to: player)
        self.send(.videoProgress, data: "invalid", to: player)
        self.send(.videoProgress, to: player)
        self.send(.playbackQualityChange, data: "hd1080", to: player)
        self.send(.playbackQualityChange, data: "future-quality", to: player)
        self.send(.playbackQualityChange, to: player)
        self.send(.volumeChange, data: #"{"muted":true,"volume":25,"unstorable":false}"#, to: player)
        self.send(.volumeChange, data: #"{"volume":25}"#, to: player)
        self.send(.volumeChange, data: "malformed", to: player)
        self.send(.fullscreenChange, data: #"{"fullscreen":true,"videoId":"video","time":32.5}"#, to: player)
        self.send(.fullscreenChange, data: #"{"fullscreen":"true"}"#, to: player)
        self.send(.fullscreenChange, to: player)
        self.send(.autoplayBlocked, to: player)
        self.send("onFutureEvent", data: "12.5", to: player)
        await self.flushEvents()
        #expect(times == [.init(value: 12.5, unit: .seconds)])
        #expect(qualities == [.hd1080, .init(name: "future-quality")])
        #expect(volumes == [.init(isMuted: true, volume: 25, isUnstorable: false)])
        #expect(fullscreenStates == [.init(isFullscreen: true, videoID: "video", time: .init(value: 32.5, unit: .seconds))])
        #expect(autoplayCount == 1)
    }

    @Test("Cancelling an event subscription stops delivery and releases the player")
    func cancelsEventSubscription() async {
        weak var releasedPlayer: YouTubePlayer?
        var count = 0
        do {
            let player = self.makePlayer()
            releasedPlayer = player
            let subscription = player.eventPublisher.sink { _ in count += 1 }
            self.send("onFutureEvent", to: player)
            await self.flushEvents()
            #expect(count == 1)
            subscription.cancel()
            self.send("onFutureEvent", to: player)
            await self.flushEvents()
            #expect(count == 1)
        }
        await self.flushEvents()
        #expect(releasedPlayer == nil)
    }

    @Test("Reading the playback-rate publisher does not start a getter before subscription")
    func defersPlaybackRateGetterUntilSubscription() async throws {
        let fixture = YouTubePlayerTestFixture()
        try await fixture.waitUntilReady()
        try await fixture.clearCalls()
        let publisher = fixture.player.playbackRatePublisher
        await self.flushEvents()
        #expect(try await fixture.calls().isEmpty)
        var values: [YouTubePlayer.PlaybackRate] = []
        let subscription = publisher.sink { values.append($0) }
        defer { subscription.cancel() }
        try await self.waitUntil { values.count == 1 }
        #expect(values == [.normal])
        #expect(try await fixture.calls().map(\.name) == ["getPlaybackRate"])
    }

    @Test("Playback-rate subscriptions share their initial getter and preserve future numeric rates")
    func sharesPlaybackRateGetterAndConvertsEvents() async throws {
        let fixture = YouTubePlayerTestFixture()
        try await fixture.waitUntilReady()
        try await fixture.setResult(1.25, for: "getPlaybackRate")
        try await fixture.clearCalls()
        let publisher = fixture.player.playbackRatePublisher
        var firstValues: [YouTubePlayer.PlaybackRate] = []
        var secondValues: [YouTubePlayer.PlaybackRate] = []
        let firstSubscription = publisher.sink { firstValues.append($0) }
        let secondSubscription = publisher.sink { secondValues.append($0) }
        defer {
            firstSubscription.cancel()
            secondSubscription.cancel()
        }
        try await self.waitUntil { firstValues.count == 1 && secondValues.count == 1 }
        try await fixture.emit(name: .playbackRateChange, data: "malformed")
        try await fixture.emit(name: .playbackRateChange)
        try await fixture.emit(name: .videoProgress, data: 3.25)
        try await fixture.emit(name: .playbackRateChange, data: 3.25)
        try await self.waitUntil { firstValues.count == 2 && secondValues.count == 2 }
        #expect(firstValues == [.oneQuarterFaster, .init(value: 3.25)])
        #expect(secondValues == firstValues)
        #expect(try await fixture.calls().map(\.name) == ["getPlaybackRate"])
    }

    @Test("Cancelling one shared subscription keeps the initial getter alive for the remaining subscriber")
    func preservesGetterForRemainingSubscriber() async throws {
        let fixture = YouTubePlayerTestFixture(automaticallyReady: false)
        try await fixture.waitForPage()
        try await fixture.clearCalls()
        let publisher = fixture.player.playbackRatePublisher
        var firstValues: [YouTubePlayer.PlaybackRate] = []
        var secondValues: [YouTubePlayer.PlaybackRate] = []
        let firstSubscription = publisher.sink { firstValues.append($0) }
        let secondSubscription = publisher.sink { secondValues.append($0) }
        defer { secondSubscription.cancel() }
        await self.flushEvents()
        firstSubscription.cancel()
        try await fixture.emit(name: .ready)
        try await self.waitUntil { secondValues.count == 1 }
        #expect(firstValues.isEmpty)
        #expect(secondValues == [.normal])
        #expect(try await fixture.calls().map(\.name) == ["getPlaybackRate"])
    }

    @Test(
        "Async getter subscriptions support subscribing and cancelling from a background queue",
        arguments: ["duration", "metadata", "rate"]
    )
    func cancelsGetterFromBackgroundQueue(
        kind: String
    ) async throws {
        weak var releasedPlayer: YouTubePlayer?
        do {
            let fixture = YouTubePlayerTestFixture(automaticallyReady: false)
            try await fixture.waitForPage()
            releasedPlayer = fixture.player
            let queue = DispatchQueue(label: "YouTubePlayerPublisherTests.subscription")
            let publisher: AnyPublisher<Void, Never>
            switch kind {
            case "duration":
                publisher = fixture.player.durationPublisher.map { @Sendable _ in }.eraseToAnyPublisher()
            case "metadata":
                publisher = fixture.player.playbackMetadataPublisher.map { @Sendable _ in }.eraseToAnyPublisher()
            default:
                publisher = fixture.player.playbackRatePublisher.map { @Sendable _ in }.eraseToAnyPublisher()
            }
            let subscription = publisher
                .subscribe(on: queue)
                .receive(on: DispatchQueue.main)
                .sink { _ in Issue.record("An idle cancelled getter must not emit") }
            await self.flushEvents()
            await withCheckedContinuation { continuation in
                queue.async { continuation.resume() }
            }
            await self.flushEvents()
            subscription.cancel()
            await withCheckedContinuation { continuation in
                queue.async { continuation.resume() }
            }
            await self.flushEvents()
        }
        let deadline = Date().addingTimeInterval(3)
        while releasedPlayer != nil, Date() < deadline {
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        #expect(releasedPlayer == nil)
        releasedPlayer?.stateSubject.send(.ready)
    }

    @Test(
        "Async getters deliver values after subscribing from a background queue",
        arguments: ["duration", "metadata", "rate"]
    )
    func deliversGetterFromBackgroundSubscription(
        kind: String
    ) async throws {
        let fixture = YouTubePlayerTestFixture()
        try await fixture.waitUntilReady()
        let publisher: AnyPublisher<String, Never>
        let expectedValue: String
        switch kind {
        case "duration":
            publisher = fixture.player.durationPublisher.map { @Sendable in String($0.value) }.eraseToAnyPublisher()
            expectedValue = "120.0"
        case "metadata":
            publisher = fixture.player.playbackMetadataPublisher.map { @Sendable in $0.title ?? "" }.eraseToAnyPublisher()
            expectedValue = "Fixture"
        default:
            publisher = fixture.player.playbackRatePublisher.map { @Sendable in String($0.value) }.eraseToAnyPublisher()
            expectedValue = "1.0"
        }
        var values: [String] = []
        let subscription = publisher
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { values.append($0) }
        defer { subscription.cancel() }
        try await self.waitUntil { values.count == 1 }
        #expect(values == [expectedValue])
    }

    @Test("Duration and metadata publishers query initially and only refresh for their matching events")
    func refreshesAsyncPublisherValues() async throws {
        let fixture = YouTubePlayerTestFixture()
        try await fixture.waitUntilReady()
        try await fixture.clearCalls()
        var durations: [Measurement<UnitDuration>] = []
        var metadata: [YouTubePlayer.PlaybackMetadata] = []
        let durationSubscription = fixture.player.durationPublisher.sink { durations.append($0) }
        let metadataSubscription = fixture.player.playbackMetadataPublisher.sink { metadata.append($0) }
        defer {
            durationSubscription.cancel()
            metadataSubscription.cancel()
        }
        try await self.waitUntil { durations.count == 1 && metadata.count == 1 }
        #expect(durations.first == .init(value: 120, unit: .seconds))
        #expect(metadata.first?.videoId == "first")
        #expect(metadata.first?.title == "Fixture")
        try await fixture.setResult(240.5, for: "getDuration")
        try await fixture.setResult(["video_id": "second", "title": "Updated"], for: "getVideoData")
        try await fixture.emit(name: .stateChange, data: 1)
        try await fixture.emit(name: .apiChange)
        try await fixture.emit(name: .videoDataChange)
        try await self.waitUntil { durations.count == 2 && metadata.count == 2 }
        #expect(durations.last == .init(value: 240.5, unit: .seconds))
        #expect(metadata.last?.videoId == "second")
        #expect(metadata.last?.title == "Updated")
        let callNames = try await fixture.calls().map(\.name)
        #expect(callNames.filter { $0 == "getDuration" }.count == 2)
        #expect(callNames.filter { $0 == "getVideoData" }.count == 2)
    }

    @Test("Async publishers ignore getter failures and keep delivering later successful values")
    func recoversAfterAsyncGetterFailures() async throws {
        let fixture = YouTubePlayerTestFixture()
        try await fixture.waitUntilReady()
        try await fixture.setError("duration failure", for: "getDuration")
        try await fixture.setError("metadata failure", for: "getVideoData")
        try await fixture.setError("rate failure", for: "getPlaybackRate")
        try await fixture.clearCalls()
        var durations: [Measurement<UnitDuration>] = []
        var metadata: [YouTubePlayer.PlaybackMetadata] = []
        var rates: [YouTubePlayer.PlaybackRate] = []
        let subscriptions = [
            fixture.player.durationPublisher.sink { durations.append($0) },
            fixture.player.playbackMetadataPublisher.sink { metadata.append($0) },
            fixture.player.playbackRatePublisher.sink { rates.append($0) }
        ]
        defer { subscriptions.forEach { $0.cancel() } }
        try await self.waitUntil { try await fixture.calls().count == 3 }
        await self.flushEvents()
        #expect(durations.isEmpty && metadata.isEmpty && rates.isEmpty)
        try await fixture.setError(nil, for: "getDuration")
        try await fixture.setError(nil, for: "getVideoData")
        try await fixture.emit(name: .apiChange)
        try await fixture.emit(name: .videoDataChange)
        try await fixture.emit(name: .playbackRateChange, data: 1.5)
        try await self.waitUntil { durations.count == 1 && metadata.count == 1 && rates.count == 1 }
        #expect(durations.first?.value == 120)
        #expect(metadata.first?.title == "Fixture")
        #expect(rates == [.oneHalfFaster])
    }

    @Test(
        "Cancelling an idle async getter subscription releases its player",
        arguments: ["duration", "metadata", "rate"]
    )
    func cancelsPendingAsyncGetter(
        kind: String
    ) async throws {
        weak var releasedPlayer: YouTubePlayer?
        do {
            let fixture = YouTubePlayerTestFixture(automaticallyReady: false)
            try await fixture.waitForPage()
            releasedPlayer = fixture.player
            let publisher: AnyPublisher<Void, Never>
            switch kind {
            case "duration":
                publisher = fixture.player.durationPublisher.map { _ in }.eraseToAnyPublisher()
            case "metadata":
                publisher = fixture.player.playbackMetadataPublisher.map { _ in }.eraseToAnyPublisher()
            default:
                publisher = fixture.player.playbackRatePublisher.map { _ in }.eraseToAnyPublisher()
            }
            let subscription = publisher.sink { Issue.record("A cancelled idle getter must not emit") }
            await self.flushEvents()
            subscription.cancel()
            await self.flushEvents()
        }
        let deadline = Date().addingTimeInterval(3)
        while releasedPlayer != nil, Date() < deadline {
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        #expect(releasedPlayer == nil)
        releasedPlayer?.stateSubject.send(.ready)
    }

}

// MARK: - Fixtures

private extension YouTubePlayerWebKitTests.PublisherTests {

    /// Creates an idle player whose document never contacts the network.
    func makePlayer() -> YouTubePlayer {
        return .init(
            configuration: .init(
                htmlBuilder: .init(
                    htmlProvider: { _, _ in "<html></html>" }
                )
            )
        )
    }

    /// Sends a callback through the same subject used by the WebKit message bridge.
    func send(
        _ name: YouTubePlayer.Event.Name,
        data: String? = nil,
        to player: YouTubePlayer
    ) {
        player.webView.eventSubject.send(
            .receivedPlayerEvent(
                .init(
                    name: name,
                    data: data.map { .init(value: $0) }
                )
            )
        )
    }

    /// Drains the main-queue hops used by the event and state publishers.
    func flushEvents() async {
        for _ in 0..<3 {
            await withCheckedContinuation { continuation in
                DispatchQueue.main.async { continuation.resume() }
            }
        }
    }

    /// Waits for an observable publisher result with a bounded failure deadline.
    func waitUntil(
        _ condition: () async throws -> Bool
    ) async throws {
        let deadline = Date().addingTimeInterval(5)
        while Date() < deadline {
            if try await condition() {
                return
            }
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        try #require(Bool(false), "Expected publisher result did not arrive within five seconds")
    }

}
