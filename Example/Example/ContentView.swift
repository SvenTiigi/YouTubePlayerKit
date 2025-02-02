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
    private var wwdcKeynote: WWDCKeynote
    
    /// The state.
    @State
    private var state: YouTubePlayer.State = .idle
    
    /// The playback state.
    @State
    private var playbackState: YouTubePlayer.PlaybackState?
    
    /// The playback quality.
    @State
    private var playbackQuality: YouTubePlayer.PlaybackQuality?
    
    /// The playback rate.
    @State
    private var playbackRate: YouTubePlayer.PlaybackRate?
    
    /// The playback metadata.
    @State
    private var playbackMetadata: YouTubePlayer.PlaybackMetadata?
    
    // MARK: Initializer
    
    /// Creates a new instance of ``ContentView``
    /// - Parameter wwdcKeynote: The WWDC Keynote.
    init(
        wwdcKeynote: WWDCKeynote = .wwdc2024
    ) {
        self.youTubePlayer = .init(
            source: .init(urlString: wwdcKeynote.youTubeURL),
            isLoggingEnabled: true
        )
        self._wwdcKeynote = .init(initialValue: wwdcKeynote)
    }

}

// MARK: - View

extension ContentView: View {
    
    /// The content and behavior of the view.
    var body: some View {
        NavigationStack {
            List {
                self.playerSection
                self.keynotePickerSection
                self.stateSection
                self.metadataSection
                self.parametersSection
                self.mediaControlSection
            }
            .headerProminence(.increased)
            .navigationTitle("YouTubePlayerKit")
        }
        .onReceive(
            self.youTubePlayer.statePublisher
        ) { state in
            self.state = state
        }
        .onReceive(
            self.youTubePlayer.playbackStatePublisher
        ) { playbackState in
            self.playbackState = playbackState
        }
        .onReceive(
            self.youTubePlayer.playbackQualityPublisher
        ) { playbackQuality in
            self.playbackQuality = playbackQuality
        }
        .onReceive(
            self.youTubePlayer.playbackRatePublisher
        ) { playbackRate in
            self.playbackRate = playbackRate
        }
        .onReceive(
            self.youTubePlayer.playbackMetadataPublisher
        ) { playbackMetadata in
            self.playbackMetadata = playbackMetadata
        }
        .animation(.snappy, value: self.state)
        .animation(.snappy, value: self.playbackState)
        .animation(.snappy, value: self.playbackQuality)
        .animation(.snappy, value: self.playbackRate)
        .animation(.snappy, value: self.playbackMetadata)
    }
    
}

// MARK: - Player Section

private extension ContentView {
    
    /// The player section
    var playerSection: some View {
        Section {
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
            .aspectRatio(16/9, contentMode: .fit)
            .listRowInsets(.init())
            #if !os(macOS)
            .listRowBackground(Color(.systemGroupedBackground))
            #endif
        }
    }
    
}

// MARK: - Keynote Picker Section

private extension ContentView {
    
    /// The keynote picker section.
    var keynotePickerSection: some View {
        Section {
            Picker(
                "WWDC Keynote",
                selection: self.$wwdcKeynote
            ) {
                ForEach(
                    WWDCKeynote.allCases.reversed(),
                    id: \.self
                ) { wwdcKeynote in
                    Text("WWDC \(String(wwdcKeynote.year))")
                        .tag(wwdcKeynote)
                }
            }
            .pickerStyle(.menu)
            .onChange(
                of: self.wwdcKeynote
            ) { _, wwdcKeynote in
                Task { @MainActor in
                    guard let source = YouTubePlayer.Source(urlString: wwdcKeynote.youTubeURL) else {
                        try? await self.youTubePlayer.stop()
                        return
                    }
                    try? await self.youTubePlayer.cue(source: source)
                }
            }
        }
    }
    
}

// MARK: - State Section

private extension ContentView {
    
