import SwiftUI
import LinkPresentation

// MARK: - YouTubePlayerThumbnailView

/// A YouTubePlayer Thumbnail View
public struct YouTubePlayerThumbnailView {
    
    // MARK: Properties
    
    /// The URL
    private let url: URL?
    
    /// The LinkPresentation Metadata
    @State
    private var metadata: LPLinkMetadata?
    
    // MARK: Initializer
    
    /// Creates a new instance of `YouTubePlayerThumbnailView`
    /// - Parameters:
    ///   - url: The URL
    public init(
        _ url: URL?
    ) {
        self.url = url
    }
    
}

// MARK: - YouTubePlayerThumbnailView+init(url:)

public extension YouTubePlayerThumbnailView {
    
    /// Creates a new instance of `YouTubePlayerThumbnailView`
    /// - Parameters:
    ///   - url: The URL
    init(
        _ url: String
    ) {
        self.init(
            .init(
                string: url
            )
        )
    }
    
}

// MARK: - Start fetching Metadata

private extension YouTubePlayerThumbnailView {
    
    /// Start fetching metadata from an optional URL
    /// - Parameter url: The optional URL to fetch start fetching metadata
    func startFetchingMetadata(
        from url: URL?
    ) {
        // Verify URL is available
        guard let url = url else {
            // Otherwise return out of function
            return
        }
        // Clear current metadata
        self.metadata = nil
        // Initialize a new MetadataProvider
        let metadataProvider = LPMetadataProvider()
        // Start fetching metadata for URL
        metadataProvider.startFetchingMetadata(
            for: url
        ) { metadata, _ in
            // Set Metadata
            self.metadata = metadata
        }
    }
    
}

// MARK: - View

extension YouTubePlayerThumbnailView: View {
    
    /// The content and behavior of the view
    public var body: some View {
        let linkView = LPLinkView.Representable(
            url: self.url,
            metaData: self.metadata
        )
        .onAppear {
            self.startFetchingMetadata(
                from: self.url
            )
        }
        if #available(iOS 14.0, macOS 11.0, *) {
            linkView
                .onChange(
                    of: self.url,
                    perform: self.startFetchingMetadata
                )
        } else {
            linkView
        }
    }
    
}

// MARK: - LPLinkView+Representable

private extension LPLinkView {
    
    #if os(macOS)
    /// A LPLinkView SwiftUI Representable NSView
    struct Representable: NSViewRepresentable {
        
        // MARK: Properties
        
        /// The URL
        let url: URL?
        
        /// The LPLinkMetadata
        let metaData: LPLinkMetadata?
        
        // MARK: UIViewRepresentable
        
        /// Make LPLinkView
        /// - Parameter context: The Context
        func makeNSView(
            context: Context
        ) -> LPLinkView {
            self.url.flatMap { .init(url: $0) } ?? .init()
        }
        
        /// Update LPLinkView
        /// - Parameters:
        ///   - linkView: The LPLinkView
        ///   - context: The Context
        func updateNSView(
            _ linkView: LPLinkView,
            context: Context
        ) {
            self.metaData.flatMap { linkView.metadata = $0 }
        }
        
    }
    #else
    /// A LPLinkView SwiftUI Representable UIView
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
    #endif
    
}
