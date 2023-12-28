import Foundation
import WebKit

// MARK: - YoutubePlayerWebView+WKScriptMessageHandler
extension YouTubePlayerWebView: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let message = message.body as? String {
            switch message {
            case YouTubePlayer.PictureInPictureState.enterpictureinpicture:
                player?.playerPictureInPictureSubject.send(.active)
            case YouTubePlayer.PictureInPictureState.leavepictureinpicture:
                player?.playerPictureInPictureSubject.send(.inactive)
            default:
                break
            }
        }
    }
}

extension YouTubePlayerWebView {

    /// The message handler name.
    static let messageHandlerName = "iosListener"

    /// The  user script injected at document end
    static let userScriptSource: String =
    """
    window.addEventListener('load', () => {
        var videos = document.getElementsByTagName('video');
        for (var i = 0; i < videos.length; i++) {
            videos[i].addEventListener('\(YouTubePlayer.PictureInPictureState.enterpictureinpicture)', () => window.webkit.messageHandlers.\(YouTubePlayerWebView.messageHandlerName).postMessage('\(YouTubePlayer.PictureInPictureState.enterpictureinpicture)'), false);
            videos[i].addEventListener('\(YouTubePlayer.PictureInPictureState.leavepictureinpicture)', () => window.webkit.messageHandlers.\(YouTubePlayerWebView.messageHandlerName).postMessage('\(YouTubePlayer.PictureInPictureState.leavepictureinpicture)'));
        }
    });
    """
}
