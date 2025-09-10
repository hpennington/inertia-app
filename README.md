# Inertia

## Overview
An editor application and library for creating in-app, native, keyframe animations with a WYSIWYG (what you see is what you get) editor.

## Demo Video
![Screen Recording 2025-09-09 at 7 18 23 PM](https://github.com/user-attachments/assets/c4c2c9cf-efae-4df7-8934-4c06c1176ce1)


## Problem statement
As a mobile engineer, I want a workflow for creating in-app animations, 
from the ease of an animation WYSIWYG editor. This editor should export a file format suitable for describing a keyframe animation system, 
that applies to both: Components written in code, and components drawn from the editor. The file format also describes the component shape, 
and color, etc of the latter component types (those drawn from within the editor and not from within the codebase). 
There should also be a runtime for both iOS (SwiftUI), Android (Jetpack Compose), and Web (React), it should load the drawings and animation descriptions, 
and handle interactions from the codebase as well.

#### Goals
- Platforms: SwiftUI, React, Compose
- Support the subset of animations provided by both SwiftUI’s keyframe animations system (iOS 17+), and the WebAnimations API (unknown version but currently is supported)
- Supports trigger options: trigger, reverse, cancel
- Supports config options: loop, return
- Supports Keyframe animations
- Local compilation / serving

#### Non Goals
- Supporting spring animations
- Remote compilation / serving
- Specification export
