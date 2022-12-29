import SwiftUI
import WebKit

// MARK: - YouTubePlayerView

/// A YouTubePlayer SwiftUI View
public struct YouTubePlayerView<Overlay: View> {
    
    // MARK: Properties
    
    /// The YouTubePlayer
    public let player: YouTubePlayer
    
    /// The The transaction to use when the `YouTubePlayer.State` changes
    public let transaction: Transaction
    
    /// The Overlay ViewBuilder closure
    public let overlay: (YouTubePlayer.State) -> Overlay
    
    /// The current YouTubePlayer State
    @State
    private var state: YouTubePlayer.State = .idle
    
    // MARK: Initializer
    
    /// Creates a new instance of `YouTubePlayer.View`
    /// - Parameters:
    ///   - player: The YouTubePlayer
    ///   - transaction: The transaction to use when the `YouTubePlayer.State` changes. Default value `.init()`
    ///   - overlay: The Overlay ViewBuilder closure
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
    
    /// The content and behavior of the view
    public var body: some View {
        YouTubePlayerWebView.Representable(
            player: self.player
        )
        .overlay(
            self.overlay(self.state)
        )
        .preference(
            key: YouTubePlayer.PreferenceKey.self,
            value: self.player
        )
        .onReceive(
            self.player
                .statePublisher
                .receive(on: DispatchQueue.main)
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
            playerWebView.player?.pause()
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
            playerWebView.player?.pause()
        }
        
    }
    #endif
    
}
