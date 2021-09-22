import Foundation

// MARK: - YouTubePlayer+Perspective360Degree

public extension YouTubePlayer {
    
    /// The 360° YouTube player video playback perspective configuration
    struct Perspective360Degree: Codable, Hashable {
        
        // MARK: Properties
        
        /// Represents the horizontal angle of the view in degrees,
        /// which reflects the extent to which the user turns the view to face further left or right
        public let yaw: Int?
        
        /// Represents the vertical angle of the view in degrees,
        /// which reflects the extent to which the user adjusts the view to look up or down
        public let pitch: Int?
        
        /// Represents the clockwise or counterclockwise rotational angle of the view in degrees
        public let roll: Int?
        
        /// Represents the field-of-view of the view in degrees as measured along the longer edge of the viewport
        public let fov: Int?
        
        /// A boolean value that indicates whether the IFrame embed
        /// should respond to events that signal changes in a supported device's orientation
        public let enableOrientationSensor: Bool?
        
        // MARK: Initializer
        
        /// Creates a new instance of `YouTubePlayer.Perspective360Degree`
        public init(
            yaw: Int? = nil,
            pitch: Int? = nil,
            roll: Int? = nil,
            fov: Int? = nil,
            enableOrientationSensor: Bool? = nil
        ) {
            self.yaw = yaw.flatMap { max(0, min($0, 360)) }
            self.pitch = pitch.flatMap { max(-90, min($0, 90)) }
            self.roll = roll.flatMap { max(-180, min($0, 180)) }
            self.fov = fov.flatMap { max(30, min($0, 120)) }
            self.enableOrientationSensor = enableOrientationSensor
        }
        
    }
    
}
