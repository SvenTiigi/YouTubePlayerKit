import SwiftUI
import YouTubePlayerKit

// MARK: - ContentView

/// The ContentView
struct ContentView {

    /// All  WWDC Keynotes.
    private let wwdcKeynotes = WWDCKeynote.all.sorted(by: >)
    
    /// The selected WWDC keynote.
    @State
    private var selectedKeynote: WWDCKeynote? = .wwdc2023
    
    /// The YouTube Player.
    @StateObject
    private var youTubePlayer = YouTubePlayer(
        source: .url(WWDCKeynote.wwdc2023.youTubeURL),
        configuration: .init(
            fullscreenMode: {
                #if os(macOS) || os(visionOS)
                .web
                #else
                .system
                #endif
            }()
        )
    )
    
    /// The color scheme.
    @Environment(\.colorScheme)
    private var colorScheme
    
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
        .onChange(of: self.selectedKeynote) { _, keynote in
            guard let keynote else {
                return self.youTubePlayer.stop()
            }
            self.youTubePlayer.cue(source: .url(keynote.youTubeURL))
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
                        ForEach(self.wwdcKeynotes) { keynote in
                            Button {
                                self.selectedKeynote = keynote
                            } label: {
                                YouTubePlayerView(
                                    .init(
                                        source: .url(keynote.youTubeURL)
                                    )
                                )
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
            List(self.wwdcKeynotes, selection: self.$selectedKeynote) { wwdcKeynote in
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
            List(self.wwdcKeynotes, selection: self.$selectedKeynote) { wwdcKeynote in
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
