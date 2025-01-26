import Combine
import Foundation
import WebKit

// MARK: - YouTubePlayerWebView

/// A YouTube player web view.
final class YouTubePlayerWebView: WKWebView {
    
    // MARK: Properties
    
    /// The YouTubePlayer
    private(set) weak var player: YouTubePlayer?
    
    /// The origin URL
    private let originURL = URL(string: "https://youtubeplayer")
    
    /// The YouTubePlayerWebView Event PassthroughSubject
    private(set) lazy var eventSubject = PassthroughSubject<Event, Never>()
    
    /// The Layout Lifecycle Subject
    private lazy var layoutLifecycleSubject = PassthroughSubject<CGRect, Never>()
    
    /// The cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Initializer
    
    /// Creates a new instance of ``YouTubePlayer.WebView``
    /// - Parameter player: The YouTube player
    init(
        player: YouTubePlayer
    ) {
        self.player = player
        super.init(
            frame: .zero,
            configuration: {
                let configuration = WKWebViewConfiguration()
                // Do not persist cookies and website data storage to disk
                configuration.websiteDataStore = player.configuration.useNonPersistentWebsiteDataStore
                    ? .nonPersistent()
                    : .default()
                #if !os(macOS)
                // Set allows inline media playback
                configuration.allowsInlineMediaPlayback = player.configuration.allowsInlineMediaPlayback
                // Set allows picture in picture media playback
                configuration.allowsPictureInPictureMediaPlayback = player.configuration.allowsPictureInPictureMediaPlayback
                #endif
                // No media types requiring user action for playback
                configuration.mediaTypesRequiringUserActionForPlayback = .init()
                // Disable text interaction / selection
                configuration.preferences.isTextInteractionEnabled = false
                // Set HTML element fullscreen enabled if fullscreen mode is set to web
                let isElementFullscreenEnabled = player.configuration.fullscreenMode == .web
                if #available(iOS 15.4, macOS 12.3, visionOS 1.0, *) {
                    configuration.preferences.isElementFullscreenEnabled = isElementFullscreenEnabled
                } else {
                    configuration.preferences.setValue(isElementFullscreenEnabled, forKey: "fullScreenEnabled")
                }
                return configuration
            }()
        )
        // Setup
        self.setup(using: player)
        // Load
        self.load()
    }
    
    /// Initializer with NSCoder is unavailable.
    /// Use `init(player:)`
    @available(*, unavailable)
    required init?(
        coder aDecoder: NSCoder
    ) { nil }
    
    // MARK: View-Lifecycle
    
    #if os(macOS)
    /// Perform layout
    override func layout() {
        super.layout()
        // Send frame on Layout Subject
        self.layoutLifecycleSubject.send(self.frame)
    }
    #else
    /// Layout Subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        // Send frame on Layout Subject
        self.layoutLifecycleSubject.send(self.frame)
    }
    #endif
    
    #if os(macOS)
    /// ScrollWheel Event
    /// - Parameter event: The NSEvent
    override func scrollWheel(with event: NSEvent) {
        // Explicity overriden without super invocation
        // to disable scrolling on macOS
        self.nextResponder?.scrollWheel(with: event)
    }
    #endif
    
    /// Sets a Boolean that indicates whether the scroll view automatically adjusts its content insets.
    /// - Parameter enabled: A Boolean if enabled.
    func setAutomaticallyAdjustsContentInsets(enabled: Bool) {
        #if os(macOS)
        self.enclosingScrollView?.automaticallyAdjustsContentInsets = enabled
        #else
        self.scrollView.contentInsetAdjustmentBehavior = enabled ? .automatic : .never
        #endif
    }
    
}

// MARK: - Setup

private extension YouTubePlayerWebView {
    
