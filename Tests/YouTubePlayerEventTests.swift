import Foundation
import Testing
@testable import YouTubePlayerKit

struct YouTubePlayerEventTests {

    @Test("Unknown event names and payloads survive Codable round trips")
    func preservesUnknownEvents() throws {
        let name = "onFutureEvent-\(UUID().uuidString)"
        let json = "{\"name\":\"\(name)\",\"data\":\"  unknown payload  \"}"
        let event = try JSONDecoder().decode(
            YouTubePlayer.Event.self,
            from: Data(json.utf8)
        )
        #expect(event.name.rawValue == name)
        #expect(event.data?.value == "  unknown payload  ")
        let encoded = try JSONEncoder().encode(event)
        #expect(try JSONDecoder().decode(YouTubePlayer.Event.self, from: encoded) == event)
        let object = try #require(JSONSerialization.jsonObject(with: encoded) as? [String: String])
        #expect(object["name"] == name)
    }

    @Test("Absent and null payloads decode as no data", arguments: [
        #"{"name":"onReady"}"#,
        #"{"name":"onReady","data":null}"#
    ])
    func decodesMissingData(
        json: String
    ) throws {
        let event = try JSONDecoder().decode(
            YouTubePlayer.Event.self,
            from: Data(json.utf8)
        )
        #expect(event.name == .ready)
        #expect(event.data == nil)
    }

    @Test("String payloads preserve their exact contents", arguments: [
        "", "null", "undefined", "  value\n", "a+b & é 😀"
    ])
    func preservesStrings(
        value: String
    ) throws {
        let payload = try #require(YouTubePlayer.Event.Data(javaScriptValue: value))
        #expect(payload.value == value)
        let decoded = try JSONDecoder().decode(
            YouTubePlayer.Event.Data.self,
            from: JSONEncoder().encode(payload)
        )
        #expect(decoded == payload)
    }

    @Test("Native JSON payloads remain available without known schemas")
    func convertsNativeValues() throws {
        #expect(YouTubePlayer.Event.Data(javaScriptValue: nil) == nil)
        #expect(YouTubePlayer.Event.Data(javaScriptValue: NSNull()) == nil)
        #expect(YouTubePlayer.Event.Data(javaScriptValue: true)?.value == "true")
        #expect(YouTubePlayer.Event.Data(javaScriptValue: 0.25)?.value == "0.25")
        let payload = try #require(YouTubePlayer.Event.Data(javaScriptValue: ["future": [1, 2, 3]]))
        #expect(try payload.jsonValue(as: [String: [Int]].self) == ["future": [1, 2, 3]])
        #expect(YouTubePlayer.Event.Data(javaScriptValue: ["invalid": Date()]) == nil)
    }

    @Test("Typed access fails gracefully for unexpected payloads")
    func handlesUnexpectedPayloads() {
        let payload = YouTubePlayer.Event.Data(value: "unexpected")
        #expect(payload.value(as: Int.self) == nil)
        #expect(throws: DecodingError.self) {
            try payload.jsonValue(as: [String: Int].self)
        }
    }

}
