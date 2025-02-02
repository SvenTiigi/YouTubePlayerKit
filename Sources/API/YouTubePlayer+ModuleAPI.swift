import Combine
import Foundation

// MARK: - Module API

public extension YouTubePlayer {
    
    /// Returns the loaded modules of the player.
    func getModules() async throws(APIError) -> [Module] {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "getOptions"
            ),
            converter: .typeCast(
                to: [String].self
            )
        )
        .map(Module.init(name:))
    }
    
    /// Returns the options of a module.
    /// - Parameter module: The module to retrieve options for.
    func getModuleOptions(
        for module: Module
    ) async throws(APIError) -> [Module.Option] {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "getOptions",
                parameters: [
                    "'\(module.name)'"
                ]
            ),
            converter: .typeCast(
                to: [String].self
            )
        )
        .map(Module.Option.init(name:))
    }
    
    /// Sets an option of a module.
    /// - Parameters:
    ///   - module: The module.
    ///   - option: The option.
    ///   - value: The value.
    func setModuleOption(
        module: Module,
        option: Module.Option,
        value: LosslessStringConvertible
    ) async throws(APIError) {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "setOption",
                parameters: [
                    "'\(module.name)'",
                    "'\(option.name)'",
                    value
                ]
            )
        )
    }
    
    /// Returns the value of an option for a module.
    /// - Parameters:
    ///   - module: The module
    ///   - option: The option.
    ///   - converter: The response converter.
    func getModuleOption<Value>(
        module: Module,
        option: Module.Option,
        converter: JavaScriptEvaluationResponseConverter<Value>
    ) async throws(APIError) -> Value {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "getOption",
                parameters: [
                    "'\(module.name)'",
                    "'\(option.name)'"
                ]
            ),
            converter: converter
        )
    }
    
}
