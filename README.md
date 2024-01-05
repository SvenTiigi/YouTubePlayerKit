<br/>

<p align="center">
    <img src="Assets/logo.png" width="30%" alt="logo">
</p>

<h1 align="center">YouTubePlayerKit</h1>

<p align="center">
    A Swift Package to easily play YouTube videos
    <br/>
    with extended support for SwiftUI, Combine and async/await
</p>

<p align="center">
   <a href="https://swiftpackageindex.com/SvenTiigi/YouTubePlayerKit">
    <img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSvenTiigi%2FYouTubePlayerKit%2Fbadge%3Ftype%3Dswift-versions" alt="Swift Version">
   </a>
   <a href="https://swiftpackageindex.com/SvenTiigi/YouTubePlayerKit">
    <img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSvenTiigi%2FYouTubePlayerKit%2Fbadge%3Ftype%3Dplatforms" alt="Platforms">
   </a>
   <br/>
   <a href="https://github.com/SvenTiigi/YouTubePlayerKit/actions/workflows/build_and_test.yml">
       <img src="https://github.com/SvenTiigi/YouTubePlayerKit/actions/workflows/build_and_test.yml/badge.svg" alt="Build and Test Status">
   </a>
   <a href="https://sventiigi.github.io/YouTubePlayerKit/documentation/youtubeplayerkit/">
       <img src="https://img.shields.io/badge/Documentation-DocC-blue" alt="Documentation">
   </a>
   <a href="https://twitter.com/SvenTiigi/">
      <img src="https://img.shields.io/badge/Twitter-@SvenTiigi-blue.svg?style=flat" alt="Twitter">
   </a>
    <a href="https://mastodon.world/@SvenTiigi">
      <img src="https://img.shields.io/badge/Mastodon-@SvenTiigi-8c8dff.svg?style=flat" alt="Mastodon">
   </a>
</p>

<img align="right" width="307" src="Assets/example-app.png" alt="Example application">

```swift
import SwiftUI
import YouTubePlayerKit

struct ContentView: View {

    var body: some View {
        //  WWDC 2019 Keynote
        YouTubePlayerView(
            "https://youtube.com/watch?v=psL_5RIBqnY"
        )
    }

}
```

## Features

