# Cineverse

A native iOS movie discovery app built with SwiftUI.

## Requirements

- iOS 18.5+
- Xcode 16+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)
- [SwiftLint](https://github.com/realm/SwiftLint) (optional, for linting)

## Setup

1. Install XcodeGen: `brew install xcodegen`
2. Generate project: `xcodegen generate`
3. Open in Xcode: `open Cineverse.xcodeproj`

## Building

```bash
# Using the build script (recommended)
bash build.sh

# Or manually with xcodebuild
xcodebuild -project Cineverse.xcodeproj -scheme Cineverse \
  -destination 'platform=iOS Simulator,name=iPhone 16' build
```

## Code Quality

This project uses SwiftLint to enforce code style.

```bash
# Install
brew install swiftlint

# Run linting
swiftlint lint
```

## License

MIT License - see [LICENSE](LICENSE) for details.
