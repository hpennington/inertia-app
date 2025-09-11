# Inertia Animation Library

## Overview
An editor application and library for creating in-app, native, keyframe animations with a WYSIWYG (what you see is what you get) editor.

## Demo Video


https://github.com/user-attachments/assets/b3251bed-75bd-4967-a8c7-8927c85d3f48


## Intro

Welcome to Inertia, a cross-platform animation library for SwiftUI, Jetpack Compose, and React.

Inertia bridges designers and developers with a keyframe editor that exports animation files, which integrate directly into your native UI code.

Unlike other libraries, Inertia lets you animate real UI components on each platform while leveraging native animation engines:
- SwiftUI → built on iOS 17+ keyframe animations
- Jetpack Compose → powered by Compose's animation APIs
- React → hooks and components for smooth keyframe-driven animations

## Features

🌍 Cross-platform: SwiftUI, Jetpack Compose, React  
🎨 Keyframe editor with JSON export  
🔐 Strongly typed IDs for safe animation references  
🎛️ Control lifecycle: trigger, cancel, restart  
⚡ Minimal boilerplate  
🎯 Editor mode for live design and testing  

## Installation

### SwiftUI (iOS)

```swift
import Inertia
```

### Jetpack Compose (Android)

```kotlin
implementation("com.inertia:inertia-compose:<version>")
```

### React (Web)

```bash
npm install inertia-animations
# or
yarn add inertia-animations
```

## Usage

### 1. Define Animation IDs (SwiftUI)

Animation IDs can be simple strings:

```swift
// Simple string approach
let birdAnimationId = "bird"
let carAnimationId = "car"

// Or use enum for better organization (optional)
enum AnimationID: String, CaseIterable {
    case car, planeTop, planeBottom, homeCard, bird
}
```

### 2. Set Up the Animation Container

Wrap your app's root view in an InertiaContainer. The container loads animations and provides the animation context to child views.

```swift
import SwiftUI
import Inertia

struct AppEnvironment {
    #if INERTIA_EDITOR
    static let isInertiaEditor = true
    #else
    static let isInertiaEditor = false
    #endif
}

@main
struct InertiaDemoApp: App {
    var body: some Scene {
        WindowGroup {
            InertiaContainer(
                dev: AppEnvironment.isInertiaEditor, // enables editor mode when compiled with INERTIA_EDITOR
                id: "animation",                     // animation bundle id (matches JSON filename)
                hierarchyId: "animation2"            // unique hierarchy identifier
            ) {
                ContentView()
            }
        }
    }
}
```

### 3. Apply Animations to Views

Use the `.inertia()` modifier to make any view animatable:

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "bird")
                .resizable()
                .frame(width: 48, height: 48)
                .foregroundStyle(.green)
                .inertia("bird")  // Apply animation with string ID

            Button("Fly Away") {
                // Animation triggers are handled through the JSON configuration
            }
            .inertia("flyButton")
        }
        .padding()
    }
}
```

### 4. Animation Control (Optional)

For programmatic control, access the InertiaViewModel through the environment:

```swift
struct ContentView: View {
    @EnvironmentObject private var inertia: InertiaViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "bird")
                .inertia("bird")
            
            Button("Trigger Animation") {
                trigger("bird")
            }
        }
    }
    
    private func trigger(_ id: String) {
        inertia.trigger(id)
    }
    
    private func toggle(_ id: String) {
        if inertia.isCancelled(id) {
            inertia.restart(id)
        } else {
            inertia.cancel(id)
        }
    }
}
```

## Animation File Structure

Create a JSON file (e.g., animation.json) in your app bundle:

```json
{
  "id": "animation",
  "objects": [
    {
      "id": "bird",
      "containerId": "animation",
      "width": 48,
      "height": 48,
      "position": {"x": 0, "y": 0},
      "color": [0.3, 0.5, 1.0, 0.75],
      "shape": "triangle",
      "objectType": "animation",
      "zIndex": 1,
      "animation": {
        "id": "bird",
        "initialValues": {
          "scale": 1.0,
          "translate": {"width": 0.0, "height": 0.0},
          "rotate": 0.0,
          "rotateCenter": 0.0,
          "opacity": 1.0
        },
        "invokeType": "auto",
        "keyframes": [
          {
            "id": "keyframe1",
            "values": {
              "scale": 0.5,
              "translate": {"width": 0.2, "height": -0.1},
              "rotate": 0.0,
              "rotateCenter": 45.0,
              "opacity": 1.0
            },
            "duration": 1.0
          },
          {
            "id": "keyframe2", 
            "values": {
              "scale": 1.2,
              "translate": {"width": -0.3, "height": 0.2},
              "rotate": 0.0,
              "rotateCenter": 90.0,
              "opacity": 0.8
            },
            "duration": 1.5
          }
        ]
      }
    }
  ]
}
```

## Animation Properties

- `scale`: Scale factor (1.0 = normal size)
- `translate`: Position offset as percentage of container size
- `rotate`: Rotation from top-left anchor (degrees)
- `rotateCenter`: Rotation from center anchor (degrees)
- `opacity`: Transparency (0.0 = invisible, 1.0 = opaque)
- `duration`: Keyframe duration in seconds

## Invoke Types

- `"auto"`: Animation starts automatically when view appears
- `"trigger"`: Animation waits for programmatic trigger

## Editor Mode

Enable editor mode during development by:

1. Adding INERTIA_EDITOR build flag
2. Setting `dev: true` in InertiaContainer
3. Running your app - you'll see:
   - Selection borders around animatable views
   - Live editing capabilities
   - Real-time animation preview

The editor connects via WebSocket to design tools for live collaboration.

## Complete Example

```swift
import SwiftUI
import Inertia

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Animated bird that flies automatically
            Image(systemName: "bird")
                .resizable()
                .frame(width: 48, height: 48)
                .foregroundStyle(.green)
                .inertia("bird")

            // Animated card with manual trigger
            RoundedRectangle(cornerRadius: 12)
                .fill(.blue)
                .frame(width: 200, height: 120)
                .overlay {
                    Text("Home Card")
                        .foregroundStyle(.white)
                }
                .inertia("homeCard")
                .onTapGesture {
                    // Trigger handled by animation configuration
                }

            // Multiple planes with individual animations
            HStack {
                Image(systemName: "airplane")
                    .inertia("planeTop")
                    
                Image(systemName: "airplane")
                    .inertia("planeBottom")
            }
            .font(.largeTitle)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@main 
struct InertiaDemoApp: App {
    var body: some Scene {
        WindowGroup {
            InertiaContainer(
                dev: false,  // Set to true for editor mode
                id: "animation",
                hierarchyId: "mainContainer"
            ) {
                ContentView()
            }
        }
    }
}
```

## Key Differences from Other Animation Libraries

- **Design-First**: Animations are defined in JSON, enabling designer-developer collaboration
- **Cross-Platform**: Same animation files work across SwiftUI, Compose, and React
- **Native Performance**: Uses each platform's native animation engines
- **Live Editing**: Editor mode enables real-time animation tweaking
- **Minimal Code**: Apply animations with a single modifier

## Roadmap

✅ SwiftUI support  
✅ Jetpack Compose support  
✅ React support  

---

*Inertia Team • 2025*