import Testing
import Foundation
@testable import YouTubePlayerKit

struct YouTubePlayerJavaScriptTests {
    
    @Test
    func emptyInitializer() {
        let javaScript = YouTubePlayer.JavaScript()
        #expect(javaScript.code().isEmpty)
        #expect(javaScript.description.isEmpty)
    }
    
    @Test
    func designatedInitializer() {
        let javaScriptCode = "const x = 1;"
        let javaScript = YouTubePlayer.JavaScript(javaScriptCode)
        #expect(javaScript.code() == javaScriptCode)
        #expect(javaScript.description == javaScriptCode)
    }
    
    @Test
    func statementTerminatorNormalization() {
        #expect(
            YouTubePlayer.JavaScript("const x = 1").code() == "const x = 1;"
        )
        #expect(
            YouTubePlayer.JavaScript("const x = 1;").code() == "const x = 1;"
        )
        #expect(
            YouTubePlayer.JavaScript("const x = 1;;;").code() == "const x = 1;"
        )
        #expect(
            YouTubePlayer.JavaScript("const x = 1;  \n  ;;  ").code() == "const x = 1;"
        )
    }
    
    @Test
    func variableInterpolation() {
        let youTubePlayerVariableName = UUID().uuidString
        let functionName = UUID().uuidString
        let javaScript: YouTubePlayer.JavaScript = "\(.youTubePlayer).\(functionName)()"
        #expect(
            javaScript.code(variableNames: [.youTubePlayer: youTubePlayerVariableName])
            ==
            "\(youTubePlayerVariableName).\(functionName)();"
        )
    }
    
    @Test
    func multipleVariableInterpolations() {
        let youTubePlayerVariableName = UUID().uuidString
        let javaScript: YouTubePlayer.JavaScript = """
        \(.youTubePlayer).play();
        \(.youTubePlayer).pause();
        """
        #expect(
            javaScript.code(variableNames: [.youTubePlayer: youTubePlayerVariableName])
            ==
            """
            \(youTubePlayerVariableName).play();
            \(youTubePlayerVariableName).pause();
            """
        )
    }
    
    @Test
    func youTubePlayerOperator() {
        let youTubePlayerVariableName = UUID().uuidString
        let functionName = UUID().uuidString
        #expect(
            YouTubePlayer
                .JavaScript
                .youTubePlayer(operator: "\(functionName)()")
                .code(variableNames: [.youTubePlayer: youTubePlayerVariableName])
            ==
            "\(youTubePlayerVariableName).\(functionName)();"
        )
    }
    
    @Test
    func youTubePlayerFunctionWithoutParameters() {
        let youTubePlayerVariableName = UUID().uuidString
        let functionName = UUID().uuidString
        #expect(
            YouTubePlayer
                .JavaScript
                .youTubePlayer(functionName: functionName)
                .code(variableNames: [.youTubePlayer: youTubePlayerVariableName])
            ==
            "\(youTubePlayerVariableName).\(functionName)();"
        )
    }
    
    @Test
    func youTubePlayerFunctionWithParameters() {
        let youTubePlayerVariableName = UUID().uuidString
        let functionName = UUID().uuidString
        let parameter = UUID().uuidString
        #expect(
            YouTubePlayer
                .JavaScript
                .youTubePlayer(functionName: functionName, parameters: [parameter])
                .code(variableNames: [.youTubePlayer: youTubePlayerVariableName])
            ==
            "\(youTubePlayerVariableName).\(functionName)(\(parameter));"
        )
    }
    
    @Test
    func youTubePlayerFunctionWithMultipleParameters() {
        let youTubePlayerVariableName = UUID().uuidString
        let functionName = UUID().uuidString
        let parameters = [String](repeating: UUID().uuidString, count: .random(in: 2...5))
        #expect(
            YouTubePlayer
                .JavaScript
                .youTubePlayer(functionName: functionName, parameters: parameters)
                .code(variableNames: [.youTubePlayer: youTubePlayerVariableName])
            ==
            "\(youTubePlayerVariableName).\(functionName)(\(parameters.joined(separator: ", ")));"
        )
    }
    
    @Test
    func youTubePlayerFunctionWithEncodableParameter() throws {
        struct Parameter: Encodable {
            var example1: Bool = .random()
            var example2: Bool = .random()
        }
        let jsonEncoder: JSONEncoder = {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
            return jsonEncoder
        }()
        let functionName = UUID().uuidString
        let parameter = Parameter()
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
            javaScript.code(variableNames: [.youTubePlayer: youTubePlayerVariableName])
            ==
            """
            \(youTubePlayerVariableName).\(functionName)(\(parameterJSONString));
            """
        )
    }
    
    @Test
    func ignoreReturnValue() {
        let youTubePlayerVariableName = UUID().uuidString
        let functionName = UUID().uuidString
        #expect(
            YouTubePlayer
                .JavaScript
                .youTubePlayer(functionName: functionName)
                .ignoreReturnValue()
                .code(variableNames: [.youTubePlayer: youTubePlayerVariableName])
            ==
            """
            \(youTubePlayerVariableName).\(functionName)(); null;
            """
        )
    }
    
    @Test
    func immediatelyInvokedFunctionExpression() {
        let youTubePlayerVariableName = UUID().uuidString
        let functionName = UUID().uuidString
        #expect(
            YouTubePlayer
                .JavaScript
                .youTubePlayer(functionName: functionName)
                .asImmediatelyInvokedFunctionExpression()
                .code(variableNames: [.youTubePlayer: youTubePlayerVariableName])
            ==
            """
            (function() {
                \(youTubePlayerVariableName).\(functionName)();
            })();
            """
        )
    }
    
    @Test
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
                .code(variableNames: [.youTubePlayer: youTubePlayerVariableName])
            ==
            """
            (function() {
                \(youTubePlayerVariableName).\(functionName)(\(parameter)); null;
            })();
            """
        )
    }
    
    @Test
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
            javaScript.code()
            ==
            "\(YouTubePlayer.JavaScript.Variable.youTubePlayer.rawValue).\(functionName)();"
        )
    }
    
}
