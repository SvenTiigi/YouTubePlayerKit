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
            YouTubePlayerViewController
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

// MARK: - YouTubePlayerViewController+Representable

private extension YouTubePlayerViewController {
    
    /// The YouTubePlayer ViewController SwiftUI Representable
    struct Representable: UIViewControllerRepresentable {
        
        /// The YouTube Player
        let player: YouTubePlayer
        
        /// Creates the view controller object and configures its initial state.
        /// - Parameter context: The Context
        func makeUIViewController(
            context: Context
        ) -> YouTubePlayerViewController {
            .init(
                player: self.player
            )
        }
        
        /// Updates the state of the specified view controller with new information from SwiftUI.
        /// - Parameters:
        ///   - uiViewController: The YouTubePlayer ViewController
        func updateUIViewController(
            _ uiViewController: YouTubePlayerViewController,
            context: Context
        ) {
            guard self.player != uiViewController.player else {
                return
            }
            uiViewController.player = self.player
        }
        
    }
    
}
