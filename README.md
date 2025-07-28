# SJHeightScaleView

A customizable SwiftUI component for selecting height values with an intuitive scale interface.

## Features

- 📏 Interactive height selection with visual scale
- 🎨 Customizable appearance and range
- 📱 Support for iOS, macOS, watchOS, and tvOS
- 🔢 Multiple unit support (cm, inches, feet)
- ⚡ Smooth drag gestures and animations

## Installation

### Swift Package Manager

Add HeightScaleView to your project using Xcode:

1. Go to File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/subinspathilettu/SJHeightScaleView`
3. Click Add Package

Or add it to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/subinspathilettu/SJHeightScaleView", from: "1.0.0")
]
```

## Usage

### Basic Usage

```swift
import SwiftUI
import HeightScaleView

struct ContentView: View {
    @State private var selectedHeight: Double = 175.0
    
    var body: some View {
        HeightScaleView(
            selectedHeight: $selectedHeight,
            minHeight: 140,
            maxHeight: 220,
            unit: .centimeters
        )
    }
}
```

### Customization Options

```swift
HeightScaleView(
    selectedHeight: $height,
    minHeight: 100,          // Minimum height value
    maxHeight: 250,          // Maximum height value
    unit: .centimeters,      // Unit: .centimeters, .inches, or .feet
    tickInterval: 1.0        // Interval between tick marks
)
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `selectedHeight` | `Binding<Double>` | Required | The currently selected height value |
| `minHeight` | `Double` | `100` | Minimum selectable height |
| `maxHeight` | `Double` | `250` | Maximum selectable height |
| `unit` | `HeightUnit` | `.centimeters` | Unit of measurement |
| `tickInterval` | `Double` | `1` | Spacing between tick marks |

## Supported Units

- `.centimeters` (cm)
- `.inches` (in)
- `.feet` (ft)

## Requirements

- iOS 14.0+
- macOS 11.0+
- watchOS 7.0+
- tvOS 14.0+
- Swift 5.9+

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
