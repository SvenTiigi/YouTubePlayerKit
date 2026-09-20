import Foundation
import WebKit

// MARK: - WebKitTestSupport

/// Bounds local WebKit startup and JavaScript evaluation on slower simulators.
@MainActor
enum WebKitTestSupport {

    /// A WebKit completion delivered on the main actor.
    typealias JavaScriptCompletion = @MainActor (Any?, (any Error)?) -> Void

    /// Allows cold WebKit processes to start before asserting player behavior.
    static let pageLoadTimeout: TimeInterval = 90

}

// MARK: - Offscreen Execution

extension WebKitTestSupport {

    /// Keeps JavaScript and callbacks running in fixtures that are not attached to a window.
    /// - Parameter webView: The web view used by a local test fixture.
    static func prepareForOffscreenUse(
        _ webView: WKWebView
    ) {
        // WebKit may suspend detached views immediately when linking against newer SDKs.
        // https://bugs.webkit.org/show_bug.cgi?id=283794#c4
        if #available(iOS 17.0, macOS 14.0, visionOS 1.0, *) {
            webView.configuration.preferences.inactiveSchedulingPolicy = .none
        }
    }

}

// MARK: - JavaScript Evaluation

extension WebKitTestSupport {

    /// Evaluates a JSON-producing script without waiting indefinitely for WebKit.
    /// - Parameters:
    ///   - script: JavaScript that returns a JSON string.
    ///   - webView: The web view containing the local fixture.
    ///   - timeout: The maximum time to wait for the completion callback.
    /// - Returns: The JSON string returned by JavaScript.
    static func evaluateJSON(
        _ script: String,
        in webView: WKWebView,
        timeout: TimeInterval = 15
    ) async throws -> String {
        return try await self.evaluateJSON(script, timeout: timeout) { completion in
            webView.evaluateJavaScript(script, completionHandler: completion)
        }
    }

    /// Bridges a JavaScript callback into a bounded wait, including late completions.
    /// - Parameters:
    ///   - script: The script included in failure diagnostics.
    ///   - timeout: The maximum time to wait for the completion callback.
    ///   - evaluate: Starts evaluation and eventually invokes its completion.
    /// - Returns: The JSON string returned by evaluation.
    static func evaluateJSON(
        _ script: String,
        timeout: TimeInterval,
        evaluate: (_ completion: @escaping JavaScriptCompletion) -> Void
    ) async throws -> String {
        try Task.checkCancellation()
        return try await withCheckedThrowingContinuation { continuation in
            var pending: CheckedContinuation<String, any Error>? = continuation
            let timeoutTask = Task { @MainActor in
                do {
                    try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                } catch {
                    return
                }
                let continuation = pending
                pending = nil
                continuation?.resume(
                    throwing: NSError(
                        domain: "WebKitTestSupport",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "JavaScript evaluation timed out after \(timeout) seconds: \(script)"]
                    )
                )
            }
            evaluate { value, error in
                guard let continuation = pending else {
                    return
                }
                pending = nil
                timeoutTask.cancel()
                if let error {
                    continuation.resume(throwing: error)
                } else if let value = value as? String {
                    continuation.resume(returning: value)
                } else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "WebKitTestSupport",
                            code: 2,
                            userInfo: [NSLocalizedDescriptionKey: "JavaScript did not return a JSON string: \(script)"]
                        )
                    )
                }
            }
        }
    }

}
