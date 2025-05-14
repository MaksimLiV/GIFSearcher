# GIFSearcher

GIFSearcher is a simple iOS app that lets users search and view GIFs using the Giphy API. It features a clean UI, real-time search, and infinite scrolling.

## Features

- Trending GIFs on launch  
- Real-time search  
- Infinite scroll  
- Full-screen GIF view  
- Share via iOS share sheet  
- Network connectivity monitoring  
- Error handling with user feedback

## Architecture

Built with MVVM:

- `Models` – data structures (GIF, GIFResponse)  
- `ViewModels` – business logic and state  
- `Views` – UI and view controllers  
- `Services` – networking layer using Giphy API  
- `Utils` – extensions and helpers

## Getting Started

**Requirements**  
- Xcode 14+  
- iOS 15+  
- Swift 5  
- CocoaPods

**Installation**

```bash
git clone https://github.com/yourusername/GIFSearcher.git
cd GIFSearcher
pod install
open GIFSearcher.xcworkspace
```

Add your Giphy API key in `SecretAPIKey.swift`:

```swift
struct SecretAPIKey {
    static let key = "YOUR_API_KEY"
}
```

Get an API key at [Giphy Developers](https://developers.giphy.com/)

## Dependencies

- Alamofire  
- Network framework

## Future Plans

- Favorites with Core Data  
- Categories and tags  
- Dark Mode  
- Stickers support  
- User login for personalization

## License

MIT

## Credits

- Giphy API  
- Alamofire
