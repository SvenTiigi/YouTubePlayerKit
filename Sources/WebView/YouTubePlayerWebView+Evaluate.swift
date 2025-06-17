import Foundation

// MARK: - YouTubePlayerWebView+evaluate

extension YouTubePlayerWebView {
    
    /// Evaluates the given JavaScript and converts the result using the supplied converter.
    /// - Parameters:
    ///   - javaScript: The JavaScript that should be evaluated.
    ///   - converter: The JavaScript response converter.
    func evaluate<Response>(
        javaScript: YouTubePlayer.JavaScript,
        converter: YouTubePlayer.JavaScriptEvaluationResponseConverter<Response>
    ) async throws(YouTubePlayer.APIError) -> Response {
        // Verify YouTube player is available
        guard let player = self.player else {
            // Otherwise throw an error
            throw .init(
                reason: "YouTubePlayer deallocated"
            )
        }
        // Check if the player state is currently set to idle
        if player.state == .idle {
            // Wait for the player to be non idle
            for await state in player.stateSubject.values where !state.isIdle  {
                // Break out of for-loop as state is either ready or error
                break
            }
        }
        // Ignore return value if response is void
        let javaScript = Response.self is Void.Type ? javaScript.ignoreReturnValue() : javaScript
        // Initialize the JavaScript content
        let javaScriptContent = javaScript.content(
            variableNames: [
                .youTubePlayer: player.configuration.htmlBuilder.youTubePlayerJavaScriptVariableName
            ]
        )
        // Log JavaScript evaluation
        player
            .logger()?
            .debug(
                """
                Evaluate JavaScript: \(javaScriptContent, privacy: .public)
                """
            )
        // Declare JavaScript response
        let javaScriptResponse: Any?
        do {
            // Try to evaluate the JavaScript
            javaScriptResponse = try await self.evaluateJavaScriptAsync(javaScriptContent)
        } catch {
            // Initialize API error
            let apiError = YouTubePlayer.APIError(
                javaScript: javaScriptContent,
                javaScriptResponse: nil,
                underlyingError: error,
                reason: (error as NSError)
                    .userInfo["WKJavaScriptExceptionMessage"] as? String
            )
            // Log error
            player
                .logger()?
                .error(
                    """
                    Evaluated JavaScript: \(javaScriptContent, privacy: .public)
                    Error: \(apiError, privacy: .public)
                    """
                )
            // Throw error
            throw apiError
        }
        player
            .logger()?
            .debug(
                """
                Evaluated JavaScript: \(javaScriptContent, privacy: .public)
                Result-Type: \(javaScriptResponse.flatMap { String(describing: Mirror(reflecting: $0).subjectType) } ?? "nil", privacy: .public)
                Result: \(String(describing: javaScriptResponse ?? "nil"), privacy: .public)
                """
            )
        do {
            // Return converted response
            return try converter(
                javaScript: javaScriptContent,
                javaScriptResponse: javaScriptResponse
            )
        } catch {
            player
                .logger()?
                .error(
                    """
                    JavaScript response conversion failed
                    JavaScript: \(javaScriptContent, privacy: .public)
                    Result: \(String(describing: javaScriptResponse ?? "nil"), privacy: .public)
                    Error: \(error, privacy: .public)
                    """
                )
            throw error
        }
    }
    
}

// MARK: - YouTubePlayerWebView+evaluateJavaScriptAsync

private extension YouTubePlayerWebView {
    
    /// Evaluates the specified JavaScript string.
    /// - Parameter javaScriptString: The JavaScript string to evaluate.
    /// - Returns: The result of the script evaluation.
    /// - Note: This function utilizes the completion closure based `evaluateJavaScript` API since the native async version causes under some conditions a runtime crash.
    func evaluateJavaScriptAsync(
        _ javaScriptString: String
    ) async throws -> Any? {
        // Unchecked Sendable JavaScript response struct
        struct JavaScriptResponse: @unchecked Sendable {
            let value: Any?
        }
        // Try to retrieve JavaScript response
        let javaScriptResponse: JavaScriptResponse = try await withCheckedThrowingContinuation { continuation in
            // Initialize evaluate JavaScript closure
            let evaluateJavaScript = { [weak self] in
                self?.evaluateJavaScript(javaScriptString) { response, error in
                    continuation.resume(
                        with: {
                            if let error {
                                return .failure(error)
                            } else {
                                return .success(
                                    .init(
                                        value: response is NSNull ? nil : response
                                    )
                                )
                            }
                        }()
                    )
                }
            }
            // Check if is main thread
            if Thread.isMainThread {
                evaluateJavaScript()
            } else {
                // Dispatch on main queue
                DispatchQueue.main.async {
                    evaluateJavaScript()
                }
            }
        }
        // Return value
        return javaScriptResponse.value
    }
    
}
