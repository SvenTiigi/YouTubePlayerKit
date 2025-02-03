import SwiftUI

// MARK: - YouTubePlayerView

/// The YouTube player SwiftUI view.
public struct YouTubePlayerView<Overlay: View> {
    
    // MARK: Properties
    
    /// The ``YouTubePlayer``.
    public let player: YouTubePlayer
    
    /// The The transaction to use when the ``YouTubePlayer/State`` changes.
    public let transaction: Transaction
    
    /// A closure which constructs the `Overlay` for a given state.
    public let overlay: (YouTubePlayer.State) -> Overlay
    
    /// The current ``YouTubePlayer/State``
    @State
    private var state: YouTubePlayer.State = .idle
    
    // MARK: Initializer
    
    /// Creates a new instance of ``YouTubePlayerView``
    /// - Parameters:
    ///   - player: The ``YouTubePlayer``.
    ///   - transaction: The transaction to use when the state changes. Default value `.init()`
    ///   - overlay: A view builder closure to construct an `Overlay` for the given state.
    public init(
        _ player: YouTubePlayer,
        transaction: Transaction = .init(),
        @ViewBuilder
        overlay: @escaping (YouTubePlayer.State) -> Overlay
    ) {
        self.player = player
        self.transaction = transaction
        self.overlay = overlay
    }
    
}

// MARK: - View

extension YouTubePlayerView: View {
    
    /// The content and behavior of the view.
    public var body: some View {
        YouTubePlayerWebView.Representable(
            player: self.player
        )
        .overlay(
            self.overlay(self.state)
        )
        .onReceive(
            self.player.statePublisher
        ) { state in
            withTransaction(self.transaction) {
                self.state = state
            }
        }
    }
    
}

// MARK: - YouTubePlayerWebView+Representable

private extension YouTubePlayerWebView {
    
    #if !os(macOS)
    /// The YouTubePlayer UIView SwiftUI Representable
    struct Representable: UIViewRepresentable {
        
        /// The YouTube Player
        let player: YouTubePlayer
        
        /// Make YouTubePlayerWebView
        /// - Parameter context: The Context
        /// - Returns: The YouTubePlayerWebView
        func makeUIView(
            context: Context
        ) -> YouTubePlayerWebView {
            self.player.webView
        }
        
        /// Update YouTubePlayerWebView
        /// - Parameters:
        ///   - playerWebView: The YouTubePlayerWebView
        ///   - context: The Context
        func updateUIView(
            _ playerWebView: YouTubePlayerWebView,
            context: Context
        ) {}
        
        /// Dismantle YouTubePlayerWebView
        /// - Parameters:
        ///   - playerWebView: The YouTubePlayerWebView
        ///   - coordinator: The Coordinaotr
        static func dismantleUIView(
            _ playerWebView: YouTubePlayerWebView,
            coordinator: Void
        ) {
            Task { [weak playerWebView] in
                try? await playerWebView?.player?.pause()
            }
        }
        
    }
    #else
    /// The YouTubePlayer NSView SwiftUI Representable
    struct Representable: NSViewRepresentable {
        
        /// The YouTube Player
        let player: YouTubePlayer
        
        /// Make YouTubePlayerWebView
        /// - Parameter context: The Context
        /// - Returns: The YouTubePlayerWebView
        func makeNSView(
            context: Context
        ) -> YouTubePlayerWebView {
            self.player.webView
        }
        
        /// Update YouTubePlayerWebView
        /// - Parameters:
        ///   - playerWebView: The YouTubePlayerWebView
        ///   - context: The Context
        func updateNSView(
            _ playerWebView: YouTubePlayerWebView,
            context: Context
        ) {}
        
        /// Dismantle YouTubePlayerWebView
        /// - Parameters:
        ///   - playerWebView: The YouTubePlayerWebView
        ///   - coordinator: The Coordinaotr
        static func dismantleNSView(
            _ playerWebView: YouTubePlayerWebView,
            coordinator: Void
        ) {
            Task { [weak playerWebView] in
                try? await playerWebView?.player?.pause()
            }
        }
        
    }
    #endif
    
}
