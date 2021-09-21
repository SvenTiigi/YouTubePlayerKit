import Combine
import Foundation
import WebKit

// MARK: - YouTubePlayerWebView

/// The YouTubePlayer WebView
final class YouTubePlayerWebView: WKWebView {
    
    // MARK: Properties
    
    /// The YouTubePlayer
    let player: YouTubePlayer
    
    /// The updated YouTubePlayer Source which has
    /// been set by the `load(source:)` API
    var updatedSource: YouTubePlayer.Source?
    
    /// The origin URL
    private(set) lazy var originURL: URL? = Bundle
        .main
        .bundleIdentifier
        .flatMap { ["https://", $0.lowercased()].joined() }
        .flatMap(URL.init)
    
    // MARK: Subjects
    
    /// The YouTubePlayer State CurrentValueSubject
    private(set) lazy var stateSubject = CurrentValueSubject<YouTubePlayer.State?, Never>(nil)
    
    /// The YouTubePlayer VideoState CurrentValueSubject
    private(set) lazy var videoStateSubject = CurrentValueSubject<YouTubePlayer.VideoState?, Never>(nil)
    
    /// The YouTubePlayer PlaybackQuality CurrentValueSubject
    private(set) lazy var playbackQualitySubject = CurrentValueSubject<YouTubePlayer.PlaybackQuality?, Never>(nil)
    
    /// The YouTubePlayer PlaybackRate CurrentValueSubject
    private(set) lazy var playbackRateSubject = CurrentValueSubject<YouTubePlayer.PlaybackRate?, Never>(nil)
    
    // MARK: Initializer
    
    /// Creates a new instance of `YouTubePlayer.WebView`
    /// - Parameter player: The YouTubePlayer
    init(
        player: YouTubePlayer
    ) {
        // Set player
        self.player = player
        // Super init
        super.init(
            frame: .zero,
            configuration: {
                // Initialize WebView Configuration
                let configuration = WKWebViewConfiguration()
                // Allows inline media playback
                configuration.allowsInlineMediaPlayback = true
                // No media types requiring user action for playback
                configuration.mediaTypesRequiringUserActionForPlayback = []
                // Return configuration
                return configuration
            }()
        )
        // Set clear background color
        self.backgroundColor = .clear
        // Disable opaque
        self.isOpaque = false
        // Set autoresizing masks
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // Disable scrolling
        self.scrollView.isScrollEnabled = false
        // Disable bounces of ScrollView
        self.scrollView.bounces = false
        // Set navigation delegate
        self.navigationDelegate = self
        // Set ui delegate
        self.uiDelegate = self
        // Load Player and retain result
        let isPlayerLoaded = self.loadPlayer()
        // Check if Player is not loaded
        if !isPlayerLoaded {
            // Send setup failed error
            self.stateSubject.send(.error(.setupFailed))
        }
    }
    
    /// Initializer with NSCoder always returns nil
    required init?(coder: NSCoder) {
        nil
    }
    
    /// Deinit
    deinit {
        // Destroy Player
        self.destroyPlayer()
    }
    
}

// MARK: - YouTubePlayerWebView+loadPlayer

extension YouTubePlayerWebView {
    
    /// Load Player
    /// - Returns: A Bool value if the YouTube player was successfully loaded
    @discardableResult
    func loadPlayer() -> Bool {
        // Set YouTubePlayerAPI on current Player
        self.player.api = self
        // Update user interaction enabled state.
        // If no configuration is provided `true` value will be used
        self.isUserInteractionEnabled = self.player.configuration.isUserInteractionEnabled ?? true
        // Try to initialize YouTubePlayer Options
        guard let youTubePlayerOptions = try? YouTubePlayer.Options(
            player: self.player,
            originURL: self.originURL
        ) else {
            // Otherwise return failure
            return false
        }
        // Verify YouTube Player HTML is available
        guard let youTubePlayerHTML = YouTubePlayer.HTML(
            options: youTubePlayerOptions
        ) else {
            // Otherwise return failure
            return false
        }
        // Load HTML string
        self.loadHTMLString(
            youTubePlayerHTML.contents,
            baseURL: self.originURL
        )
        // Return success
        return true
    }
    
}

// MARK: - YouTubePlayerWebView+destroyPlayer

extension YouTubePlayerWebView {
    
    /// Destroy Player
    /// - Parameter completion: The optional completion closure. Default value `nil`
    func destroyPlayer(
        completion: (() -> Void)? = nil
    ) {
        // Stop Player
        self.stop()
        // Destroy Player
        self.evaluate(
            javaScript: "player.destroy();"
        ) { [weak self] _, _ in
            // Reset all CurrentValueSubjects
            self?.stateSubject.send(nil)
            self?.videoStateSubject.send(nil)
            self?.playbackQualitySubject.send(nil)
            self?.playbackRateSubject.send(nil)
            // Invoke completion if available
            completion?()
        }
    }
    
}

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
                                underlyingError: error
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
    ///   - completion: The completion closure
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
    
}
