import Foundation
import Testing

// MARK: - WebKitTestSupportTests

@MainActor
struct WebKitTestSupportTests {

    @Test("JavaScript fixture evaluation preserves a successful JSON response")
    func preservesJSONResponse() async throws {
        let result = try await WebKitTestSupport.evaluateJSON("fixture", timeout: 1) { completion in
            completion("{\"ready\":true}", nil)
        }
        #expect(result == "{\"ready\":true}")
    }

    @Test("JavaScript fixture evaluation preserves the original WebKit error")
    func preservesEvaluationError() async {
        let expectedError = NSError(domain: "Fixture", code: 42)
        await #expect {
            _ = try await WebKitTestSupport.evaluateJSON("fixture", timeout: 1) { completion in
                completion(nil, expectedError)
            }
        } throws: { error in
            return error as NSError == expectedError
        }
    }

    @Test("JavaScript fixture evaluation rejects responses that are not JSON strings")
    func rejectsInvalidResponse() async {
        await #expect {
            _ = try await WebKitTestSupport.evaluateJSON("fixture", timeout: 1) { completion in
                completion(42, nil)
            }
        } throws: { error in
            let error = error as NSError
            return error.domain == "WebKitTestSupport" && error.code == 2
        }
    }

    @Test("An unresponsive JavaScript evaluation times out and ignores a late callback")
    func timesOutAndIgnoresLateCallback() async throws {
        var completion: WebKitTestSupport.JavaScriptCompletion?
        await #expect {
            _ = try await WebKitTestSupport.evaluateJSON("unresponsive fixture", timeout: 0.01) {
                completion = $0
            }
        } throws: { error in
            let error = error as NSError
            #expect(error.localizedDescription.contains("unresponsive fixture"))
            return error.domain == "WebKitTestSupport" && error.code == 1
        }
        let callback = try #require(completion)
        callback("late response", nil)
    }

}
