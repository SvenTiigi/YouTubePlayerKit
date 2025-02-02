import Foundation

// MARK: - ExpressibleByURL

/// A protocol that enables a type to be initialized using a URL.
public protocol ExpressibleByURL {
    
    /// Creates a new instance from the given URL.
    /// - Parameter url: The URL.
    init?(url: URL)
    
}

// MARK: - ExpressibleByURL+init(urlString:)

public extension ExpressibleByURL {
    
    /// Creates a new instance from the given URL string.
    /// - Parameter urlString: The URL string.
    init?(urlString: String) {
        guard let url: URL = {
            if #available(iOS 17.0, macOS 14.0, visionOS 1.0, *) {
                return .init(
                    string: urlString,
                    encodingInvalidCharacters: false
                )
            } else {
                return .init(
                    string: urlString
                )
            }
        }() else {
            return nil
        }
        self.init(url: url)
    }
    
}
