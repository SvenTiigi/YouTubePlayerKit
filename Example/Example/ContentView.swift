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
    let youTubePlayer: YouTubePlayer = "https://www.youtube.com/watch?v=psL_5RIBqnY&t=3181"
    
}

// MARK: - View

extension ContentView: View {
    
    /// The content and behavior of the view
    var body: some View {
        NavigationView {
            VStack {
                YouTubePlayerView(
                    self.youTubePlayer,
                    placeholderOverlay: {
                        ProgressView()
                    }
                )
                .frame(height: 200)
                Spacer()
            }
            .navigationBarTitle(" WWDC Events")
        }
    }
    
}
