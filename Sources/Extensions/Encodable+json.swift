import Foundation

// MARK: - Encodable+json

extension Encodable {
    
    /// Make JSON Dictionary
    /// - Parameter encoder: The JSONEncoder. Default value `.init()`
    func json(
        encoder: JSONEncoder = .init()
    ) throws -> [String: Any] {
        // Set without escaping slashes output formatting
        encoder.outputFormatting = .withoutEscapingSlashes
        // Encode
        let jsonData = try encoder.encode(self)
        // Serialize to JSON object
        let jsonObject = try JSONSerialization.jsonObject(
           with: jsonData,
           options: .allowFragments
        )
        // Verify JSON object can be casted to a Dictionary
        guard let jsonDictionary = jsonObject as? [String: Any] else {
            // Otherwise throw Error
            throw DecodingError.typeMismatch(
                [String: Any].self,
                .init(
                    codingPath: .init(),
                    debugDescription: "Malformed JSON object"
                )
            )
        }
        // Return JSON Dictionary
        return jsonDictionary
    }
    
}

// MARK: - Encodable+jsonString

extension Encodable {
    
    /// Make JSON String
    /// - Parameters:
    ///   - encoder: The JSONEncoder. Default value `.init()`
    ///   - options: The JSONSerialization WritingOptions. Default value `.init()`
    func jsonString(
        encoder: JSONEncoder = .init(),
        options: JSONSerialization.WritingOptions = .init()
    ) throws -> String {
        try self
            .json(encoder: encoder)
            .jsonString(options: options)
    }
    
}
