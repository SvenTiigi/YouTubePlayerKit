<br/>

<p align="center">
    <img src="https://raw.githubusercontent.com/SvenTiigi/YouTubePlayerKit/gh-pages/readme-assets/logo.png?token=ACZQQFS3DO5PMLZUDKA3VT3BKHYS4" width="30%" alt="logo">
</p>

<h1 align="center">YouTubePlayerKit</h1>

<p align="center">
    A Swift Package to easily play YouTube videos on iOS
</p>

<p align="center">
   <a href="https://github.com/apple/swift-package-manager">
      <img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" alt="SPM">
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
            "https://www.youtube.com/watch?v=psL_5RIBqnY"
        )
    }
    
}
```

## Features

- [x] Play YouTube videos with just one line of code 📺
- [x] YouTube [Terms of Service](https://www.youtube.com/t/terms) compliant implementation ✅
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

`t.b.d`

## Advanced

`t.b.d`

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