    /// The state section.
    @MainActor
    var stateSection: some View {
        Section("State") {
            LabeledContent(
                "State",
                value: {
                    switch self.state {
                    case .idle:
                        return "Idle"
                    case .ready:
                        return "Ready"
                    case .error:
                        return "Error"
                    }
                }()
            )
            LabeledContent(
                "Playback State",
                value: {
                    switch self.playbackState {
                    case .unstarted:
                        return "Unstarted"
                    case .ended:
                        return "Ended"
                    case .playing:
                        return "Playing"
                    case .paused:
                        return "Paused"
                    case .buffering:
                        return "Buffering"
                    case .cued:
                        return "Cued"
                    case nil:
                        return ""
                    default:
                        return "Unknown"
                    }
                }()
            )
            LabeledContent(
                "Playback Rate",
                value: self.playbackRate?.description ?? ""
            )
            LabeledContent(
                "Playback Quality",
                value: {
                    switch self.playbackQuality {
                    case .auto:
                        return "Auto"
                    case .small:
                        return "Small"
                    case .medium:
                        return "Medium"
                    case .large:
                        return "Large"
                    case .hd720:
                        return "720p"
                    case .hd1080:
                        return "1080p"
                    case .highResolution:
                        return "High Resolution"
                    case nil:
                        return ""
                    default:
                        return "Unknown"
                    }
                }()
            )
            LabeledContent("Logging") {
                Menu {
                    ForEach([true, false], id: \.self) { isEnabled in
                        Button {
                            self.youTubePlayer.isLoggingEnabled = isEnabled
                        } label: {
                            Label {
                                Text(isEnabled ? "Enabled" : "Disabled")
                            } icon: {
                                if self.youTubePlayer.isLoggingEnabled == isEnabled {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .disabled(self.youTubePlayer.isLoggingEnabled == isEnabled)
                    }
                } label: {
                    Text(
                        self.youTubePlayer.isLoggingEnabled 
                            ? "Enabled"
                            : "Disabled"
                    )
                }
            }
            Button("Reload", systemImage: "arrow.clockwise") {
                Task {
                    try? await self.youTubePlayer.reload()
                }
            }
        }
    }
    
}

// MARK: - Metadata Section

private extension ContentView {
    
    /// The metadata section.
    @ViewBuilder
    var metadataSection: some View {
        if let playbackMetadata = self.playbackMetadata {
            Section("Metadata") {
                if let title = playbackMetadata.title {
                    LabeledContent(
                        "Title",
                        value: title
                    )
                }
                if let author = playbackMetadata.author {
                    LabeledContent(
                        "Author",
                        value: author
                    )
                }
                if let videoId = playbackMetadata.videoId {
                    LabeledContent(
                        "Video ID",
                        value: videoId
                    )
                }
            }
        }
    }
    
}

// MARK: - Parameters Section

private extension ContentView {
    
    /// The parameters section
    var parametersSection: some View {
        Section {
            YouTubePlayerBoolParameterControl(
                "Auto Play",
                parameter: \.autoPlay,
                youTubePlayer: self.youTubePlayer
            )
            YouTubePlayerBoolParameterControl(
                "Loop Enabled",
                parameter: \.loopEnabled,
                youTubePlayer: self.youTubePlayer
            )
            YouTubePlayerBoolParameterControl(
                "Show Controls",
                parameter: \.showControls,
                youTubePlayer: self.youTubePlayer
            )
            YouTubePlayerBoolParameterControl(
                "Show Fullscreen Button",
                parameter: \.showFullscreenButton,
                youTubePlayer: self.youTubePlayer
            )
            YouTubePlayerBoolParameterControl(
                "Keyboard Controls Disabled",
                parameter: \.keyboardControlsDisabled,
                youTubePlayer: self.youTubePlayer
            )
            YouTubePlayerBoolParameterControl(
                "Show Captions",
                parameter: \.showCaptions,
                youTubePlayer: self.youTubePlayer
            )
        } header: {
            Text("Parameters")
        } footer: {
            Text("Note: Changing a parameter will reload the YouTube player to apply the new setting.")
        }
    }
    
    
    /// A YouTube player bool parameter control.
    struct YouTubePlayerBoolParameterControl: View {
        
        // MARK: Properties
        
        /// The title.
        private let titleKey: LocalizedStringKey
        
        /// The key path.
        private let keyPath: WritableKeyPath<YouTubePlayer.Parameters, Bool?>
        
        /// The YouTube player.
        @ObservedObject
        private var youTubePlayer: YouTubePlayer
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayerBoolParameterControl``
        /// - Parameters:
        ///   - titleKey: The title.
        ///   - keyPath: The key path.
        ///   - youTubePlayer: The YouTube player.
        init(
            _ titleKey: LocalizedStringKey,
            parameter keyPath: WritableKeyPath<YouTubePlayer.Parameters, Bool?>,
            youTubePlayer: YouTubePlayer
        ) {
            self.titleKey = titleKey
            self.keyPath = keyPath
            self.youTubePlayer = youTubePlayer
        }
        
        // MARK: View
        
        /// The content and behavior of the view.
        var body: some View {
            LabeledContent(self.titleKey) {
                Menu {
                    let parameter = self.youTubePlayer.parameters[keyPath: self.keyPath]
                    ForEach(
                        [true, false, nil],
                        id: \.self
                    ) { value in
                        Button {
                            self.youTubePlayer.parameters[keyPath: self.keyPath] = value
                        } label: {
                            Label {
                                switch value {
                                case .some(true):
                                    Text("On")
                                case .some(false):
                                    Text("Off")
                                case nil:
                                    Text("Default")
                                }
                            } icon: {
                                if value == parameter {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .disabled(parameter == value)
                    }
                } label: {
                    switch self.youTubePlayer.parameters[keyPath: self.keyPath] {
                    case .some(true):
                        Text("On")
                    case .some(false):
                        Text("Off")
                    case nil:
                        Text("Default")
                    }
                }
            }
        }
        
    }
    
}

// MARK: - Media Control Section

private extension ContentView {
    
    /// The media control section.
    var mediaControlSection: some View {
        Section("Media Control") {
            Button("Play", systemImage: "play") {
                Task {
                    try? await self.youTubePlayer.play()
                }
            }
            Button("Pause", systemImage: "pause") {
                Task {
                    try? await self.youTubePlayer.pause()
                }
            }
            Button("Stop", systemImage: "stop") {
                Task {
                    try? await self.youTubePlayer.stop()
                }
            }
            Button("Mute", systemImage: "speaker.slash") {
                Task {
                    try? await self.youTubePlayer.mute()
                }
            }
            Button("Unmute", systemImage: "speaker.wave.3.fill") {
                Task {
                    try? await self.youTubePlayer.unmute()
                }
            }
            Button("Show Stats For Nerds", systemImage: "eyeglasses") {
                Task {
                    try? await self.youTubePlayer.setStatsForNerds(isVisible: true)
                }
            }
            Button("Hide Stats For Nerds", systemImage: "eyeglasses") {
                Task {
                    try? await self.youTubePlayer.setStatsForNerds(isVisible: false)
                }
            }
        }
    }
    
}

// MARK: - Preview

#Preview {
    ContentView()
}
