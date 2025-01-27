<br/>

<p align="center">
    <img src="Assets/logo.png" width="30%" alt="logo">
</p>

<h1 align="center">
    YouTubePlayerKit
</h1>

<p align="center">
    A Swift Package to easily play YouTube videos.
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
- [x] Runs on iOS, macOS and visionOS 📱 🖥 👓

## Example

Check out the example application to see YouTubePlayerKit in action. Simply open the `Example/Example.xcodeproj` and run the "Example" scheme.

## Installation

To integrate using Apple's [Swift Package Manager](https://swift.org/package-manager/), add the following as a dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/SvenTiigi/YouTubePlayerKit.git", from: "2.0.0")
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
- Controlling playback of [360° videos](https://developers.google.com/youtube/iframe_api_reference#Spherical_Video_Controls) is not supported.

## Usage

A YouTube player can be easily rendered when using `SwiftUI` by declaring a `YouTubePlayerView`.

```swift
import SwiftUI
import YouTubePlayerKit

struct ContentView: View {

    let youTubePlayer: YouTubePlayer = "https://youtube.com/watch?v=psL_5RIBqnY"

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

When using `UIKit` or `AppKit` you can make use of the `YouTubePlayerViewController`

```swift
import UIKit
import YouTubePlayerKit

let youTubePlayerViewController = YouTubePlayerViewController(
    player: "https://youtube.com/watch?v=psL_5RIBqnY"
)

// Example: Access the underlying iFrame API via the `YouTubePlayer` instance
try await youTubePlayerViewController.player.showStatsForNerds()

self.present(youTubePlayerViewController, animated: true)
```

Or the `YouTubePlayerHostingView`

```swift
import UIKit
import YouTubePlayerKit

let youTubePlayerHostingView = YouTubePlayerHostingView(
    player: "https://youtube.com/watch?v=psL_5RIBqnY"
)

// Example: Access the underlying iFrame API via the `YouTubePlayer` instance
try await youTubePlayerHostingView.player.showStatsForNerds()

self.addSubview(youTubePlayerHostingView)
```

## YouTubePlayer

A `YouTubePlayer` is the central object which needs to be passed to a `YouTubePlayerView`, `YouTubePlayerViewController` or `YouTubePlayerHostingView` in order to play a certain YouTube video and interact with the underlying YouTube iFrame API.

Therefore, you can easily initialize a `YouTubePlayer` by using a string literal as seen in the previous examples.

```swift
let youTubePlayer: YouTubePlayer = "https://youtube.com/watch?v=psL_5RIBqnY"
```

A `YouTubePlayer` can be further initialized with a [`YouTubePlayer.Source`](https://github.com/SvenTiigi/YouTubePlayerKit/blob/main/Sources/Models/YouTubePlayer%2BSource.swift), [`YouTubePlayer.Parameters`](https://github.com/SvenTiigi/YouTubePlayerKit/blob/main/Sources/Models/YouTubePlayer%2BParameters.swift) and a [`YouTubePlayer.Configuration`](https://github.com/SvenTiigi/YouTubePlayerKit/blob/main/Sources/Models/YouTubePlayer%2BConfiguration.swift)

```swift
let youTubePlayer = YouTubePlayer(
    source: .video(id: "psL_5RIBqnY"),
    parameters: .init(
        autoPlay: true,
        showControls: true,
        loopEnabled: true,
        startTime: .init(value: 5, unit: .minutes),
        // ...
    ),
    configuration: .init(
        fullscreenMode: .system,
        allowsInlineMediaPlayback: true,
        customUserAgent: "MyCustomUserAgent",
        // ...
    )
)
```

You can update the `parameters` of a `YouTubePlayer` via:

```swift
youTubePlayer.parameters.showControls = false
```

> [!WARNING]
> Updating the `YouTubePlayer.Parameters` during runtime will cause the `YouTubePlayer` to reload.

### Source

The `YouTubePlayer.Source` is an enum which allows you to specify which YouTube source should be loaded.

```swift
// A single video
let video: YouTubePlayer.Source = .video(id: "psL_5RIBqnY")

// Series of videos
let videos: YouTubePlayer.Source = .videos(ids: ["w87fOAG8fjk", "RXeOiIDNNek", "psL_5RIBqnY"])

// Playlist
let playlist: YouTubePlayer.Source = .playlist(id: "PLHFlHpPjgk72Si7r1kLGt1_aD3aJDu092")

// Channel
let channel: YouTubePlayer.Source = .channel(name: "GoogleDevelopers")
```

You can also use a URL to initialize a `YouTubePlayer.Source`

```swift
let source: YouTubePlayer.Source? = .init(urlString: "https://youtube.com/watch?v=psL_5RIBqnY")
```

> [!NOTE]
> The URL parsing logic is designed to handle most known YouTube URL formats, but there may be some variations that it doesn't cover.

### Logging

To gain more insights into the underlying communication of the YouTube Player iFrame JavaScript API, you can enable logging by:

```swift
YouTubePlayer.isLoggingEnabled = true
```

The YouTubePlayerKit utilizes the [unified logging system (OSLog)](https://developer.apple.com/documentation/os/logging) to log information about the player options, JavaScript events and evaluations.

### API

A `YouTubePlayer` allows you to access the underlying YouTube player iFrame API in order to play, pause, seek or retrieve information like the current playback quality or title of the video that is currently playing.

#### Playback controls and player settings

```swift
// Play video
try await youTubePlayer.play()

// Pause video
try await youTubePlayer.pause()

// Stop video
try await youTubePlayer.stop()

// Seek to 60 seconds
try await youTubePlayer.seek(to: .init(value: 1, unit: .minutes), allowSeekAhead: false)

// Closes any current picture-in-picture video and fullscreen video
await youTubePlayer.closeAllMediaPresentations()

// Requests web fullscreen mode, applicable only if `configuration.fullscreenMode` is set to `.web`.
await youTubePlayer.requestWebFullscreen()
```

#### Events

```swift
// A Publisher that emits the current YouTubePlayer Source
youTubePlayer.sourcePublisher

// A Publisher that emits the current YouTubePlayer State
youTubePlayer.statePublisher

// A Publisher that emits the current YouTubePlayer PlaybackState
youTubePlayer.playbackStatePublisher

// A Publisher that emits the current YouTubePlayer PlaybackQuality
youTubePlayer.playbackQualityPublisher

// A Publisher that emits the current YouTubePlayer PlaybackRate
youTubePlayer.playbackRatePublisher

// A Publisher that emits whenever autoplay or scripted video playback features were blocked.
youTubePlayer.autoplayBlockedPublisher
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
try await youTubePlayer.load(source: .video(id: "psL_5RIBqnY"))

// Cue a video from source
try await youTubePlayer.cue(source: .channel(name: "GoogleDevelopers"))
```

#### Reload

```swift
// Reloads the player
try await youTubePlayer.reload()
```

#### Changing the player volume

```swift
// Mutes the player
try await youTubePlayer.mute()

// Unmutes the player
try await youTubePlayer.unmute()

// Retrieve Bool value if the player is muted
try await youTubePlayer.isMuted()

// Retrieve the player's current volume, an integer between 0 and 100
try await youTubePlayer.getVolume()
```

#### Retrieving video information

```swift
// Show Stats for Nerds which displays additional video information
try await youTubePlayer.showStatsForNerds()

// Hide Stats for Nerds
try await youTubePlayer.hideStatsForNerds()

// Returns a Boolean indicating whether Stats for Nerds is currently displayed.
try await youTubePlayer.isStatsForNerdsVisible()

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
try await youTubePlayer.nextVideo()

// This function loads and plays the previous video in the playlist
try await youTubePlayer.previousVideo()

// This function loads and plays the specified video in the playlist
try await youTubePlayer.playVideo(at: 3)

// This function indicates whether the video player should continuously play a playlist
try await youTubePlayer.setLoop(enabled: true)

// This function indicates whether a playlist's videos should be shuffled
try await youTubePlayer.setShuffle(enabled: true)

// This function returns an array of the video IDs in the playlist as they are currently ordered
try await youTubePlayer.getPlaylist()

// This function returns the index of the playlist video that is currently playing
try await youTubePlayer.getPlaylistIndex()

// This function returns the identifier of the playlist video that is currently playing.
try await youTubePlayer.getPlaylistID()
```

#### Setting the playback rate

```swift
// This function retrieves the playback rate of the currently playing video
try await youTubePlayer.getPlaybackRate()

// This function sets the suggested playback rate for the current video
try await youTubePlayer.set(playbackRate: 1.5)

// This function returns the set of playback rates in which the current video is available
try await youTubePlayer.getAvailablePlaybackRates()
```

## Video Thumbnail

You can load a YouTube video thumbnail via the `YouTubeVideoThumbnail` object.

```swift
// Initialize an instance of YouTubeVideoThumbnail
let videoThumbnail = YouTubeVideoThumbnail(
    videoID: "psL_5RIBqnY",
    // Choose between default, medium, high, standard, maximum
    resolution: .high
)

// Retrieve the URL, if available
let url: URL? = videoThumbnail.url

// Retrieve the image, if available.
let image: YouTubeVideoThumbnail.Image? = try await videoThumbnail.image()
```

Additionally, the `YouTubePlayer` allows you to easily retrieve the thumbnail url and image for the currently loaded video.

```swift
// Returns the video thumbnail URL of the currently loaded video
try await youTubePlayer.getVideoThumbnailURL()

/// Returns the video thumbnail of the currently loaded video
try await youTubePlayer.getVideoThumbnailImage(resolution: .maximum)
```

## Credits

- [youtube/youtube-ios-player-helper](https://github.com/youtube/youtube-ios-player-helper)
