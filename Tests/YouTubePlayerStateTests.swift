import Testing
@testable import YouTubePlayerKit

// MARK: - YouTubePlayerStateTests

struct YouTubePlayerStateTests {

    @Test(
        "Each player state compares equal to itself",
        arguments: [
            YouTubePlayer.State.idle,
            .ready,
            .error(.invalidSource),
            .error(.webContentProcessDidTerminate)
        ]
    )
    func equalityIsReflexive(
        state: YouTubePlayer.State
    ) {
        #expect(state == state)
    }

    @Test("Different lifecycle states and error reasons remain distinguishable")
    func distinguishesLifecycleStates() {
        let states: [YouTubePlayer.State] = [
            .idle,
            .ready,
            .error(.invalidSource),
            .error(.notFound)
        ]
        for (index, state) in states.enumerated() {
            for otherState in states.dropFirst(index + 1) {
                #expect(state != otherState)
                #expect(otherState != state)
            }
        }
    }

    @Test("State inspection agrees with the lifecycle case")
    func exposesLifecycleAndError() {
        let idle = YouTubePlayer.State.idle
        let ready = YouTubePlayer.State.ready
        let failed = YouTubePlayer.State.error(.notFound)
        #expect(idle.isIdle && !idle.isReady && !idle.isError)
        #expect(ready.isReady && !ready.isIdle && !ready.isError)
        #expect(failed.isError && !failed.isIdle && !failed.isReady)
        #expect(idle.error == nil)
        #expect(ready.error == nil)
        guard case .notFound = failed.error else {
            Issue.record("The error state must expose its underlying player error")
            return
        }
    }

    @Test(
        "Documented YouTube error codes map to the expected player errors",
        arguments: [
            (2, YouTubePlayer.State.error(.invalidSource)),
            (5, .error(.html5NotSupported)),
            (100, .error(.notFound)),
            (101, .error(.embeddedVideoPlayingNotAllowed)),
            (150, .error(.embeddedVideoPlayingNotAllowed)),
            (153, .error(.missingAPIClientIdentification))
        ]
    )
    func mapsPlayerErrorCodes(
        code: Int,
        expectedState: YouTubePlayer.State
    ) throws {
        let error = try #require(YouTubePlayer.Error(errorCode: code))
        #expect(YouTubePlayer.State.error(error) == expectedState)
    }

    @Test("Unknown error codes are not misclassified")
    func preservesUnknownErrorCodes() {
        #expect(YouTubePlayer.Error(errorCode: 999) == nil)
    }

}
