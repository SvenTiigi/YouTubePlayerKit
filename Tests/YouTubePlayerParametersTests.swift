import Foundation
import Testing
@testable import YouTubePlayerKit

// MARK: - YouTubePlayerParametersTests

struct YouTubePlayerParametersTests {

    @Test(
        "Boolean parameters accept the supported JSON representations",
        arguments: [
            ("true", true),
            ("false", false),
            ("1", true),
            ("0", false),
            (#""true""#, true),
            (#""false""#, false),
            (#""1""#, true),
            (#""0""#, false)
        ]
    )
    func decodesBooleanRepresentations(
        representation: String,
        expectedValue: Bool
    ) throws {
        let parameters = try JSONDecoder().decode(
            YouTubePlayer.Parameters.self,
            from: Data("{\"autoplay\":\(representation)}".utf8)
        )
        #expect(parameters.autoPlay == expectedValue)
    }

    @Test(
        "Invalid boolean representations are rejected during decoding",
        arguments: ["2", "-1", #""yes""#, "[]", "{}"]
    )
    func rejectsInvalidBooleanRepresentations(
        representation: String
    ) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(
                YouTubePlayer.Parameters.self,
                from: Data("{\"autoplay\":\(representation)}".utf8)
            )
        }
    }

    @Test("URL parameters use API names and the start parameter takes precedence over t")
    func parsesURLParameters() throws {
        let url = try #require(URL(string: "https://youtube.com/watch?v=video&autoplay=1&controls=0&start=12&t=99&end=45&hl=de&cc_lang_pref=en&cc_load_policy=true&color=white"))
        let parameters = try #require(YouTubePlayer.Parameters(url: url))
        #expect(parameters.autoPlay == true)
        #expect(parameters.showControls == false)
        #expect(parameters.startTime == .init(value: 12, unit: .seconds))
        #expect(parameters.endTime == .init(value: 45, unit: .seconds))
        #expect(parameters.language == "de")
        #expect(parameters.captionLanguage == "en")
        #expect(parameters.showCaptions == true)
        #expect(parameters.progressBarColor == .white)
    }

    @Test("URL parsing ignores invalid values while retaining valid independent parameters")
    func toleratesInvalidURLValues() throws {
        let url = try #require(URL(string: "https://youtube.com/watch?t=37&autoplay=invalid&controls=2&end=invalid&color=blue&hl=%20de%20"))
        let parameters = try #require(YouTubePlayer.Parameters(url: url))
        #expect(parameters.startTime == .init(value: 37, unit: .seconds))
        #expect(parameters.autoPlay == nil)
        #expect(parameters.showControls == nil)
        #expect(parameters.endTime == nil)
        #expect(parameters.progressBarColor == nil)
        #expect(parameters.language == "de")
    }

    @Test("URLs without player parameters retain the normal defaults")
    func usesDefaultsForURLWithoutQuery() throws {
        let url = try #require(URL(string: "https://youtube.com/watch"))
        #expect(YouTubePlayer.Parameters(url: url) == .init())
    }

    @Test("Repeated URL query names preserve the first nonempty value without crashing")
    func handlesRepeatedURLParameters() throws {
        let url = try #require(URL(string: "https://youtube.com/watch?autoplay=1&autoplay=0&start=12&start=99&hl=&hl=de&hl=en&v=first&v=second"))
        let parameters = try #require(YouTubePlayer.Parameters(url: url))
        #expect(parameters.autoPlay == true)
        #expect(parameters.startTime == .init(value: 12, unit: .seconds))
        #expect(parameters.language == "de")
    }

    @Test("Missing and null optional JSON values do not become explicit playback settings")
    func decodesMissingAndNullParameters() throws {
        let parameters = try JSONDecoder().decode(
            YouTubePlayer.Parameters.self,
            from: Data(#"{"autoplay":null,"start":null,"futureParameter":true}"#.utf8)
        )
        #expect(parameters.autoPlay == nil)
        #expect(parameters.startTime == nil)
        #expect(parameters.originURL == nil)
    }

}
