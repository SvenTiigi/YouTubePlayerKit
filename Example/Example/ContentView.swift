//
//  ContentView.swift
//  Example
//
//  Created by Sven Tiigi on 20.09.21.
//

import SwiftUI
import YouTubePlayerKit

// MARK: - ContentView

/// The ContentView
struct ContentView {

    /// The YouTube Player
    private let youTubePlayer = YouTubePlayer(
        source: .url(WWDCKeynote.wwdc2021.youTubeURL)
    )
    
    /// All  WWDC Keynotes
    private let wwdcKeynotes: [WWDCKeynote] = WWDCKeynote.all.sorted(by: >)
    
    /// The color scheme
    @Environment(\.colorScheme)
    private var colorScheme
    
}

// MARK: - View

extension ContentView: View {
    
    /// The content and behavior of the view
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                YouTubePlayerView(
                    self.youTubePlayer,
                    placeholderOverlay: {
                        ProgressView()
                    }
                )
                .frame(height: 220)
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(self.wwdcKeynotes) { wwdcKeynote in
                            Button(
                                action: {
                                    self.youTubePlayer.source = .url(wwdcKeynote.youTubeURL)
                                },
                                label: {
                                    YouTubePlayerThumbnailView(
                                        wwdcKeynote.youTubeURL,
                                        isUserInteractionEnabled: false
                                    )
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitle(" WWDC Keynotes")
            .navigationBarItems(
                trailing: Link(
                    destination: URL(
                        string: "https://github.com/SvenTiigi/YouTubePlayerKit"
                    )!,
                    label: {
                        Image(
                            systemName: "play.rectangle.fill"
                        )
                        .imageScale(.large)
                    }
                )
            )
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
}
