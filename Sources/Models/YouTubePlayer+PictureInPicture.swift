import Foundation

// MARK: - YouTubePlayer+PictureInPictureState
public extension YouTubePlayer {

    /// The YouTubePlayer PictureInPictureState
    enum PictureInPictureState: Int, Codable, Hashable, CaseIterable {
        /// inactive
        case inactive = 0
        /// active
        case active = 1
    }
}

extension YouTubePlayer.PictureInPictureState {

    /// The enterpictureinpicture EventListener name.
    static let enterpictureinpicture = "enterpictureinpicture"

    /// The leavepictureinpicture EventListener name.
    static let leavepictureinpicture = "leavepictureinpicture"
}
