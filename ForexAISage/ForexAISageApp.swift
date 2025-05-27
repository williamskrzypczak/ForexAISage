//
//  ForexAISageApp.swift
//  ForexAISage
//
//  Created by Bill Skrzypczak on 5/26/25.
//

import SwiftUI

// MARK: - Main App Entry Point
// This is the main entry point of the ForexAISage application
// The @main attribute indicates this is the starting point of the app
@main
struct ForexAISageApp: App {
    // The body property defines the app's scene structure
    var body: some Scene {
        // WindowGroup creates a window for the app's content
        WindowGroup {
            SplashScreenView()
        }
    }
}
