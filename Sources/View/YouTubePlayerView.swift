import SwiftUI

// MARK: - YouTubePlayerView

/// A YouTubePlayer SwiftUI View
public struct YouTubePlayerView<Overlay: View> {
    
    // MARK: Properties
    
    /// The YouTubePlayer
    public let player: YouTubePlayer
    
    /// The Overlay ViewBuilder closure
    public let overlay: (YouTubePlayer.State) -> Overlay
    
    /// The current YouTubePlayer State
    @State
    private var state: YouTubePlayer.State = .idle
    
    // MARK: Initializer
    
    /// Creates a new instance of `YouTubePlayer.View`
    /// - Parameters:
    ///   - player: The YouTubePlayer
    ///   - overlay: The Overlay ViewBuilder closure
    public init(
        _ player: YouTubePlayer,
        @ViewBuilder
        overlay: @escaping (YouTubePlayer.State) -> Overlay
    ) {
        self.player = player
        self.overlay = overlay
    }
    
}

// MARK: - View

extension YouTubePlayerView: View {
    
    /// The content and behavior of the view
    public var body: some View {
        ZStack {
            YouTubePlayerWebView
                .Representable(player: self.player)
            self.overlay(self.state)
        }
        .onReceive(
            self.player
                .statePublisher
                .receive(on: DispatchQueue.main)
        ) { state in
            self.state = state
        }
    }
    
}

// MARK: - YouTubePlayerWebView+Representable

private extension YouTubePlayerWebView {
    
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
            .init(
                player: self.player
            )
        }
        
        /// Update YouTubePlayerWebView
        /// - Parameters:
        ///   - uiView: The YouTubePlayerWebView
        ///   - context: The Context
        func updateUIView(
            _ uiView: YouTubePlayerWebView,
            context: Context
        ) {}
        
    }
    
}