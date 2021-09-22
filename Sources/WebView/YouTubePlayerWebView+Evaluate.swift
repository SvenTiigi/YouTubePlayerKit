import Foundation

// MARK: - YouTubePlayerWebView+evaluate

extension YouTubePlayerWebView {
    
    /// Evaluates the given JavaScript
    /// - Parameters:
    ///   - javaScript: The JavaScript string
    ///   - completion: The optional completion closure
    func evaluate(
        javaScript: String,
        completion: ((Result<Any?, YouTubePlayerAPIError>, String) -> Void)? = nil
    ) {
        self.evaluateJavaScript(
            javaScript
        ) { result, error in
            completion?(
                error
                    .flatMap { error in
                        .failure(
                            .init(
                                javaScript: javaScript,
                                underlyingError: error,
                                reason: (error as NSError)
                                    .userInfo["WKJavaScriptExceptionMessage"] as? String
                            )
                        )
                    }
                    ?? .success(result),
                javaScript
            )
        }
    }
    
    /// Evaluates the given JavaScript and tries to convert the response value to given `Response` type
    /// - Parameters:
    ///   - javaScript: The JavaScript string
    ///   - responseType: The Response type
    ///   - completion: The completion closure which takes in the Result and the executed JavaScript
    func evaluate<Response>(
        javaScript: String,
        responseType: Response.Type,
        completion: @escaping (Result<Response, YouTubePlayerAPIError>, String) -> Void
    ) {
        self.evaluate(
            javaScript: javaScript
        ) { result, javaScript in
            switch result {
            case .success(let responseValue):
                // Verify response value can be casted to the Response type
                guard let response = responseValue as? Response else {
                    // Otherwise complete with failure
                    return completion(
                        .failure(
                            .init(
                                javaScript: javaScript,
                                javaScriptResponse: responseValue,
                                reason: [
                                    "Malformed response",
                                    "Expected a type of: \(String(describing: Response.self))"
                                ]
                                .joined(separator: ". ")
                            )
                        ),
                        javaScript
                    )
                }
                // Complete with success
                completion(.success(response), javaScript)
            case .failure(let error):
                // Complete with failure
                completion(.failure(error), javaScript)
            }
        }
    }
    
    /// Evaluates the given JavaScript and tries to convert the response value to given `Response` type
    /// - Parameters:
    ///   - javaScript: The JavaScript string
    ///   - responseType: The Response type. Default value `.self`
    ///   - completion: The completion closure which takes in the Result
    func evaluate<Response>(
        javaScript: String,
        responseType: Response.Type = Response.self,
        completion: @escaping (Result<Response, YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: javaScript,
            responseType: Response.self
        ) { result, _ in
            completion(result)
        }
    }
    
}
