# SwiftUI Animation Playground

A macOS app for exploring, comparing, and learning SwiftUI animations interactively. Perfect for developers who want to understand how different animation curves behave and find the right parameters for their apps.

## Features

### Playground Mode
Experiment with SwiftUI animations in real-time:
- **9 Animation Types**: `.spring`, `.smooth`, `.snappy`, `.bouncy`, `.easeIn`, `.easeOut`, `.easeInOut`, `.linear`, and `.interpolatingSpring`
- **Interactive Parameters**: Adjust duration, bounce, stiffness, damping, and other parameters with immediate visual feedback
- **Multiple Shapes**: Test animations on circles and rounded rectangles
- **Live Code Preview**: See the exact SwiftUI code for your current animation settings

### Compare Mode
Compare up to three animation curves side-by-side:
- **Triple Animation Display**: Run up to three different animations simultaneously
- **Stacked or Side-by-Side**: Toggle between layout modes
- **Synchronized Playback**: All animations play together for easy comparison

### Examples
Real-world animation patterns with interactive, editable code:

| Example | Description |
|---------|-------------|
| **Toggle Switch** | Classic iOS-style toggle with spring animation |
| **Floating Action Button** | Expanding menu with staggered spring animations |
| **Drag & Release** | Physics-based spring return using `interpolatingSpring` |
| **Heart Reaction** | Two-stage animation (pop + settle) demonstrating concatenated animations |
| **Pull to Refresh** | Gesture-driven spring animation |

Each example features:
- **Interactive Code Editor**: Tap animation types and parameter values to modify them directly
- **Live Preview**: Changes apply instantly to the animation
- **Copy-Paste Code**: Get simplified, ready-to-use SwiftUI code for your own projects

## Requirements

- macOS 15.0+
- Xcode 16.0+

## Installation

### Download
Prebuilt binaries are available in the [Releases](../../releases) section.

### Build from Source
1. Clone the repository
2. Open `AnimationDemo.xcodeproj` in Xcode
3. Build and run (⌘R)

## License

MIT License - feel free to use this for learning and reference.
