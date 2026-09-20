import Combine
import Foundation
import Testing
import WebKit
@testable import YouTubePlayerKit

// MARK: - YouTubePlayerCallbackTests

/// Exercises the production HTML and WebKit bridge without contacting YouTube.
@MainActor
@Suite(.serialized, .timeLimit(.minutes(1)))
struct YouTubePlayerCallbackTests {}

// MARK: - Callback Delivery

extension YouTubePlayerCallbackTests {

    @Test("Delivers a burst of progress callbacks in order through the public publisher")
    func deliversOrderedProgressCallbacks() async throws {
        let fixture = CallbackFixture()
        try await fixture.waitForPage()
        try await fixture.initializeAPI()
        try await fixture.evaluate(
            """
            for (let index = 0; index < 1000; index++) {
                window.callbackTestPlayerOptions.events.onVideoProgress({data: index});
            }
            """
        )
        try await fixture.waitForEvents(count: 1000)
        #expect(fixture.events.count == 1000)
        #expect(fixture.events.allSatisfy { $0.name == .videoProgress })
        #expect(fixture.events.compactMap { $0.data?.value(as: Int.self) } == Array(0..<1000))
    }

    @Test("Preserves future event names and JavaScript payload semantics")
    func preservesGeneratedCallbackPayloads() async throws {
        let fixture = CallbackFixture()
        try await fixture.waitForPage()
        try await fixture.evaluate(
            """
            sendYouTubePlayerEvent('onFutureEvent');
            for (const data of [undefined, null, '', '  text \\n ', 'null', 0, -12.5, true, false, {value: '🌍'}, [1, null, 'two']]) {
                sendYouTubePlayerEvent('onFutureEvent', {data});
            }
            """
        )
        let expectedPayloads: [String?] = [
            nil, nil, nil, "", "  text \n ", "null", "0", "-12.5", "true", "false",
            #"{"value":"🌍"}"#, #"[1,null,"two"]"#
        ]
        try await fixture.waitForEvents(count: expectedPayloads.count)
        #expect(fixture.events.map(\.name.rawValue) == Array(repeating: "onFutureEvent", count: expectedPayloads.count))
        #expect(fixture.events.map { $0.data?.value } == expectedPayloads)
    }

    @Test("Normalizes native JSON message payloads without dropping future events")
    func preservesNativeMessagePayloads() async throws {
        let fixture = CallbackFixture()
        try await fixture.waitForPage()
        try await fixture.evaluate(
            """
            const handler = window.webkit.messageHandlers.youtubePlayerScriptMessageHandler;
            handler.postMessage({name: 'onFutureEvent'});
            for (const data of [null, '', ' text ', 'null', 0, 1, -12.5, true, false, {value: '🌍'}, [1, null, 'two']]) {
                handler.postMessage({name: 'onFutureEvent', data});
            }
            """
        )
        let expectedPayloads: [String?] = [
            nil, nil, "", " text ", "null", "0", "1", "-12.5", "true", "false",
            #"{"value":"🌍"}"#, #"[1,null,"two"]"#
        ]
        try await fixture.waitForEvents(count: expectedPayloads.count)
        #expect(fixture.events.map(\.name.rawValue) == Array(repeating: "onFutureEvent", count: expectedPayloads.count))
        #expect(fixture.events.map { $0.data?.value } == expectedPayloads)
    }

    @Test("Ignores malformed messages and continues delivering valid callbacks")
    func ignoresMalformedMessages() async throws {
        let fixture = CallbackFixture()
        try await fixture.waitForPage()
        try await fixture.evaluate(
            """
            const handler = window.webkit.messageHandlers.youtubePlayerScriptMessageHandler;
            for (const body of [null, 'invalid', 42, [], {}, {name: 1}, {data: 'missing name'}]) {
                handler.postMessage(body);
            }
            sendYouTubePlayerEvent('onFutureEvent', {data: 'complete'});
            """
        )
        try await fixture.waitForEvents(count: 1)
        #expect(fixture.events.count == 1)
        #expect(fixture.events.first?.name.rawValue == "onFutureEvent")
        #expect(fixture.events.first?.data?.value == "complete")
    }

