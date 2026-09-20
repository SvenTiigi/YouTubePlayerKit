import Combine
import Foundation
import OSLog

// MARK: - Event Publisher

public extension YouTubePlayer {
    
    /// A Publisher that emits a received ``YouTubePlayer/Event``
    var eventPublisher: some Publisher<Event, Never> {
        self.webView
            .eventSubject
            .compactMap(\.playerEvent)
            .receive(on: DispatchQueue.main)
    }
    
}

// MARK: - Evaluate

public extension YouTubePlayer {
    
    /// Evaluates the JavaScript and converts its response.
    /// - Note: Cancellation is checked before dispatch. JavaScript already dispatched to WebKit may finish.
    /// - Parameters:
    ///   - javaScript: The JavaScript to evaluate.
    ///   - converter: The response converter.
    func evaluate<Response>(
        javaScript: JavaScript,
        converter: JavaScriptEvaluationResponseConverter<Response>
    ) async throws(APIError) -> Response {
        try await self.webView.evaluate(
            javaScript: javaScript,
            converter: converter
        )
    }
    
    /// Evaluates the JavaScript.
    /// - Parameter javaScript: The JavaScript to evaluate.
    func evaluate(
        javaScript: JavaScript
    ) async throws(APIError) {
        try await self.evaluate(
            javaScript: javaScript,
            converter: .void
        )
    }
    
}

// MARK: - Reload

public extension YouTubePlayer {
    
    /// Reloads the YouTube player.
    /// - Note: Once destruction is dispatched, the document is replaced even if the task is cancelled.
    /// - Throws: A setup, player, or cancellation error.
    func reload() async throws(Swift.Error) {
        try Task.checkCancellation()
        // An idle player may never become ready; reloading must not wait for the old document.
        if !self.state.isIdle {
            try? await self.evaluate(
                javaScript: .youTubePlayer(
                    functionName: "destroy"
                )
            )
        }
        // Once destruction is dispatched, replace the document even if cancellation arrives.
        // Send idle state
        self.stateSubject.send(.idle)
        // Reload
        try self.webView.load()
        try await self.waitUntilReady()
    }
    
}

// MARK: - Logger

public extension YouTubePlayer {
    
    /// Returns a new logger instance if logging is enabled via ``YouTubePlayer/isLoggingEnabled``
    func logger() -> Logger? {
        guard self.isLoggingEnabled else {
            return nil
        }
        return .init(
            subsystem: "YouTubePlayer",
            category: .init(describing: self.id)
        )
    }
    
}