    /// Setups the web view.
    func setup(
        using player: YouTubePlayer
    ) {
        // Setup frame observation
        self.publisher(
            for: \.frame,
            options: [.new]
        )
        .dropFirst()
        .merge(
            with: self.layoutLifecycleSubject
        )
        .removeDuplicates()
        .sink { frame in
            // Verify size is not equal to zero
            guard frame.size != .zero else {
                // Otherwise return out of function
                return
            }
            // Set player size
            Task(priority: .userInitiated) { [weak self] in
                try? await self?.evaluate(
                    javaScript: .player(
                        function: "setSize",
                        parameters: [
                            Double(frame.size.width),
                            Double(frame.size.height)
                        ]
                    )
                )
            }
        }
        .store(in: &self.cancellables)
        // Set navigation delegate
        self.navigationDelegate = self
        // Set ui delegate
        self.uiDelegate = self
        // Disable link preview
        self.allowsLinkPreview = false
        // Disable gesture navigation
        self.allowsBackForwardNavigationGestures = false
        // Clear under page background color
        self.underPageBackgroundColor = .clear
        #if !os(macOS)
        // Set clear background color
        self.backgroundColor = .clear
        // Disable opaque
        self.isOpaque = false
        // Disable scrolling
        self.scrollView.isScrollEnabled = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        // Disable bounces of ScrollView
        self.scrollView.bounces = false
        #endif
        // Initially set if content insets should be automatically adjusted
        self.setAutomaticallyAdjustsContentInsets(enabled: player.configuration.automaticallyAdjustsContentInsets)
        // Initially set custom user agent
        self.customUserAgent = player.configuration.customUserAgent
    }
    
}

// MARK: - Load

extension YouTubePlayerWebView {
    
    /// Loads the YouTube player.
    @discardableResult
    func load() -> Bool {
        // Verify player is available
        guard let player = self.player else {
            // Otherwise return false
            return false
        }
        // Declare HTML
        let html: HTML
        do {
            // Try to initialize HTML
            html = try .init(
                source: player.source,
                parameters: player.parameters,
                originURL: self.originURL,
                allowsInlineMediaPlayback: player.configuration.allowsInlineMediaPlayback
            )
        } catch {
            // Send error state
            player.stateSubject.send(
                .error(
                    .setupFailed(error)
                )
            )
            return false
        }
        YouTubePlayer
            .Logger
            .category(self.player)?
            .debug(
                """
                Loading YouTube Player with options:
                \(html.playerOptionsJSON)
                """
            )
        // Load HTML contents
        self.loadHTMLString(
            html.contents,
            baseURL: self.originURL
        )
        return true
    }
    
}

// MARK: - YouTubePlayerWebView+evaluate

extension YouTubePlayerWebView {
    
    /// Evaluates the JavaScript.
    /// - Parameters:
    ///   - javaScript: The JavaScript that should be evaluated.
    func evaluate(
        javaScript: JavaScript
    ) async throws(YouTubePlayer.APIError) {
        try await self.evaluate(
            javaScript: javaScript,
            converter: .init { _, _ in }
        )
    }
    
