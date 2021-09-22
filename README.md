<br/>

<p align="center">
    <img src="https://raw.githubusercontent.com/SvenTiigi/YouTubePlayerKit/gh-pages/readme-assets/logo.png?token=ACZQQFS3DO5PMLZUDKA3VT3BKHYS4" width="30%" alt="logo">
</p>

<h1 align="center">YouTubePlayerKit</h1>

<p align="center">
    A Swift Package to easily play YouTube videos
</p>

<p align="center">
   <img src="https://img.shields.io/badge/platform-iOS%20%7C%20macOS-lightgrey" alt="Platform">
   <a href="https://sventiigi.github.io/YouTubePlayerKit">
      <img src="https://github.com/SvenTiigi/YouTubePlayerKit/blob/gh-pages/badge.svg" alt="Documentation">
   </a>
   <a href="https://twitter.com/SvenTiigi/">
      <img src="https://img.shields.io/badge/Twitter-@SvenTiigi-blue.svg?style=flat" alt="Twitter">
   </a>
</p>

<img align="right" width="307" src="https://raw.githubusercontent.com/SvenTiigi/YouTubePlayerKit/gh-pages/readme-assets/example-app.png?token=ACZQQFQCQOW4BAQ5BX3Q4Q3BKLRI2" alt="Example application">

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
- [x] YouTube [Terms of Service](https://youtube.com/t/terms) compliant implementation ✅
- [x] Access to all native YouTube iFrame [APIs](https://developers.google.com/youtube/iframe_api_reference) 👩‍💻👨‍💻
- [x] Support for SwiftUI and UIKit 📱

## Example

Check out the example application to see `YouTubePlayerKit` in action. Simply open the `Example/Example.xcodeproj` and run the `Example` scheme.

## Installation

### Swift Package Manager

To integrate using Apple's [Swift Package Manager](https://swift.org/package-manager/), add the following as a dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/SvenTiigi/YouTubePlayerKit.git", from: "1.0.0")
]
```

Or navigate to your Xcode project then select `Swift Packages`, click the “+” icon and search for `YouTubePlayerKit`.

## Usage

A YouTube player can be easily rendered when using `SwiftUI` by declaring a `YouTubePlayerView`.

```swift
import SwiftUI
import YouTubePlayerKit

struct ContentView: View {

    var body: some View {
        // YouTubePlayerView with overlay view builder
        // which takes in a `YouTubePlayer.State`
        YouTubePlayerView(
            "https://youtube.com/watch?v=psL_5RIBqnY"
        ) { state in
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
> Check out the various `YouTubePlayerView` initializer to place an overlay for a given state.

When using `UIKit` you can make use of the `YouTubePlayerViewController`.

```swift
import UIKit
import YouTubePlayerKit

// Initialize a YouTubePlayerViewController
let youTubePlayerViewController = YouTubePlayerViewController(
    player: "https://youtube.com/watch?v=psL_5RIBqnY"
)

// Optional: Use the `YouTubePlayer` to access the underlying iFrame API
youTubePlayerViewController
    .player
    .playbackQualityPublisher
    .sink { playbackQuality in
        // Print playback quality changes
        print(
            "Playback quality changed to", 
            playbackQuality
        ) 
    }
    .store(in: &cancellables)

// Present YouTubePlayerViewController
self.present(youTubePlayerViewController, animated: true)
```

## YouTubePlayer

A `YouTubePlayer` is the central object which needs to be passed to every YouTubePlayerView or YouTubePlayerViewController in order to play a certain YouTube video and interact with the underlying YouTube iFrame API. 

Therefore, you can easily initialize a `YouTubePlayer` by using a string literal as seen in the previous examples.

```swift
let youTubePlayer: YouTubePlayer = "https://youtube.com/watch?v=psL_5RIBqnY"
```

A `YouTubePlayer` consist of two parts a `YouTubePlayer.Source` and a `YouTubePlayer.Configuration`.

```swift
let youTubePlayer = YouTubePlayer(
    source: .video(
        id: "psL_5RIBqnY"
    ),
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
// Watch URL
let watchURLSource: YouTubePlayer.Source? = .url("https://youtube.com/watch?v=psL_5RIBqnY")

// Share URL
let sharedURLSource: YouTubePlayer.Source? = .url("https://youtu.be/psL_5RIBqnY")

// Embed URL
let embedURLSource: YouTubePlayer.Source? = .url("https://youtube.com/embed/psL_5RIBqnY")

// Channel URL
let channelURLSource: YouTubePlayer.Source? = .url("https://youtube.com/c/iJustine")
```
> When using a URL the `YouTubePlayer.Source` will be optional

### Configuration

The `YouTubePlayer.Configuration` allows you to configure various [parameters](https://developers.google.com/youtube/player_parameters) of the underlying YouTube iFrame player.

```swift
let configuration = YouTubePlayer.Configuration(
    // Disable user interaction
    isUserInteractionEnabled: false,
    // Enable auto play
    autoPlay: true,
    // Disable controls
    controls: false,
    // Enable loop
    loop: true
)

let youTubePlayer = YouTubePlayer(
    source: "https://youtube.com/watch?v=psL_5RIBqnY",
    configuration: configuration
)
```
> Check out the `YouTubePlayer.Configuration` to get a list of all available parameters.

## YouTubePlayerAPI

A `YouTubePlayer` instance offers various properties and functions to access the underlying YouTube player iFrame API like accessing the current playback quality, play, pause, seek, etc...

```swift
let youTubePlayer: YouTubePlayer = "https://youtube.com/watch?v=psL_5RIBqnY"

// Play video
youTubePlayer.play()

// Pause video
youTubePlayer.pause()

// Retrieve the duration
youTubePlayer.getDuration { result in
    print("Duration", result)
}

// Load a new Video
youTubePlayer.load(
    source: .video(id: "0TD96VTf0Xs")
)

// ...
```
> Check out the `YouTubePlayerAPI` protocol to get a list of all available functions and properties.

When using `SwiftUI` simply store the `YouTubePlayer` on your View.

```swift
import SwiftUI
import YouTubePlayerKit

struct ContentView: View {
    
    let youTubePlayer: YouTubePlayer = .init(
        source: .video(id: "0TD96VTf0Xs")
    )
    
    var body: some View {
        VStack {
            YouTubePlayerView(
                self.youTubePlayer
            )
            .frame(height: 200)
            Button(
                action: self.youTubePlayer.play,
                label: {
                    Text("Play")
                }
            )
        }
    }
    
}
```

## Credits
- [youtube/youtube-ios-player-helper](https://github.com/youtube/youtube-ios-player-helper)

## License

```
YouTubePlayerKit
Copyright (c) 2021 Sven Tiigi sven.tiigi@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
