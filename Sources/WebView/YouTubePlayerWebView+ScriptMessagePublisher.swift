import Combine
import Foundation
import WebKit

// MARK: - YouTubePlayerWebView+ScriptMessagePublisher

extension YouTubePlayerWebView {

    /// A Combine-compatible publisher that bridges WKScriptMessage events
    /// from a WKWebView’s user content controller into a stream of values.
    final class ScriptMessagePublisher: NSObject {

        // MARK: Typealias

        /// The kind of values published by this publisher.
        typealias Output = WKScriptMessage

        /// The kind of errors this publisher might publish.
        typealias Failure = Never

        // MARK: Properties

        /// The passtrough subject.
        private lazy var subject = PassthroughSubject<Output, Failure>()

    }

}

// MARK: - Publisher

extension YouTubePlayerWebView.ScriptMessagePublisher: Publisher {

    /// Attaches the specified subscriber to this publisher.
    /// - Parameter subscriber: The subscriber to attach to this `Publisher`, after which it can receive values.
    func receive(
        subscriber: some Subscriber<Output, Failure>
    ) {
        self.subject.receive(subscriber: subscriber)
    }

}

// MARK: - WKScriptMessageHandler

extension YouTubePlayerWebView.ScriptMessagePublisher: WKScriptMessageHandler {

    /// Invoked when a script message is received from a webpage.
    /// - Parameters:
    ///   - userContentController: The user content controller invoking the delegate method.
    ///   - message: The received script message.
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        self.subject.send(message)
    }

}
