import SwiftUI
import YouTubePlayerKit

// MARK: - ContentView

/// The ContentView
struct ContentView {
    
    // MARK: Properties
    
    /// The YouTube Player.
    private let youTubePlayer: YouTubePlayer
    
    /// The selected WWDC keynote.
    @State
    private var selectedKeynote: WWDCKeynote?
    
    /// The color scheme.
    @Environment(\.colorScheme)
    private var colorScheme
    
    // MARK: Initializer
    
    /// Creates a new instance of ``ContentView``
    /// - Parameter wwdcKeynote: The WWDC Keynote.
    init(
        wwdcKeynote: WWDCKeynote = .wwdc2024
    ) {
        self.youTubePlayer = .init(
            source: [
                "w87fOAG8fjk", // 2014
                "RXeOiIDNNek", // 2024
                "psL_5RIBqnY" // 2019
            ]
        )
        self._selectedKeynote = .init(initialValue: wwdcKeynote)
    }
    
}

// MARK: - View

extension ContentView: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Group {
            #if os(macOS)
            self.macOSBody
            #elseif os(visionOS)
            self.visionOSBody
            #else
            self.iOSBody
            #endif
        }
        .onChange(
            of: self.selectedKeynote
        ) { _, selectedKeynote in
            Task { @MainActor in
                guard let selectedKeynote = selectedKeynote,
                      let source = YouTubePlayer.Source(urlString: selectedKeynote.youTubeURL) else {
                    try? await self.youTubePlayer.stop()
                    return
                }
                try? await self.youTubePlayer.load(source: source)
            }
        }
    }
    
}

// MARK: - Player

private extension ContentView {
    
    /// The content and behavior of the YouTube player view.
    var playerView: some View {
        YouTubePlayerView(self.youTubePlayer) { state in
            switch state {
            case .idle:
                ProgressView()
            case .ready:
                EmptyView()
            case .error:
                Label(
                    "An error occurred.",
                    systemImage: "xmark.circle.fill"
                )
                .foregroundStyle(.red)
            }
        }
    }
    
}

// MARK: - iOS

#if os(iOS)
private extension ContentView {
    
    /// The content and behavior of the view for the iOS platform.
    var iOSBody: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(
                    spacing: 20,
                    pinnedViews: [.sectionHeaders]
                ) {
                    Section {
                        ForEach(WWDCKeynote.allCases.reversed()) { keynote in
                            Button {
                                self.selectedKeynote = keynote
                            } label: {
                                Rectangle()
                                /*
                                YouTubePlayerView(
                                    .init(
                                        urlString: keynote.youTubeURL
                                    )
                                )*/
                                .disabled(true)
                                .frame(height: 150)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                    } header: {
                        self.playerView
                            .frame(height: 220)
                            .background(Color(.systemBackground))
                            .shadow(
                                color: .black.opacity(0.1),
                                radius: 46,
                                x: 0,
                                y: 15
                            )
                    }
                }
            }
            .navigationTitle(" WWDC Keynotes")
            .background(
                Color(
                    self.colorScheme == .dark
                        ? .secondarySystemGroupedBackground
                        : .systemGroupedBackground
                )
            )
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reload") {
                        Task {
                            print("Start reloading")
                            defer {
                                print("Finished reloading")
                            }
                            try await self.youTubePlayer.reload()
                        }
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
}
#endif

// MARK: - visionOS

#if os(visionOS)
private extension ContentView {
    
    /// The content and behavior of the view for the visionOS platform.
    var visionOSBody: some View {
        NavigationSplitView {
            List(
                WWDCKeynote.allCases.reversed(),
                selection: self.$selectedKeynote
            ) { wwdcKeynote in
                Text(String(wwdcKeynote.year))
                    .tag(wwdcKeynote)
            }
            .listStyle(.sidebar)
            .navigationTitle(" WWDC Keynotes")
        } detail: {
            self.playerView
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 16,
                        style: .continuous
                    )
                )
                .padding()
                .toolbar(.hidden)
        }
    }
    
}
#endif

// MARK: - macOS

#if os(macOS)
private extension ContentView {

    /// The content and behavior of the view for the macOS platform.
    var macOSBody: some View {
        NavigationSplitView {
            List(
                WWDCKeynote.allCases.reversed(),
                selection: self.$selectedKeynote
            ) { wwdcKeynote in
                Text(String(wwdcKeynote.year))
                    .tag(wwdcKeynote)
            }
            .listStyle(.sidebar)
            .navigationTitle(" WWDC Keynotes")
        } detail: {
            self.playerView
                .toolbar(.hidden)
        }
    }
    
}
#endif

#Preview {
    ContentView()
}