    @Test("Updates typed playback state from a generated state callback")
    func updatesPlaybackState() async throws {
        let fixture = CallbackFixture()
        try await fixture.waitForPage()
        try await fixture.initializeAPI()
        try await fixture.evaluate("window.callbackTestPlayerOptions.events.onStateChange({data: 1});")
        try await fixture.waitForEvents(count: 1)
        #expect(fixture.events.first?.name == .stateChange)
        #expect(fixture.player.playbackState == .playing)
    }

    @Test("Subscribes to additional event names and honors exclusions in the actual player options")
    func subscribesToAdditionalEvents() async throws {
        let eventName = YouTubePlayer.Event.Name(rawValue: "onFuture'Event</script>🌍")
        let excludedEvents: Set<YouTubePlayer.Event.Name> = [.stateChange, .volumeChange]
        let fixture = CallbackFixture(
            additionalEventNames: [eventName, .stateChange],
            excludedEventNames: excludedEvents
        )
        try await fixture.waitForPage()
        try await fixture.initializeAPI()
        let eventNameJSON = String(
            decoding: try JSONEncoder().encode(eventName.rawValue),
            as: UTF8.self
        )
        try await fixture.evaluate(
            """
            const events = window.callbackTestPlayerOptions.events;
            events[\(eventNameJSON)]({data: Object.keys(events)});
            """
        )
        try await fixture.waitForEvents(count: 1)
        let event = try #require(fixture.events.first)
        let subscribedNames = try #require(event.data).jsonValue(as: [String].self)
        let expectedNames = Set(YouTubePlayer.Event.Name.allCases)
            .union([eventName])
            .subtracting(excludedEvents)
            .subtracting([.iFrameApiReady, .iFrameApiFailedToLoad])
        #expect(event.name == eventName)
        #expect(Set(subscribedNames) == Set(expectedNames.map(\.rawValue)))
    }

