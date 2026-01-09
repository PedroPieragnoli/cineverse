# Cineverse

A native iOS movie discovery app built with SwiftUI, featuring pixel-perfect UI and TMDB integration.

## Features

- Movie discovery with TMDB API
- Dark mode optimized design
- Modern SwiftUI patterns
- MVVM architecture

## Requirements

- iOS 18.5+
- Xcode 16+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)
- [SwiftLint](https://github.com/realm/SwiftLint) (optional)

## Setup

```bash
# Install dependencies
brew install xcodegen swiftlint

# Generate project
xcodegen generate

# Open in Xcode
open Cineverse.xcodeproj
```

## Building

```bash
# Using build script (recommended)
bash build.sh

# Manual build
xcodebuild -project Cineverse.xcodeproj -scheme Cineverse \
  -destination 'platform=iOS Simulator,name=iPhone 16' build
```

## Testing

```bash
# Run all tests
xcodebuild test -project Cineverse.xcodeproj -scheme Cineverse \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# Unit tests only
xcodebuild test -project Cineverse.xcodeproj -scheme Cineverse \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:CineverseTests
```

## Project Structure

```
Cineverse/
├── Features/
│   └── Home/
│       └── Models/         # Movie domain models
├── Shared/
│   ├── Extensions/         # Swift extensions
│   └── Utils/              # Utilities (TMDB config, etc.)
└── Assets.xcassets/        # Images and colors
```

## Architecture

The project follows MVVM with feature-based organization:

- **Features/**: Self-contained feature modules
- **Shared/**: Code shared across features
- **Models**: Codable structs for API data
- **ViewModels**: State management with @Observable

## Code Quality

SwiftLint runs automatically during builds. Manual linting:

```bash
swiftlint lint
swiftlint lint --strict
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Author

Pedro Pieragnoli
