# Atlys

# SwiftUI Carousel Component

A customizable, interactive carousel component for SwiftUI that features smooth animations, item scaling, and intuitive touch gestures.

## Features

- Smooth horizontal scrolling with spring animations
- Visual feedback with scaling and z-index effects
- Center item appears larger and in front of other items
- Velocity-based scrolling for natural interaction
- Page indicator showing current position
- Highly customizable through parameters
- Generic implementation for use with any content type

## Installation

Simply copy the following files into your SwiftUI project:

- `CarouselView.swift` - The main carousel component
- `PageIndicatorView.swift` - A page indicator component

## Usage

### Basic Example

```swift
import SwiftUI

struct ContentView: View {
    // Define your data model
    struct CarouselItem: Identifiable {
        let id = UUID()
        let imageName: String
    }
    
    // Sample data
    let carouselItems = [
        CarouselItem(imageName: "img1"),
        CarouselItem(imageName: "img2"),
        CarouselItem(imageName: "img3")
    ]
    
    var body: some View {
        CarouselView(items: carouselItems) { item in
            Image(item.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(height: 250)
    }
}
```

### Customization

The carousel component provides several customization options:

```swift
CarouselView(
    items: myItems,                  // Your data items (must conform to Identifiable)
    itemAspectRatio: 1.5,            // Width-to-height ratio (default: 1.0)
    maxScaleFactor: 1.3,             // Maximum scale for centered item (default: 1.2)
    minScaleFactor: 0.9              // Minimum scale for edge items (default: 1.0)
) { item in
    // Your custom view for each item
    MyItemView(item: item)
}
```

## Component Structure

### CarouselView

The main carousel component that handles:
- Item layout and positioning
- Scaling and z-index effects
- Touch gestures and animations
- Current item tracking

### PageIndicatorView

A simple dot indicator that shows:
- Total number of items in the carousel
- Currently selected item position

## Implementation Details

The carousel uses a mathematically-driven approach to calculate:

1. **Scale Factor** - Items are scaled based on their distance from the center using linear interpolation between the minimum and maximum scale factors.

2. **Z-Index** - Items are layered based on their proximity to the center, with centered items appearing on top.

3. **Position Calculation** - When a drag gesture ends, the carousel calculates the closest item position and smoothly animates to center that item.

## Requirements

- iOS 14.0+
- Swift 5.3+
- SwiftUI 2.0+

## License

This component is available under the MIT license.
