# iOS 3D Model Viewer

A SwiftUI-based iOS application for viewing and interacting with 3D models in GLTF, OBJ, DAE, and SCN formats.

## Features

- **3D Model Loading**: Support for GLTF, OBJ, DAE, and SCN file formats
- **Interactive Controls**: 
  - Pan gestures for rotating the model around X and Y axes
  - Pinch gestures for zooming in and out
  - Rotation gestures for rotating around Z axis
- **Control Panel**: 
  - Reset button to return to original position
  - Auto-rotate toggle for continuous rotation
  - Wireframe toggle to switch between solid and wireframe rendering
- **Modern UI**: Clean SwiftUI interface with intuitive controls

## Project Structure

```
iOS3DViewer/
├── iOS3DViewerApp.swift          # Main app entry point
├── ContentView.swift             # Main view with file picker
├── ModelViewer.swift            # 3D scene viewer with gesture controls
├── ModelLoader.swift            # Handles loading of different 3D file formats
├── Info.plist                   # App configuration
└── Assets.xcassets/             # App icons and assets
```

## How to Use

1. **Open the app** and tap "Load 3D Model"
2. **Select a 3D file** from your device (GLTF, OBJ, DAE, or SCN format)
3. **Tap "View Model"** to open the 3D viewer
4. **Interact with the model**:
   - **Pan**: Drag to rotate the model
   - **Pinch**: Zoom in/out
   - **Rotate**: Use rotation gesture for Z-axis rotation
5. **Use controls**:
   - **Reset**: Return to original position
   - **Auto Rotate**: Toggle continuous rotation
   - **Wireframe**: Switch between solid and wireframe view

## Technical Details

### Supported File Formats
- **GLTF/GLB**: Industry standard for 3D models
- **OBJ**: Common 3D model format
- **DAE**: Collada format
- **SCN**: SceneKit native format

### Technologies Used
- **SwiftUI**: Modern iOS UI framework
- **SceneKit**: Apple's 3D graphics framework
- **ModelIO**: Apple's model loading framework
- **UIKit**: For gesture recognition and file picking

### Gesture Implementation
- **Pan Gesture**: Maps horizontal movement to Y-axis rotation, vertical to X-axis rotation
- **Pinch Gesture**: Controls camera distance for zoom effect
- **Rotation Gesture**: Provides Z-axis rotation control

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.0+

## Installation

1. Open `iOS3DViewer.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run the project (⌘+R)

## Adding Your 3D Models

To test with your own 3D models:

1. **Add files to the project**: Drag your GLTF/OBJ files into the Xcode project
2. **Update ModelLoader**: Modify the `loadModel` function in `ModelLoader.swift` to load from your specific file paths
3. **Or use the file picker**: The app includes a document picker to load files from your device

## Customization

### Lighting
Modify the lighting setup in `ModelLoader.swift`:
```swift
private func createDefaultScene() -> SCNScene {
    // Customize ambient and directional lighting here
}
```

### Gesture Sensitivity
Adjust gesture sensitivity in `ModelViewer.swift`:
```swift
let sensitivity: Float = 0.01 // Increase for more sensitive rotation
```

### Model Scaling
Modify the auto-scaling in `ModelLoader.swift`:
```swift
let scale = 2.0 / size // Adjust the scale factor
```

## Future Enhancements

- Support for more 3D file formats (FBX, 3DS, etc.)
- Material and texture editing
- Animation playback for animated models
- AR integration using ARKit
- Model sharing and export functionality

## License

This project is available for educational and personal use.

