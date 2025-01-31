import Combine
import Foundation

// MARK: - Event API

public extension YouTubePlayer {
    
    /// A Publisher that emits a received JavaScript event.
    var javaScriptEventPublisher: some Publisher<JavaScriptEvent, Never> {
        self.webView
            .eventSubject
            .compactMap(\.javaScriptEvent)
            .receive(on: DispatchQueue.main)
    }
    
    /// A Publisher that emits the current YouTube player source.
    var sourcePublisher: some Publisher<Source?, Never> {
        self.sourceSubject
            .receive(on: DispatchQueue.main)
    }
    
    /// The current YouTube player state.
    var state: State {
        self.stateSubject.value
    }
    
    /// A Publisher that emits the current YouTube player state.
    var statePublisher: some Publisher<State, Never> {
        self.stateSubject
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
    }
    
}
