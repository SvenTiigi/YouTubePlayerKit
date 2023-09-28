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

    /// All  WWDC Keynotes
    private let wwdcKeynotes: [WWDCKeynote] = WWDCKeynote.all.sorted(by: >)
    
    /// The YouTube Player
    @StateObject
    private var youTubePlayer = YouTubePlayer(
        source: .url(WWDCKeynote.wwdc2022.youTubeURL)
    )
    
    /// The color scheme
    @Environment(\.colorScheme)
    private var colorScheme
    
}

// MARK: - View

extension ContentView: View {
    
    /// The content and behavior of the view
    var body: some View {
        NavigationView {
            ScrollView {
                YouTubePlayerView(
                    self.youTubePlayer,
                    placeholderOverlay: {
                        ProgressView()
                    }
                )
                .frame(height: 220)
                .background(Color(.systemBackground))
                .shadow(
                    color: .black.opacity(0.1),
                    radius: 46,
                    x: 0,
                    y: 15
                )
                VStack(spacing: 20) {
                    ForEach(self.wwdcKeynotes) { wwdcKeynote in
                        Button(
                            action: {
                                self.youTubePlayer.source = .url(wwdcKeynote.youTubeURL)
                            },
                            label: {
                                YouTubePlayerView(
                                    .init(
                                        source: .url(wwdcKeynote.youTubeURL)
                                    )
                                )
                                .disabled(true)
                                .frame(height: 150)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                            }
                        )
                    }
                }
                .padding()
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
            .background(
                Color(
                    self.colorScheme == .dark
                        ? .secondarySystemGroupedBackground
                        : .systemGroupedBackground
                )
            )
            .scrollContentBackground(.hidden)
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
}