    /// Evaluates the given JavaScript and converts the result using the supplied converter.
    /// - Parameters:
    ///   - javaScript: The JavaScript that should be evaluated.
    ///   - converter: The JavaScript response converter.
    func evaluate<Response>(
        javaScript: JavaScript,
        converter: JavaScriptEvaluationResponseConverter<Response>
    ) async throws(YouTubePlayer.APIError) -> Response {
        YouTubePlayer
            .Logger
            .category(self.player)?
            .debug(
                """
                Evaluate JavaScript: \(javaScript, privacy: .public)
                """
            )
        // Check if the player state is currently set to idle
        if let player = self.player, player.state == .idle {
            // Wait for the player to be non idle
            for await state in player.stateSubject.values where !state.isIdle  {
                // Break out of for-loop as state is either ready or error
                break
            }
        }
        // Declare JavaScript response
        let javaScriptResponse: Any?
        do {
            // Try to evaluate the JavaScript
            javaScriptResponse = try await self.evaluateJavaScriptAsync({
                if Response.self is Void.Type {
                    return javaScript.ignoreReturnValue().code
                } else {
                    return javaScript.code
                }
            }())
        } catch {
            // Initialize API error
            let apiError = YouTubePlayer.APIError(
                javaScript: javaScript.code,
                javaScriptResponse: nil,
                underlyingError: error,
                reason: (error as NSError)
                    .userInfo["WKJavaScriptExceptionMessage"] as? String
            )
            // Log error
            YouTubePlayer
                .Logger
                .category(self.player)?
                .error(
                    """
                    Evaluated JavaScript: \(javaScript, privacy: .public)
                    Error: \(apiError, privacy: .public)
                    """
                )
            // Throw error
            throw apiError
        }
        YouTubePlayer
            .Logger
            .category(self.player)?
            .debug(
                """
                Evaluated JavaScript: \(javaScript, privacy: .public)
                Result-Type: \(javaScriptResponse.flatMap { String(describing: Mirror(reflecting: $0).subjectType) } ?? "nil", privacy: .public)
                Result: \(String(describing: javaScriptResponse ?? "nil"), privacy: .public)
                """
            )
        // Check if JavaScript response is nil and the generic Response type is an optional type
        if javaScriptResponse == nil,
           let responseNilValue = (Response.self as? ExpressibleByNilLiteral.Type)?.init(nilLiteral: ()) as? Response {
            // Return nil
            return responseNilValue
        }
        do {
            // Return converted response
            return try converter(
                javaScript: javaScript,
                javaScriptResponse: javaScriptResponse
            )
        } catch {
            YouTubePlayer
                .Logger
                .category(self.player)?
                .error(
                    """
                    JavaScript response conversion failed
                    JavaScript: \(javaScript, privacy: .public)
                    Result: \(String(describing: javaScriptResponse ?? "nil"), privacy: .public)
                    Error: \(error, privacy: .public)
                    """
                )
            throw error
        }
    }
    
    /// Evaluates the specified JavaScript string.
    /// - Parameter javaScriptString: The JavaScript string to evaluate.
    /// - Returns: The result of the script evaluation.
    /// - Note: This function utilizes the completion closure based `evaluateJavaScript` API since the native async version causes under some conditions a runtime crash.
    private func evaluateJavaScriptAsync(
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

// MARK: - Destroy Player

extension YouTubePlayerWebView {
    
    /// Destroys the YouTube player.
    func destroyPlayer() async throws(YouTubePlayer.APIError) {
        try await self.evaluate(
            javaScript: .player(
                function: "destroy"
            )
        )
    }
    
}

// MARK: - WKUIDelegate

extension YouTubePlayerWebView: WKUIDelegate {
    
    /// WebView create WebView with configuration for navigation action
    /// - Parameters:
    ///   - webView: The WKWebView
    ///   - configuration: The WKWebViewConfiguration
    ///   - navigationAction: The WKNavigationAction
    ///   - windowFeatures: The WKWindowFeatures
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        // Check if the request url is available
        if let url = navigationAction.request.url {
            YouTubePlayer
                .Logger
                .category(self.player)?
                .debug("Open URL \(url, privacy: .public)")
            // Open URL
            Task(priority: .userInitiated) { [weak self] in
                await self?.player?.configuration.openURLAction(url)
            }
        }
        // Return nil as the URL has already been handled
        return nil
    }
    
}

// MARK: - WKNavigationDelegate

extension YouTubePlayerWebView: WKNavigationDelegate {
    
    /// WebView did fail provisional navigation
    /// - Parameters:
    ///   - webView: The web view.
    ///   - navigation: The navigation.
    ///   - error: The error.
    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        self.eventSubject.send(
            .didFailProvisionalNavigation(error)
        )
        YouTubePlayer
            .Logger
            .category(self.player)?
            .error("WKWebView did fail provisional navigation: \(error, privacy: .public)")
    }
    
