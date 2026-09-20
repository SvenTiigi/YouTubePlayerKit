import Foundation
import Testing
@testable import YouTubePlayerKit

struct YouTubePlayerHTMLBuilderTests {

    @Test("Custom subscription configuration survives encoding")
    func encodesAdditionalSubscriptions() throws {
        let builder = YouTubePlayer.HTMLBuilder(
            youTubePlayerScriptMessageHandlerName: "custom-handler",
            additionalEventNames: ["onFutureEvent", .ready]
        )
        let decoded = try JSONDecoder().decode(
            YouTubePlayer.HTMLBuilder.self,
            from: JSONEncoder().encode(builder)
        )
        #expect(decoded == builder)
        #expect(decoded.additionalEventNames == ["onFutureEvent", .ready])
        #expect(try decoded(jsonEncodedPlayerOptionsString: "{}") == builder(jsonEncodedPlayerOptionsString: "{}"))
        var other = builder
        other.additionalEventNames.insert("anotherEvent")
        #expect(other != builder)
        #expect(Set([builder, other]).count == 2)
    }

    @Test("Empty handler names fail before invoking custom HTML providers")
    func rejectsEmptyHandlerNames() {
        let builder = YouTubePlayer.HTMLBuilder(
            youTubePlayerScriptMessageHandlerName: "",
            htmlProvider: { _, _ in
                Issue.record("An invalid handler name must fail before invoking the provider")
                return ""
            }
        )
        #expect(throws: YouTubePlayer.APIError.self) {
            try builder(jsonEncodedPlayerOptionsString: "{}")
        }
        #expect(throws: YouTubePlayer.APIError.self) {
            try YouTubePlayer.HTMLBuilder.defaultHTMLProvider()(builder, "{}")
        }
    }

    @Test("Custom HTML providers receive the configured builder and options")
    func forwardsCustomProviderInputs() throws {
        let builder = YouTubePlayer.HTMLBuilder(
            additionalEventNames: ["onFutureEvent"],
            htmlProvider: { builder, options in
                #expect(builder.additionalEventNames == ["onFutureEvent"])
                #expect(options == "{\"videoId\":\"example\"}")
                return "<html>custom</html>"
            }
        )
        #expect(try builder(jsonEncodedPlayerOptionsString: "{\"videoId\":\"example\"}") == "<html>custom</html>")
    }

}
