# ``YouTubePlayerKit``

A Swift Package to easily play YouTube videos.

## Overview

YouTubePlayerKit is [available on GitHub](https://github.com/SvenTiigi/YouTubePlayerKit).

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

- Play YouTube videos with just one line of code 📺
- YouTube [Terms of Service](https://developers.google.com/youtube/terms/api-services-terms-of-service) compliant implementation ✅
- Access to all native YouTube iFrame [APIs](https://developers.google.com/youtube/iframe_api_reference) 👩‍💻👨‍💻
- Support for SwiftUI, UIKit and AppKit 🧑‍🎨
- Runs on iOS, macOS and visionOS 📱 🖥 👓

> Important: 
> The following limitations apply:
> - Audio background playback is not supported,
> - Simultaneous playback of multiple YouTube players is not supported,
> - Controlling playback of 360° videos is not supported.

> Tip:
> See ``YouTubePlayer`` for a full overview of all available APIs. 

## Topics

### Creating a YouTubePlayer

- ``YouTubePlayer/init(source:parameters:configuration:isLoggingEnabled:)``
- ``YouTubePlayer/init(url:)``
- ``YouTubePlayer/init(urlString:)``

### Displaying a YouTubePlayer

- ``YouTubePlayerView``
- ``YouTubePlayerViewController``
- ``YouTubePlayerHostingView``

### Interacting with a YouTubePlayer

- ``YouTubePlayer/play()``
- ``YouTubePlayer/pause()``
- ``YouTubePlayer/stop()``
- ``YouTubePlayer/load(source:startTime:endTime:index:)``
- ``YouTubePlayer/cue(source:startTime:endTime:index:)``