    /// WebView decide policy for NavigationAction
    /// - Parameters:
    ///   - webView: The WKWebView
    ///   - navigationAction: The WKNavigationAction
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction
    ) async -> WKNavigationActionPolicy {
        // Verify URL of request is available
        guard let url = navigationAction.request.url else {
            // Otherwise cancel navigation action
            return .cancel
        }
        // Verify url is not about:blank
        guard url.absoluteString != "about:blank" else {
            // Otherwise allow navigation
            return .allow
        }
        // Check if Request URL host is equal to origin URL host
        if url.host?.lowercased() == self.originURL?.host?.lowercased() {
            // Allow navigation action
            return .allow
        }
        // Log url
        YouTubePlayer
            .Logger
            .category(self.player)?
            .debug("WKWebView navigate to \(url, privacy: .public)")
        // Check if the scheme matches the JavaScript evvent callback url scheme
        // and the host is a known JavaScript event name
        if url.scheme == HTML.javaScriptEventCallbackURLScheme,
           let javaScriptEventName = url.host.flatMap(YouTubePlayer.JavaScriptEvent.Name.init) {
            // Initialize JavaScript event
            let javaScriptEvent = YouTubePlayer.JavaScriptEvent(
                name: javaScriptEventName,
                data: URLComponents(
                    url: url,
                    resolvingAgainstBaseURL: true
                )?
                .queryItems?
                .first { $0.name == HTML.javaScriptEventCallbackDataParameterName }?
                .value
                .flatMap { $0 == "null" ? nil : $0 }
            )
            // Log received JavaScript event
            YouTubePlayer
                .Logger
                .category(self.player)?
                .debug("Received YouTubePlayer JavaScript Event\n\(javaScriptEvent, privacy: .public)")
            // Send received JavaScriptEvent
            self.eventSubject.send(
                .receivedJavaScriptEvent(javaScriptEvent)
            )
            // Cancel navigation action
            return .cancel
        }
        // Verify URL scheme is http or https
        guard url.scheme == "http" || url.scheme == "https" else {
            // Otherwise allow navigation action
            return .allow
        }
        // For each valid URL RegularExpression
        for validURLRegularExpression in Self.validURLRegularExpressions {
            // Find first match in URL
            let match = validURLRegularExpression.firstMatch(
                in: url.absoluteString,
                range: .init(
                    url.absoluteString.startIndex...,
                    in: url.absoluteString
                )
            )
            // Check if a match is available
            if match != nil {
                // Allow navigation action
                return .allow
            }
        }
        // Open URL
        Task(priority: .userInitiated) { [weak self] in
            await self?.player?.configuration.openURLAction(url)
        }
        // Cancel navigation action
        return .cancel
    }
    
    /// Invoked when the web view's web content process is terminated.
    /// - Parameter webView: The web view whose underlying web content process was terminated.
    func webViewWebContentProcessDidTerminate(
        _ webView: WKWebView
    ) {
        // Send web content process did terminate event
        self.eventSubject.send(
            .webContentProcessDidTerminate
        )
        YouTubePlayer
            .Logger
            .category(self.player)?
            .error("WKWebView web content process did terminate")
    }
    
}

// MARK: - YouTubePlayerWebView+validURLRegularExpressions

private extension YouTubePlayerWebView {
    
    /// The valid URL RegularExpressions
    /// - SeeAlso: https://github.com/youtube/youtube-ios-player-helper/blob/f57129cd4380ec0a74dd3a59da3270a1d653d59b/Sources/YTPlayerView.m#L59-L63
    static let validURLRegularExpressions: [NSRegularExpression] = [
        "^http(s)://(www.)youtube.com/embed/(.*)$",
        "^http(s)://pubads.g.doubleclick.net/pagead/conversion/",
        "^http(s)://accounts.google.com/o/oauth2/(.*)$",
        "^https://content.googleapis.com/static/proxy.html(.*)$",
        "^https://tpc.googlesyndication.com/sodar/(.*).html$"
    ]
    .compactMap { pattern in
        try? .init(
            pattern: pattern,
            options: .caseInsensitive
        )
    }
    
}
