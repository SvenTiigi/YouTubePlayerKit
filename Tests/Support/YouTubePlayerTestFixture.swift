import Foundation
import Testing
@testable import YouTubePlayerKit

// MARK: - YouTubePlayerTestFixture

/// Runs the production HTML and WebKit bridge with a local, configurable IFrame API stand-in.
@MainActor
final class YouTubePlayerTestFixture {

    // MARK: Properties

    /// The player under test.
    let player: YouTubePlayer

    // MARK: Initializer

    /// Creates a network-independent player that records JavaScript API calls.
    /// - Parameters:
    ///   - source: The initial player source.
    ///   - automaticallyReady: Whether each document emits the ready callback automatically.
    ///   - openURLAction: The action used when navigation requests an external URL.
    init(
        source: YouTubePlayer.Source? = nil,
        automaticallyReady: Bool = true,
        openURLAction: YouTubePlayer.OpenURLAction = .default
    ) {
        self.player = YouTubePlayer(
            source: source,
            configuration: .init(
                useNonPersistentWebsiteDataStore: true,
                htmlBuilder: .init(
                    htmlProvider: { builder, options in
                        let html = try YouTubePlayer.HTMLBuilder.defaultHTMLProvider()(builder, options)
                            .replacingOccurrences(
                                of: builder.youTubePlayerIframeAPISourceURL.absoluteString,
                                with: "data:text/javascript,void(0)"
                            )
                        let fixtureScript = """
                        <script>
                            window.testPlayerCalls = [];
                            window.testPlayerErrors = {};
                            window.testPlayerResults = {
                                getDuration: 120,
                                getCurrentTime: 30,
                                getPlayerState: 2,
                                getPlaybackRate: 1,
                                getAvailablePlaybackRates: [0.5, 1, 1.5, 2],
                                getVideoLoadedFraction: 0.75,
                                getVolume: 50,
                                isMuted: false,
                                getOptions: ['captions'],
                                getPlaylist: ['first', 'second'],
                                getPlaylistIndex: 0,
                                getPlaylistId: 'playlist',
                                getVideoUrl: 'https://www.youtube.com/watch?v=first',
                                getVideoData: {video_id: 'first', title: 'Fixture', author: 'Author'}
                            };
                            window.YT = {
                                Player: function(element, options) {
                                    window.testPlayerOptions = options;
                                    const instance = new Proxy({}, {
                                        get: function(target, name) {
                                            if (name === 'playerInfo') {
                                                return window.testPlayerResults.playerInfo;
                                            }
                                            return function(...args) {
                                                window.testPlayerCalls.push({name, arguments: args});
                                                if (Object.prototype.hasOwnProperty.call(window.testPlayerErrors, name)) {
                                                    throw new Error(window.testPlayerErrors[name]);
                                                }
                                                return window.testPlayerResults[name];
                                            };
                                        }
                                    });
                                    if (\(automaticallyReady)) {
                                        setTimeout(() => options.events.onReady({target: instance}), 0);
                                    }
                                    return instance;
                                }
                            };
                            onYouTubeIframeAPIReady();
                            window.testPlayerInstalled = true;
                        </script>
                        """
                        return html.replacingOccurrences(
                            of: "</body>",
                            with: fixtureScript + "</body>"
                        )
                    }
                ),
                openURLAction: openURLAction
            )
        )
        _ = self.player.webView
    }

}

// MARK: - Recorded Values

extension YouTubePlayerTestFixture {

    /// A function invoked through the public player API.
    struct Call: Decodable, Equatable, Sendable {

        /// The IFrame API function name.
        let name: String

        /// The JSON arguments passed to the function.
        let arguments: [JSONValue]

    }

    /// A JSON value recorded at the JavaScript boundary.
    enum JSONValue: Codable, Equatable, Sendable {
        case null
        case bool(Bool)
        case number(Double)
        case string(String)
        case array([Self])
        case object([String: Self])

        /// Decodes a JSON value without losing Boolean or numeric types.
        /// - Parameter decoder: The JSON decoder.
        init(
            from decoder: any Decoder
        ) throws {
            let container = try decoder.singleValueContainer()
            if container.decodeNil() {
                self = .null
            } else if let value = try? container.decode(Bool.self) {
                self = .bool(value)
            } else if let value = try? container.decode(Double.self) {
                self = .number(value)
            } else if let value = try? container.decode(String.self) {
                self = .string(value)
            } else if let value = try? container.decode([Self].self) {
                self = .array(value)
            } else {
                self = .object(try container.decode([String: Self].self))
            }
        }

