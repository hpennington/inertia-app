# Inertia Animation Library

Welcome to Inertia, an intuitive animation library designed for SwiftUI, Jetpack Compose, and React.  
Inertia revolutionizes the workflow for designers and developers by offering a keyframe editor to define animations.  

Unlike other libraries, Inertia allows you to seamlessly incorporate native UI components in each platform and leverage native animation systems:
- SwiftUI → powered by iOS 17 keyframe animations
- Jetpack Compose → integrates directly with Compose's animation APIs
- React → hooks and components for smooth keyframe-driven animations

## Table of Contents
- [Features](#features)
- [Installation](#installation)
  - [SwiftUI](#swiftui)
  - [Jetpack Compose](#jetpack-compose)
  - [React](#react)
- [Usage](#usage)
  - [Defining Animation IDs](#defining-animation-ids)
  - [Applying Animations](#applying-animations)
  - [Controlling Animations](#controlling-animations)
  - [Adding the Animation Container](#adding-the-animation-container)
- [Sample Code (SwiftUI Example)](#sample-code-swiftui-example)
- [Example Animation File](#example-animation-file)

## Features

- Cross-platform: SwiftUI, Jetpack Compose, React
- Keyframe editor that exports JSON animation files
- Strongly typed animation IDs
- Full control over triggering, cancelling, and restarting animations
- Minimal boilerplate integration

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

### Defining Animation IDs (SwiftUI)
```swift
enum AnimationID: InertiaID {
    case car, planeTop, planeBottom, homeCard, bird
}
```

### Applying Animations (SwiftUI)
```swift
Image(systemName: "bird")
    .resizable()
    .renderingMode(.template)
    .frame(width: 48, height: 48)
    .foregroundColor(.green)
    .inertiaable(.bird)
```

### Controlling Animations (SwiftUI)
```swift
@EnvironmentObject var inertiaVM: InertiaViewModel

func triggerAnimation(_ id: AnimationID) {
    inertiaVM.trigger(id.rawValue)
}
```

### Adding the Animation Container (SwiftUI)
```swift
var body: some Scene {
    WindowGroup {
        ContentView()
            .inertiaContainer(id: "animation2", editor: false)
    }
}
```

## Sample Code (SwiftUI Example)

```swift
import SwiftUI
import Inertia

enum AnimationID: InertiaID {
    case car, planeTop, planeBottom, homeCard, bird
}

struct ContentView: View {
    @EnvironmentObject var inertiaVM: InertiaViewModel
    
    func toggleAnimation(_ id: AnimationID) {
        if let state = inertiaVM.getState(id.rawValue) {
            if state.isCancelled {
                inertiaVM.restart(id.rawValue)
            } else {
                inertiaVM.cancel(id.rawValue)
            }
        }
    }
    
    func triggerAnimation(_ id: AnimationID) {
        inertiaVM.trigger(id.rawValue)
    }
    
    var body: some View {
        VStack {
            Image(systemName: "bird")
                .resizable()
                .renderingMode(.template)
                .frame(width: 48, height: 48)
                .foregroundColor(.green)
                .inertiaable(.bird)

            HomeCardView {
                toggleAnimation(.homeCard)
            }
            .padding()
            .inertiaable(.homeCard)

            PlaneButtonView {
                toggleAnimation(.planeTop)
            }
            .inertiaable(.planeTop)
            .padding()
            
            CarButtonView {
                triggerAnimation(.car)
            }
            .inertiaable(.car)
            .padding()

            PlaneButtonView {
                toggleAnimation(.planeBottom)
            }
            .inertiaable(.planeBottom)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension View {
    func inertiaable(_ id: AnimationID) -> some View {
        self.inertiaable(id: id.rawValue)
    }
}

#Preview {
    ContentView()
}

@main
struct ProjectAnimationBuddyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .inertiaContainer(id: "animation2", editor: false)
        }
    }
}
```

## Example Animation File

```json
{
  "id": "animation2",
  "objects": [
    {
      "id": "triangle1",
      "width": 400,
      "height": 400,
      "position": [-0.35, 0.1],
      "color": [0.3, 0.5, 1.0, 0.75],
      "shape": "triangle",
      "objectType": "shape",
      "zIndex": 0,
      "animation": {
        "id": "triangle1",
        "initialValues": {
          "opacity": 1.0,
          "rotate": 0.0,
          "rotateCenter": 0.0,
          "scale": 1.0,
          "translate": [0.0, 0.0]
        },
        "invokeType": "auto",
        "keyframes": [
          { "id": "1", "duration": 1, "values": { "scale": 0.25, "translate": [0.0, 0.0], "rotate": 0.0, "rotateCenter": 45.0, "opacity": 1.0 } },
          { "id": "2", "duration": 1, "values": { "scale": 0.5, "translate": [0.0, 0.0], "rotate": 0.0, "rotateCenter": 90.0, "opacity": 1.0 } },
          { "id": "3", "duration": 1, "values": { "scale": 0.75, "translate": [0.0, 0.0], "rotate": 90, "rotateCenter": 180.0, "opacity": 1.0 } },
          { "id": "4", "duration": 1, "values": { "scale": 1.0, "translate": [0.0, 0.0], "rotate": 180.0, "rotateCenter": 360.0, "opacity": 1.0 } }
        ]
      }
    }
  ]
}
```

## Roadmap

- [x] SwiftUI support
- [x] Jetpack Compose support
- [x] React support
- [ ] Flutter (planned)
- [ ] Unity (planned)

---

**With Inertia, you can design once and animate everywhere — across iOS, Android, and Web.**