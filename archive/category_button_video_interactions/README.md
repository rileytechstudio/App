# Archived Feature: Home Screen Button Video Micro-Interactions

## Overview
This archive preserves the full, working implementation of the category card video micro-interaction mechanic on the Home screen.

When a user taps any of the 5 main category buttons (`Preparations`, `Glossary`, `Anatomy Explorer`, `Gallery`, `Games`):
1. The button springs up (`scale(1.045)`) with an elevated drop-shadow.
2. The button's embedded video overlay fades in and plays a 560ms snippet of its corresponding animation:
   - **Preparations**: Floating medical crosses.
   - **Glossary**: Drifting alphabet letters.
   - **Anatomy Explorer**: Rotating anatomical spine model.
   - **Gallery**: Vintage photo slides and corners.
   - **Games**: Scrolling clouds with pixel ground.
3. The app smoothly transitions to the destination screen or modal sheet.
4. VoiceOver and accessibility are fully respected:
   - `prefers-reduced-motion` in Web and `@Environment(\.accessibilityReduceMotion)` in iOS immediately skip animation with 0ms delay.
   - Videos are muted, non-blocking, and decorative (`aria-hidden="true"`, `.accessibilityHidden(true)`).
   - Instant skip on second tap.

---

## Preserved Files in this Archive
- `preview_index_with_video_micro_interactions.html`: Full working Web simulator containing the video elements, CSS overlays, and JS controller.
- `HomeComponents_with_video_micro_interactions.swift`: SwiftUI `CategoryCardButton` with `VideoOverlayView` and motion checks.
- `HomeScreenView_with_video_micro_interactions.swift`: SwiftUI Home screen passing video names to each card button.

The original video source files remain preserved in:
- `Preparations/Preparations Selected.mp4`
- `Preparations/Glossary Selected.mp4`
- `Preparations/Anatomy Explorer Selected.mp4`
- `Preparations/Gallery Selected.mp4`
- `Preparations/Games Selected.mp4`

---

## How to Restore / Re-Trial this Feature

### 1. Web Simulator & Distribution
Replace `preview/index.html` with the archived copy, then compile:
```bash
cp archive/category_button_video_interactions/preview_index_with_video_micro_interactions.html preview/index.html
python3 scripts/build.py
```

### 2. iOS SwiftUI
Replace the two source files:
```bash
cp archive/category_button_video_interactions/HomeComponents_with_video_micro_interactions.swift iOS/RileyApp/Sources/HomeComponents.swift
cp archive/category_button_video_interactions/HomeScreenView_with_video_micro_interactions.swift iOS/RileyApp/Sources/HomeScreenView.swift
```
Ensure video assets are present in `iOS/RileyApp/Resources/`:
```bash
cp preview/assets/*_Selected.mp4 iOS/RileyApp/Resources/
```
Verify with:
```bash
DEVELOPER_DIR=/Library/Developer/CommandLineTools swiftc -parse iOS/RileyApp/Sources/*.swift
```
