import Foundation

// MARK: - Dictionary+jsonData

extension Dictionary {
    
    /// Make JSON String
    /// - Parameter options: The JSONSerialization WritingOptions. Default value `.init()`
    func jsonData(
        options: JSONSerialization.WritingOptions = .init()
    ) throws -> Data {
        try JSONSerialization.data(
            withJSONObject: self,
            options: options
        )
    }
    
}

// MARK: - Dictionary+jsonString

extension Dictionary {
    
    /// Make JSON String
    /// - Parameter options: The JSONSerialization WritingOptions. Default value `.init()`
    func jsonString(
        options: JSONSerialization.WritingOptions = .init()
    ) throws -> String {
        .init(
            decoding: try JSONSerialization.data(
                withJSONObject: self,
                options: options
            ),
            as: UTF8.self
        )
    }
    
}
