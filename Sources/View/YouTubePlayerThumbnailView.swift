import SwiftUI
import LinkPresentation

// MARK: - YouTubePlayerThumbnailView

/// A YouTubePlayer Thumbnail View
public struct YouTubePlayerThumbnailView {
    
    // MARK: Properties
    
    /// The URL
    private let url: URL?
    
    /// A Bool value if user interactions are enabled
    private let isUserInteractionEnabled: Bool
    
    /// The LinkPresentation Metadata
    @State
    private var metadata: LPLinkMetadata?
    
    // MARK: Initializer
    
    /// Creates a new instance of `YouTubePlayerThumbnailView`
    /// - Parameters:
    ///   - url: The URL
    ///   - isUserInteractionEnabled: A Bool value if user interactions are enabled. Default value `true`
    public init(
        _ url: URL?,
        isUserInteractionEnabled: Bool = true
    ) {
        self.url = url
        self.isUserInteractionEnabled = isUserInteractionEnabled
    }
    
}

// MARK: - YouTubePlayerThumbnailView+init(url:)

public extension YouTubePlayerThumbnailView {
    
    /// Creates a new instance of `YouTubePlayerThumbnailView`
    /// - Parameters:
    ///   - url: The URL
    ///   - isUserInteractionEnabled: A Bool value if user interactions are enabled. Default value `true`
    init(
        _ url: String,
        isUserInteractionEnabled: Bool = true
    ) {
        self.init(
            .init(
                string: url
            ),
            isUserInteractionEnabled: isUserInteractionEnabled
        )
    }
    
}

// MARK: - View

extension YouTubePlayerThumbnailView: View {
    
    /// The content and behavior of the view
    public var body: some View {
        LPLinkView.Representable(
            url: self.url,
            metaData: self.metadata
        )
        .disabled(!self.isUserInteractionEnabled)
        .onAppear {
            // Verify URL is available
            guard let url = self.url else {
                // Otherwise return out of function
                return
            }
            // Start fetching metadata for URL
            LPMetadataProvider().startFetchingMetadata(
                for: url
            ) { metadata, _ in
                // Set Metadata
                self.metadata = metadata
            }
        }
    }
    
}

// MARK: - LPLinkView+Representable

private extension LPLinkView {
    
    /// A LPLinkView SwiftUI Representable View
    struct Representable: UIViewRepresentable {
        
        // MARK: Properties
        
        /// The URL
        let url: URL?
        
        /// The LPLinkMetadata
        let metaData: LPLinkMetadata?
        
        // MARK: UIViewRepresentable
        
        /// Make LPLinkView
        /// - Parameter context: The Context
        func makeUIView(
            context: Context
        ) -> LPLinkView {
            self.url.flatMap { .init(url: $0) } ?? .init()
        }
        
        /// Update LPLinkView
        /// - Parameters:
        ///   - linkView: The LPLinkView
        ///   - context: The Context
        func updateUIView(
            _ linkView: LPLinkView,
            context: Context
        ) {
            self.metaData.flatMap { linkView.metadata = $0 }
        }
        
    }
    
}