- [x] Play YouTube videos with just one line of code 📺
- [x] YouTube [Terms of Service](https://developers.google.com/youtube/terms/api-services-terms-of-service) compliant implementation ✅
- [x] Access to all native YouTube iFrame [APIs](https://developers.google.com/youtube/iframe_api_reference) 👩‍💻👨‍💻
- [x] Support for SwiftUI, UIKit and AppKit 🧑‍🎨
- [x] Runs on iOS and macOS 📱 🖥
- [x] `async/await` support ⛓

## Example

Check out the example application to see YouTubePlayerKit in action. Simply open the `Example/Example.xcodeproj` and run the "Example" scheme.

## Installation

To integrate using Apple's [Swift Package Manager](https://swift.org/package-manager/), add the following as a dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/SvenTiigi/YouTubePlayerKit.git", from: "1.5.0")
]
```

Or navigate to your Xcode project then select `Swift Packages`, click the “+” icon and search for `YouTubePlayerKit`.

> [!NOTE]
> When integrating YouTubePlayerKit to a macOS or Mac Catalyst target please ensure to enable "Outgoing Connections (Client)" in the "Signing & Capabilities" sections.

## App Store Review

When submitting an app to the App Store which includes the `YouTubePlayerKit`, please ensure to add a link to the [YouTube API Terms of Services](https://developers.google.com/youtube/terms/api-services-terms-of-service) in the review notes.

> https://developers.google.com/youtube/terms/api-services-terms-of-service

## Limitations
- Audio background playback is not supported as it violates the YouTube Terms of Service.
- Simultaneous playback of multiple YouTube players is not supported.
- Controlling playback of [360° videos](https://developers.google.com/youtube/iframe_api_reference#Spherical_Video_Controls) is not supported on iOS and macOS.

## Usage

A YouTube player can be easily rendered when using `SwiftUI` by declaring a `YouTubePlayerView`.

```swift
import SwiftUI
import YouTubePlayerKit

struct ContentView: View {

    @StateObject
    var youTubePlayer: YouTubePlayer = "https://youtube.com/watch?v=psL_5RIBqnY"

    var body: some View {
        YouTubePlayerView(self.youTubePlayer) { state in
            // Overlay ViewBuilder closure to place an overlay View
            // for the current `YouTubePlayer.State`
            switch state {
            case .idle:
                ProgressView()
            case .ready:
                EmptyView()
            case .error(let error):
                Text(verbatim: "YouTube player couldn't be loaded")
            }
        }
    }

}
```

When using `UIKit` or `AppKit` you can make use of the `YouTubePlayerViewController` or `YouTubePlayerHostingView`.

```swift
import UIKit
import YouTubePlayerKit

// Initialize a YouTubePlayerViewController
let youTubePlayerViewController = YouTubePlayerViewController(
    player: "https://youtube.com/watch?v=psL_5RIBqnY"
)

// Example: Access the underlying iFrame API via the `YouTubePlayer` instance
youTubePlayerViewController.player.showStatsForNerds()

// Present YouTubePlayerViewController
self.present(youTubePlayerViewController, animated: true)
```

If you wish to change the video at runtime simply update the `source` of a `YouTubePlayer`.

```swift
youTubePlayer.source = .video(id: "0TD96VTf0Xs")
```

Additionally, you can update the `configuration` of a `YouTubePlayer` to update the current configuration.

```swift
youTubePlayer.configuration = .init(
    autoPlay: true
)
```
> [!NOTE]
> Updating the `YouTubePlayer.Configuration` will result in a reload of the YouTubePlayer.

Since `YouTubePlayer` is conform to the [`ObservableObject`](https://developer.apple.com/documentation/combine/observableobject) protocol you can listen for changes whenever the `source` or `configuration` of a `YouTubePlayer` gets updated.

```swift
youTubePlayer
    .objectWillChange
    .sink { }
```

## YouTubePlayer

A `YouTubePlayer` is the central object which needs to be passed to every `YouTubePlayerView`, `YouTubePlayerViewController` or `YouTubePlayerHostingView` in order to play a certain YouTube video and interact with the underlying YouTube iFrame API.

Therefore, you can easily initialize a `YouTubePlayer` by using a string literal as seen in the previous examples.

```swift
let youTubePlayer: YouTubePlayer = "https://youtube.com/watch?v=psL_5RIBqnY"
```

A `YouTubePlayer` generally consist of a `YouTubePlayer.Source` and a `YouTubePlayer.Configuration`.

```swift
let youTubePlayer = YouTubePlayer(
    source: .video(id: "psL_5RIBqnY"),
    configuration: .init(
        autoPlay: true
    )
)
```

### Source

The `YouTubePlayer.Source` is a simple enum which allows you to specify which YouTube source should be loaded.

```swift
// YouTubePlayer Video Source
let videoSource: YouTubePlayer.Source = .video(id: "psL_5RIBqnY")

// YouTubePlayer Playlist Source
let playlistSource: YouTubePlayer.Source = .playlist(id: "PLHFlHpPjgk72Si7r1kLGt1_aD3aJDu092")

// YouTubePlayer Channel Source
let channelSource: YouTubePlayer.Source = .channel(name: "iJustine")
```

Additionally, you can use a URL to initialize a `YouTubePlayer.Source`

```swift
let urlSource: YouTubePlayer.Source? = .url("https://youtube.com/watch?v=psL_5RIBqnY")
```

### Configuration

The `YouTubePlayer.Configuration` allows you to configure various [parameters](https://developers.google.com/youtube/player_parameters) of the underlying YouTube iFrame player.

```swift
let configuration = YouTubePlayer.Configuration(
    // Define which fullscreen mode should be used (system or web)
    fullscreenMode: .system,
    // Custom action to perform when a URL gets opened
    openURLAction: { url in
        // ...
    },
    // Enable auto play
    autoPlay: true,
    // Hide controls
    showControls: false,
    // Enable loop
    loopEnabled: true
)

let youTubePlayer = YouTubePlayer(
    source: .url("https://youtube.com/watch?v=psL_5RIBqnY"),
    configuration: configuration
)
```

> [!TIP]
> Check out the [`YouTubePlayer.Configuration`](https://github.com/SvenTiigi/YouTubePlayerKit/blob/main/Sources/Configuration/YouTubePlayer%2BConfiguration.swift) to get a list of all available parameters.

### API

Additionally, a `YouTubePlayer` allows you to access the underlying YouTube player iFrame API in order to play, pause, seek or retrieve information like the current playback quality or title of the video that is currently playing.

#### Async/Await

All asynchronous functions on a `YouTubePlayer` can be invoked by either supplying a completion closure or by using async/await.

```swift
// Async/Await: Retrieve the current PlaybackMetadata
let playbackMetadata = try await youTubePlayer.getPlaybackMetadata()

// Completion-Closure: Retrieve the current PlaybackMetadata
youTubePlayer.getPlaybackMetadata { result in
    switch result {
    case .success(let playbackMetadata):
        print(playbackMetadata)
    case .failure(let error):
        print(error)
    }
}
```

#### Playback controls and player settings

```swift
// Play video
youTubePlayer.play()

// Pause video
youTubePlayer.pause()

// Stop video
youTubePlayer.stop()

// Seek to 60 seconds
youTubePlayer.seek(to: 60, allowSeekAhead: false)

// Closes any current picture-in-picture video and fullscreen video
await youTubePlayer.closeAllMediaPresentations()
```

#### Events

```swift
// A Publisher that emits the current YouTubePlayer State
youTubePlayer.statePublisher

// A Publisher that emits the current YouTubePlayer PlaybackState
youTubePlayer.playbackStatePublisher

// A Publisher that emits the current YouTubePlayer PlaybackQuality
youTubePlayer.playbackQualityPublisher

// A Publisher that emits the current YouTubePlayer PlaybackRate
youTubePlayer.playbackRatePublisher
```

#### Playback status

```swift
// Retrieve a number between 0 and 1 that specifies the percentage of the video that the player shows as buffered
try await youTubePlayer.getVideoLoadedFraction()

// A Publisher that emits a number between 0 and 1 that specifies the percentage of the video that the player shows as buffered
youTubePlayer.videoLoadedFractionPublisher()

// Retrieve the PlaybackState of the player video
try await youTubePlayer.getPlaybackState()

// Retrieve the elapsed time in seconds since the video started playing
try await youTubePlayer.getCurrentTime()

/// A Publisher that emits the current elapsed time in seconds since the video started playing
youTubePlayer.currentTimePublisher()

// Retrieve the current PlaybackMetadata
try await youTubePlayer.getPlaybackMetadata()

// A Publisher that emits the current PlaybackMetadata
youTubePlayer.playbackMetadataPublisher
```

#### Load/Cue video

```swift
// Load a new video from source
youTubePlayer.load(source: .url("https://youtube.com/watch?v=psL_5RIBqnY"))

// Cue a video from source
youTubePlayer.cue(source: .url("https://youtube.com/watch?v=psL_5RIBqnY"))
```

#### Update Configuration

```swift
// Update the YouTubePlayer Configuration
youTubePlayer.update(
    configuration: .init(
        showControls: false
    )
)
```
> [!NOTE]
> Updating the `YouTubePlayer.Configuration` will result in a reload of the entire YouTubePlayer

#### Reload

```swift
// Reloads the player
youTubePlayer.reload()
```

#### Changing the player volume

```swift
// Mutes the player
youTubePlayer.mute()

// Unmutes the player
youTubePlayer.unmute()

// Retrieve Bool value if the player is muted
try await youTubePlayer.isMuted()

// Retrieve the player's current volume, an integer between 0 and 100
try await youTubePlayer.getVolume()
```

#### Retrieving video information

```swift
// Show Stats for Nerds which displays additional video information
youTubePlayer.showStatsForNerds()

// Hide Stats for Nerds
youTubePlayer.hideStatsForNerds()

// Retrieve the YouTubePlayer Information
try await youTubePlayer.getInformation()

// Retrieve the duration in seconds of the currently playing video
try await youTubePlayer.getDuration()

// A Publisher that emits the duration in seconds of the currently playing video
youTubePlayer.durationPublisher

// Retrieve the YouTube.com URL for the currently loaded/playing video
try await youTubePlayer.getVideoURL()

// Retrieve the embed code for the currently loaded/playing video
try await youTubePlayer.getVideoEmbedCode()
```

#### Playing a video in a playlist

```swift
// This function loads and plays the next video in the playlist
youTubePlayer.nextVideo()

// This function loads and plays the previous video in the playlist
youTubePlayer.previousVideo()

// This function loads and plays the specified video in the playlist
youTubePlayer.playVideo(at: 3)

// This function indicates whether the video player should continuously play a playlist
youTubePlayer.setLoop(enabled: true)

// This function indicates whether a playlist's videos should be shuffled
youTubePlayer.setShuffle(enabled: true)

// This function returns an array of the video IDs in the playlist as they are currently ordered
try await youTubePlayer.getPlaylist()

// This function returns the index of the playlist video that is currently playing
try await youTubePlayer.getPlaylistIndex()
```

#### Setting the playback rate

```swift
// This function retrieves the playback rate of the currently playing video
try await youTubePlayer.getPlaybackRate()

// This function sets the suggested playback rate for the current video
youTubePlayer.set(playbackRate: 1.5)

// This function returns the set of playback rates in which the current video is available
try await youTubePlayer.getAvailablePlaybackRates()
```

## Credits

- [youtube/youtube-ios-player-helper](https://github.com/youtube/youtube-ios-player-helper)
