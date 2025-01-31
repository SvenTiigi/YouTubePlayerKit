import Foundation

// MARK: - Volume API

public extension YouTubePlayer {
    
    /// Mutes the player.
    func mute() async throws(APIError) {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "mute"
            )
        )
    }
    
    /// Unmutes the player.
    func unmute() async throws(APIError) {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "unMute"
            )
        )
    }
    
    /// Returns Bool value if the player is muted.
    func isMuted() async throws(APIError) -> Bool {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "isMuted"
            ),
            converter: .typeCast()
        )
    }
    
    /// Returns the player's current volume, an integer between 0 and 100
    func getVolume() async throws(APIError) -> Int {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "getVolume"
            ),
            converter: .typeCast()
        )
    }
    
}
