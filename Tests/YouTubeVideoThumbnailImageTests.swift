import Foundation
import Testing
@testable import YouTubePlayerKit

// MARK: - YouTubeVideoThumbnailImageTests

@MainActor
struct YouTubeVideoThumbnailImageTests {

    @Test("A successful thumbnail response decodes an image")
    func decodesImage() async throws {
        let session = self.makeSession()
        defer { session.invalidateAndCancel() }
        let image = try await YouTubeVideoThumbnail(
            videoID: "video",
            host: "success.example"
        )
        .image(urlSession: session)
        let decoded = try #require(image)
        #expect(decoded.size.width == 1)
        #expect(decoded.size.height == 1)
    }

    @Test("Unusable thumbnail responses produce no image", arguments: [
        "not-found.example", "empty.example", "invalid-image.example"
    ])
    func rejectsUnusableResponse(
        host: String
    ) async throws {
        let session = self.makeSession()
        defer { session.invalidateAndCancel() }
        let image = try await YouTubeVideoThumbnail(
            videoID: "video",
            host: host
        )
        .image(urlSession: session)
        #expect(image == nil)
    }

    @Test("Thumbnail transport failures retain their original error")
    func propagatesTransportFailure() async {
        let session = self.makeSession()
        defer { session.invalidateAndCancel() }
        do {
            _ = try await YouTubeVideoThumbnail(
                videoID: "video",
                host: "failure.example"
            )
            .image(urlSession: session)
            Issue.record("A transport failure must be thrown")
        } catch {
            #expect((error as? URLError)?.code == .timedOut)
        }
    }

}

// MARK: - Session

private extension YouTubeVideoThumbnailImageTests {

    /// Creates a session whose responses are entirely local to this test suite.
    func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [ThumbnailURLProtocol.self]
        return URLSession(configuration: configuration)
    }

}

// MARK: - ThumbnailURLProtocol

/// Provides immutable response fixtures selected by host, without global mutable handlers.
private final class ThumbnailURLProtocol: URLProtocol, @unchecked Sendable {

    /// Handles every request made by a fixture session.
    override class func canInit(
        with request: URLRequest
    ) -> Bool {
        return true
    }

    /// Preserves the URL used to select the response fixture.
    override class func canonicalRequest(
        for request: URLRequest
    ) -> URLRequest {
        return request
    }

    /// Delivers the selected local response or transport error synchronously.
    override func startLoading() {
        guard let url = self.request.url else {
            self.client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        if url.host == "failure.example" {
            self.client?.urlProtocol(self, didFailWithError: URLError(.timedOut))
            return
        }
        guard let response = HTTPURLResponse(
            url: url,
            statusCode: url.host == "not-found.example" ? 404 : 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "image/png"]
        ) else {
            self.client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        let data: Data
        switch url.host {
        case "empty.example":
            data = .init()
        case "invalid-image.example":
            data = Data("not an image".utf8)
        default:
            guard let imageData = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==") else {
                self.client?.urlProtocol(self, didFailWithError: URLError(.cannotDecodeContentData))
                return
            }
            data = imageData
        }
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        self.client?.urlProtocol(self, didLoad: data)
        self.client?.urlProtocolDidFinishLoading(self)
    }

    /// No asynchronous work remains after the synchronous fixture response.
    override func stopLoading() {}

}
