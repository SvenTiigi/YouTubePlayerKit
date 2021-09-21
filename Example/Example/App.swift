//
//  App.swift
//  Example
//
//  Created by Sven Tiigi on 20.09.21.
//

import SwiftUI

// MARK: - App

/// The App
@main
struct App {}

// MARK: - SwiftUI.App

extension App: SwiftUI.App {
    
    /// The content and behavior of the app
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
}
