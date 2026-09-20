import Testing
import Foundation
@testable import YouTubePlayerKit

struct YouTubePlayerJavaScriptTests {
    
    @Test("Empty JavaScript has no content or description")
    func emptyInitializer() {
        let javaScript = YouTubePlayer.JavaScript()
        #expect(javaScript.content().isEmpty)
        #expect(javaScript.description.isEmpty)
    }
    
    @Test("JavaScript initialization preserves the supplied code")
    func designatedInitializer() {
        let javaScriptCode = "const x = 1;"
        let javaScript = YouTubePlayer.JavaScript(javaScriptCode)
        #expect(javaScript.content() == javaScriptCode)
        #expect(javaScript.description == javaScriptCode)
    }
    
    @Test("JavaScript statements end with exactly one semicolon")
    func statementTerminatorNormalization() {
        #expect(
            YouTubePlayer.JavaScript("const x = 1").content() == "const x = 1;"
        )
        #expect(
            YouTubePlayer.JavaScript("const x = 1;").content() == "const x = 1;"
        )
        #expect(
            YouTubePlayer.JavaScript("const x = 1;;;").content() == "const x = 1;"
        )
        #expect(
            YouTubePlayer.JavaScript("const x = 1;  \n  ;;  ").content() == "const x = 1;"
        )
    }
    
    @Test("Variable interpolation uses the configured player variable name")
    func variableInterpolation() {
        let youTubePlayerVariableName = UUID().uuidString
        let functionName = UUID().uuidString
        let javaScript: YouTubePlayer.JavaScript = "\(.youTubePlayer).\(functionName)()"
        #expect(
            javaScript.content(variableNames: [.youTubePlayer: youTubePlayerVariableName])
            ==
            "\(youTubePlayerVariableName).\(functionName)();"
        )
    }
    
    @Test("Every player variable interpolation uses the same configured name")
    func multipleVariableInterpolations() {
        let youTubePlayerVariableName = UUID().uuidString
        let javaScript: YouTubePlayer.JavaScript = """
        \(.youTubePlayer).play();
        \(.youTubePlayer).pause();
        """
        #expect(
            javaScript.content(variableNames: [.youTubePlayer: youTubePlayerVariableName])
            ==
            """
            \(youTubePlayerVariableName).play();
            \(youTubePlayerVariableName).pause();
            """
        )
    }
    
    @Test("Player operators are appended to the configured player variable")
    func youTubePlayerOperator() {
        let youTubePlayerVariableName = UUID().uuidString
        let functionName = UUID().uuidString
        #expect(
            YouTubePlayer
                .JavaScript
                .youTubePlayer(operator: "\(functionName)()")
                .content(variableNames: [.youTubePlayer: youTubePlayerVariableName])
            ==
            "\(youTubePlayerVariableName).\(functionName)();"
        )
    }
    
    @Test("Player function calls without parameters use empty parentheses")
    func youTubePlayerFunctionWithoutParameters() {
        let youTubePlayerVariableName = UUID().uuidString
        let functionName = UUID().uuidString
        #expect(
            YouTubePlayer
                .JavaScript
                .youTubePlayer(functionName: functionName)
                .content(variableNames: [.youTubePlayer: youTubePlayerVariableName])
            ==
            "\(youTubePlayerVariableName).\(functionName)();"
        )
    }
    
    @Test("Player function calls preserve their supplied JavaScript argument")
    func youTubePlayerFunctionWithParameters() {
        let youTubePlayerVariableName = UUID().uuidString
        let functionName = UUID().uuidString
        let parameter = UUID().uuidString
        #expect(
            YouTubePlayer
                .JavaScript
                .youTubePlayer(functionName: functionName, parameters: [parameter])
                .content(variableNames: [.youTubePlayer: youTubePlayerVariableName])
            ==
            "\(youTubePlayerVariableName).\(functionName)(\(parameter));"
        )
    }
    
    @Test(
        "Player function calls separate multiple arguments with commas in their original order",
        arguments: [2, 3, 5]
    )
    func youTubePlayerFunctionWithMultipleParameters(
        count: Int
    ) {
        let youTubePlayerVariableName = UUID().uuidString
        let functionName = UUID().uuidString
        let parameters = (0..<count).map { "argument\($0)" }
        #expect(
            YouTubePlayer
                .JavaScript
                .youTubePlayer(functionName: functionName, parameters: parameters)
                .content(variableNames: [.youTubePlayer: youTubePlayerVariableName])
            ==
            "\(youTubePlayerVariableName).\(functionName)(\(parameters.joined(separator: ", ")));"
        )
    }
    
    @Test(
        "Player function calls encode structured arguments with the supplied JSON encoder",
        arguments: [(false, false), (false, true), (true, false), (true, true)]
    )
    func youTubePlayerFunctionWithEncodableParameter(
        first: Bool,
        second: Bool
    ) throws {
        struct Parameter: Encodable {
            var example1: Bool
            var example2: Bool
        }
        let jsonEncoder: JSONEncoder = {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
            return jsonEncoder
        }()
        let functionName = UUID().uuidString
        let parameter = Parameter(
            example1: first,
            example2: second
        )
        let parameterJSONString = String(
            decoding: try jsonEncoder.encode(parameter),
            as: UTF8.self
        )
        let javaScript = try YouTubePlayer.JavaScript.youTubePlayer(
            functionName: functionName,
            jsonParameter: parameter,
            jsonEncoder: jsonEncoder
        )
        let youTubePlayerVariableName = UUID().uuidString
        #expect(
            javaScript.content(variableNames: [.youTubePlayer: youTubePlayerVariableName])
            ==
            """
            \(youTubePlayerVariableName).\(functionName)(\(parameterJSONString));
            """
        )
    }
    
    @Test("Ignoring a JavaScript return value appends a null expression")
    func ignoreReturnValue() {
        let youTubePlayerVariableName = UUID().uuidString
        let functionName = UUID().uuidString
        #expect(
            YouTubePlayer
                .JavaScript
                .youTubePlayer(functionName: functionName)
                .ignoreReturnValue()
                .content(variableNames: [.youTubePlayer: youTubePlayerVariableName])
            ==
            """
            \(youTubePlayerVariableName).\(functionName)(); null;
            """
        )
    }
    
    @Test("JavaScript can be wrapped in an immediately invoked function expression")
    func immediatelyInvokedFunctionExpression() {
        let youTubePlayerVariableName = UUID().uuidString
        let functionName = UUID().uuidString
        #expect(
            YouTubePlayer
                .JavaScript
                .youTubePlayer(functionName: functionName)
                .asImmediatelyInvokedFunctionExpression()
                .content(variableNames: [.youTubePlayer: youTubePlayerVariableName])
            ==
            """
            (function() {
                \(youTubePlayerVariableName).\(functionName)();
            })();
            """
        )
    }
    
    @Test("Function wrapping preserves player arguments and return-value suppression")
    func combinedFeatures() {
        let youTubePlayerVariableName = UUID().uuidString
        let functionName = UUID().uuidString
        let parameter = UUID().uuidString
        #expect(
            YouTubePlayer
                .JavaScript
                .youTubePlayer(functionName: functionName, parameters: [parameter])
                .ignoreReturnValue()
                .asImmediatelyInvokedFunctionExpression()
                .content(variableNames: [.youTubePlayer: youTubePlayerVariableName])
            ==
            """
            (function() {
                \(youTubePlayerVariableName).\(functionName)(\(parameter)); null;
            })();
            """
        )
    }
    
    @Test("Descriptions retain variable placeholders while content uses default variable names")
    func emptyVariableNames() {
        let functionName = UUID().uuidString
        let javaScript = YouTubePlayer
            .JavaScript
            .youTubePlayer(functionName: functionName)
        #expect(
            javaScript.description
            ==
            "\(YouTubePlayer.JavaScript.Variable.youTubePlayer.placeholderRawValue).\(functionName)();"
        )
        #expect(
            javaScript.content()
            ==
            "\(YouTubePlayer.JavaScript.Variable.youTubePlayer.rawValue).\(functionName)();"
        )
    }
    
}