        /// Encodes a JSON value for injection into the local API stand-in.
        /// - Parameter encoder: The JSON encoder.
        func encode(
            to encoder: any Encoder
        ) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .null:
                try container.encodeNil()
            case .bool(let value):
                try container.encode(value)
            case .number(let value):
                try container.encode(value)
            case .string(let value):
                try container.encode(value)
            case .array(let value):
                try container.encode(value)
            case .object(let value):
                try container.encode(value)
            }
        }

    }

}

// MARK: - Page Lifecycle

extension YouTubePlayerTestFixture {

    /// Waits for the local page independently of the player's ready state.
    func waitForPage() async throws {
        let deadline = Date().addingTimeInterval(10)
        while Date() < deadline {
            if (try? await self.value(for: "window.testPlayerInstalled === true", as: Bool.self)) == true {
                return
            }
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        try #require(Bool(false), "The local IFrame API page did not load within ten seconds")
    }

    /// Waits for the real bridge to transition the player into its ready state.
    func waitUntilReady() async throws {
        let deadline = Date().addingTimeInterval(10)
        while self.player.state.isIdle, Date() < deadline {
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        try #require(self.player.state == .ready, "The local player did not become ready: \(self.player.state)")
    }

}

// MARK: - JavaScript Operations

extension YouTubePlayerTestFixture {

    /// Executes raw JavaScript without waiting for the player's ready state.
    /// - Parameter script: The JavaScript statements to execute.
    func evaluate(
        _ script: String
    ) async throws {
        _ = try await self.evaluateJSON(script + "\n; JSON.stringify(null);")
    }

    /// Decodes the JSON representation of a JavaScript expression.
    /// - Parameters:
    ///   - script: The JavaScript expression to evaluate.
    ///   - type: The expected decoded type.
    func value<Value: Decodable>(
        for script: String,
        as type: Value.Type
    ) async throws -> Value {
        let json = try await self.evaluateJSON("JSON.stringify((\(script)))")
        return try JSONDecoder().decode(type, from: Data(json.utf8))
    }

    /// Returns recorded API invocations in delivery order.
    func calls() async throws -> [Call] {
        return try await self.value(for: "window.testPlayerCalls", as: [Call].self)
    }

    /// Clears initialization and previously asserted calls from the recorder.
    func clearCalls() async throws {
        try await self.evaluate("window.testPlayerCalls = [];")
    }

    /// Configures the JSON result of a JavaScript function or playerInfo property.
    /// - Parameters:
    ///   - value: The JSON value returned by the function.
    ///   - function: The IFrame API function name or playerInfo property.
    func setResult(
        _ value: some Encodable,
        for function: String
    ) async throws {
        try await self.evaluate(
            "window.testPlayerResults[\(try self.json(function))] = \(try self.json(value));"
        )
    }

    /// Configures or clears an exception thrown by a JavaScript function.
    /// - Parameters:
    ///   - message: The exception message, or nil to restore successful execution.
    ///   - function: The IFrame API function name.
    func setError(
        _ message: String?,
        for function: String
    ) async throws {
        let key = try self.json(function)
        if let message {
            try await self.evaluate("window.testPlayerErrors[\(key)] = \(try self.json(message));")
        } else {
            try await self.evaluate("delete window.testPlayerErrors[\(key)];")
        }
    }

    /// Emits an event through the production JavaScript callback function.
    /// - Parameters:
    ///   - name: The event name.
    ///   - data: The event's JSON payload.
    func emit(
        name: YouTubePlayer.Event.Name,
        data: some Encodable
    ) async throws {
        try await self.evaluate(
            "sendYouTubePlayerEvent(\(try self.json(name.rawValue)), {data: \(try self.json(data))});"
        )
    }

    /// Emits a callback with no payload through the production bridge.
    /// - Parameter name: The event name.
    func emit(
        name: YouTubePlayer.Event.Name
    ) async throws {
        try await self.evaluate("sendYouTubePlayerEvent(\(try self.json(name.rawValue)));")
    }

}

// MARK: - Encoding and Evaluation

private extension YouTubePlayerTestFixture {

    /// Encodes values safely for insertion into executable JavaScript.
    /// - Parameter value: The value to encode.
    func json(
        _ value: some Encodable
    ) throws -> String {
        return String(decoding: try JSONEncoder().encode(value), as: UTF8.self)
    }

    /// Uses WebKit's completion API while transferring only a Sendable string result.
    /// - Parameter script: JavaScript that returns a JSON string.
    func evaluateJSON(
        _ script: String
    ) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            self.player.webView.evaluateJavaScript(script) { value, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let value = value as? String {
                    continuation.resume(returning: value)
                } else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "YouTubePlayerTestFixture",
                            code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "JavaScript did not return a JSON string"]
                        )
                    )
                }
            }
        }
    }

}