    @Test("Rejects child-frame callbacks while allowing main-frame callbacks")
    func rejectsChildFrameMessages() async throws {
        let fixture = CallbackFixture()
        try await fixture.waitForPage()
        try await fixture.evaluate(
            #"""
            window.addEventListener('message', event => {
                if (event.data === 'child-complete') {
                    sendYouTubePlayerEvent('onFutureEvent', {data: 'main-frame'});
                }
            }, {once: true});
            const frame = document.createElement('iframe');
            frame.srcdoc = '<script>window.webkit.messageHandlers.youtubePlayerScriptMessageHandler.postMessage({name:"onFutureEvent",data:"child-frame"}); parent.postMessage("child-complete", "*");</script>';
            document.body.appendChild(frame);
            """#
        )
        try await fixture.waitForEvents(count: 1)
        #expect(fixture.events.count == 1)
        #expect(fixture.events.first?.data?.value == "main-frame")
    }

    @Test("Delivers callbacks after replacing the document")
    func deliversCallbacksAfterReload() async throws {
        let fixture = CallbackFixture()
        try await fixture.waitForPage()
        try await fixture.evaluate(
            """
            window.callbackTestPreviousDocument = true;
            sendYouTubePlayerEvent('onFutureEvent', {data: 'before'});
            """
        )
        try await fixture.waitForEvents(count: 1)
        try fixture.player.webView.load()
        try await fixture.waitForPage(
            additionalCondition: "window.callbackTestPreviousDocument !== true"
        )
        try await fixture.evaluate("sendYouTubePlayerEvent('onFutureEvent', {data: 'after'});")
        try await fixture.waitForEvents(count: 2)
        #expect(fixture.events.map { $0.data?.value } == ["before", "after"])
    }

    @Test(
        "Escapes custom handler names in callbacks and the script-error attribute",
        arguments: [
            "player's-handler",
            #"handler"with"quotes"#,
            #"handler\with\backslashes"#,
            "</script><script>throw new Error('injected')</script>&quot;",
            "播放器🌍\u{2028}\u{2029}"
        ]
    )
    func escapesHandlerNames(
        handlerName: String
    ) async throws {
        let fixture = CallbackFixture(handlerName: handlerName)
        try await fixture.waitForPage()
        try await fixture.evaluate("sendYouTubePlayerEvent('onFutureEvent', {data: 'delivered'});")
        try await fixture.waitForEvents(count: 1)
        #expect(fixture.events.first?.data?.value == "delivered")
        try await fixture.evaluate("document.querySelector('script[src]').dispatchEvent(new Event('error'));")
        try await fixture.waitForEvents(count: 2)
        #expect(fixture.events.last?.name == .iFrameApiFailedToLoad)
        #expect(fixture.events.last?.data == nil)
    }

    @Test("Rejects an empty handler name without crashing WebKit registration")
    func rejectsEmptyHandlerName() throws {
        let fixture = CallbackFixture(handlerName: "")
        #expect(throws: YouTubePlayer.APIError.self) {
            try fixture.player.webView.load()
        }
        guard case .error(.setupFailed) = fixture.player.state else {
            Issue.record("An invalid handler name must leave the player in the setup-failed state")
            return
        }
        #expect(fixture.events.isEmpty)
    }

    @Test("Keeps a custom player variable separate from local initialization options")
    func initializesPlayerNamedPlayerOptions() async throws {
        let fixture = CallbackFixture(variableName: "playerOptions")
        try await fixture.waitForPage()
        try await fixture.initializeAPI()
        try await fixture.evaluate(
            """
            sendYouTubePlayerEvent('onFutureEvent', {
                data: typeof window.playerOptions.setSize === 'function'
            });
            """
        )
        try await fixture.waitForEvents(count: 1)
        #expect(fixture.events.first?.data?.value(as: Bool.self) == true)
    }

    @Test("Propagates a custom HTML provider failure through loading and player state")
    func propagatesHTMLProviderFailure() throws {
        let expectedError = YouTubePlayer.APIError(reason: "Custom HTML generation failed")
        let player = YouTubePlayer(
            configuration: .init(
                htmlBuilder: .init(
                    htmlProvider: { _, _ in
                        throw expectedError
                    }
                )
            )
        )
        let thrownError = #expect(throws: YouTubePlayer.APIError.self) {
            try player.webView.load()
        }
        #expect(thrownError?.reason == expectedError.reason)
        guard case .error(.setupFailed(let error)) = player.state else {
            Issue.record("A custom HTML provider failure must leave the player in the setup-failed state")
            return
        }
        #expect((error as? YouTubePlayer.APIError)?.reason == expectedError.reason)
    }

    @Test("Releases the player and WebKit view after receiving callbacks")
    func releasesPlayerAndWebView() async throws {
        weak var releasedPlayer: YouTubePlayer?
        weak var releasedWebView: WKWebView?
        do {
            let fixture = CallbackFixture()
            releasedPlayer = fixture.player
            releasedWebView = fixture.player.webView
            try await fixture.waitForPage()
            try await fixture.evaluate("sendYouTubePlayerEvent('onFutureEvent');")
            try await fixture.waitForEvents(count: 1)
        }
        let deadline = Date().addingTimeInterval(10)
        while (releasedPlayer != nil || releasedWebView != nil), Date() < deadline {
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        #expect(releasedPlayer == nil)
        #expect(releasedWebView == nil)
    }

}

// MARK: - CallbackFixture

/// Owns a real WebKit bridge and collects its public events using a local inert API script.
@MainActor
private final class CallbackFixture {

    // MARK: Properties

    /// The player using the default HTML provider.
    let player: YouTubePlayer

    /// Events delivered through the public publisher.
    private(set) var events: [YouTubePlayer.Event] = .init()

    /// Keeps event observation alive for the fixture's lifetime.
    private var subscription: AnyCancellable?

    // MARK: Initializer

    /// Creates a fixture with the specified WebKit handler name.
    /// - Parameters:
    ///   - variableName: The global JavaScript name holding the player instance.
    ///   - handlerName: The name registered in WebKit and embedded in the HTML.
    ///   - additionalEventNames: Future event names registered with the IFrame API.
    ///   - excludedEventNames: Events omitted from the IFrame API subscriptions.
    init(
        variableName: String = "youtubePlayer",
        handlerName: String = "youtubePlayerScriptMessageHandler",
        additionalEventNames: Set<YouTubePlayer.Event.Name> = .init(),
        excludedEventNames: Set<YouTubePlayer.Event.Name> = .init()
    ) {
        self.player = YouTubePlayer(
            configuration: .init(
                useNonPersistentWebsiteDataStore: true,
                htmlBuilder: .init(
                    youTubePlayerJavaScriptVariableName: variableName,
                    youTubePlayerScriptMessageHandlerName: handlerName,
                    additionalEventNames: additionalEventNames,
                    htmlProvider: { builder, options in
                        try YouTubePlayer.HTMLBuilder.defaultHTMLProvider(
                            excludedEventNames: excludedEventNames
                        )(builder, options)
                            .replacingOccurrences(
                                of: builder.youTubePlayerIframeAPISourceURL.absoluteString,
                                with: "data:text/javascript,void(0)"
                            )
                    }
                )
            )
        )
        self.subscription = self.player.eventPublisher.sink { [weak self] event in
            self?.events.append(event)
        }
    }

}

// MARK: - Fixture Operations

private extension CallbackFixture {

    /// Initializes a local API stand-in and records the options passed to the player constructor.
    func initializeAPI() async throws {
        try await self.evaluate(
            """
            window.YT = {
                Player: function(element, options) {
                    window.callbackTestPlayerOptions = options;
                    this.setSize = function() {};
                }
            };
            onYouTubeIframeAPIReady();
            """
        )
        try await self.waitForEvents(count: 1)
        try #require(self.events.last?.name == .iFrameApiReady)
        self.events.removeAll()
    }

    /// Waits for the generated page to finish loading and optionally identify a new document.
    /// - Parameter additionalCondition: A JavaScript expression that must also evaluate to true.
    func waitForPage(
        additionalCondition: String = "true"
    ) async throws {
        let deadline = Date().addingTimeInterval(10)
        while Date() < deadline {
            let isReady = try? await self.evaluateCondition(
                "document.readyState === 'complete' && typeof sendYouTubePlayerEvent === 'function' && (\(additionalCondition))"
            )
            if isReady == true {
                return
            }
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        try #require(Bool(false), "The local callback page did not become ready within ten seconds")
    }

    /// Waits for a known event or completion sentinel, with a bounded timeout.
    /// - Parameter count: The minimum expected event count.
    func waitForEvents(
        count: Int
    ) async throws {
        let deadline = Date().addingTimeInterval(10)
        while self.events.count < count, Date() < deadline {
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        try #require(self.events.count >= count, "Timed out waiting for callback delivery")
    }

    /// Evaluates JavaScript while discarding its return value.
    /// - Parameter script: The JavaScript to execute in the main frame.
    func evaluate(
        _ script: String
    ) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            self.player.webView.evaluateJavaScript(script + "\nvoid 0;") { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    /// Evaluates a Boolean JavaScript condition without transferring untyped values across actors.
    /// - Parameter condition: The JavaScript Boolean expression.
    private func evaluateCondition(
        _ condition: String
    ) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            self.player.webView.evaluateJavaScript(condition) { value, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: value as? Bool ?? false)
                }
            }
        }
    }

}
