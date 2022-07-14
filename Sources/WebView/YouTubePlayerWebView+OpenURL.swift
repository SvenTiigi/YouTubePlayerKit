#if os(macOS)
import AppKit
#else
import UIKit
#endif

// MARK: - YouTubePlayerWebView+open(url:)

extension YouTubePlayerWebView {
    
    /// Open URL
    /// - Parameter url: The URL that should be opened
    func open(
        url: URL
    ) {
        // Check if a custom OpenURLAction is available
        if let openURLAction = self.player.configuration.openURLAction {
            // Call OpenURLAction
            openURLAction(url)
        } else {
            // Otherwise open URL via Safari
            #if os(macOS)
            NSWorkspace.shared.open(
                [url],
                withAppBundleIdentifier: "com.apple.Safari",
                options: .init(),
                additionalEventParamDescriptor: nil,
                launchIdentifiers: nil
            )
            #else
            UIApplication.shared.open(
                url,
                options: .init()
            )
            #endif
        }
    }
    
}
