# Riley Hospital for Children - iOS App (Home & Preparations Screens)

A responsive, rotation-aware SwiftUI application built for **Riley Hospital for Children at Indiana University Health**.

Designed to scale across all iOS devices (iPad Pro, iPad Air, iPad mini, iPhone 16 Pro Max, iPhone 16, iPhone SE) and orientations (Landscape & Portrait).

---

## 📱 Screens Included

### 1. Home Screen
- **Top Header**: Riley Hospital doodle logo banner with circular `Settings` and `Home` navigation buttons.
- **Main Category Buttons (5 Cards, 2.24:1 Aspect Ratio)**:
  - **Row 1**: `Preparations`, `Glossary`, `Anatomy Explorer`
  - **Row 2**: `Gallery`, `Games` (centered horizontally)
- **Footer Buttons (2 Pills, 3.44:1 Aspect Ratio)**:
  - **Row 3**: `About` and `Legal` (lowered halfway toward the bottom edge)
- **Background**: Canva purple canvas with subtle gradient depth.

### 2. Preparations Screen
- **Top Header**:
  - `Back Button` (`IconBack`) to return to Home.
  - Riley Hospital doodle logo banner.
  - `Settings` and `Home` action buttons.
- **Search Bar**:
  - Live filtering search bar with magnifying glass and microphone icons.
- **Top Ribbon**:
  - Interactive `PROCEDURES` and `EDUCATION` segmented bar (`RibbonProceduresSelected` / `RibbonEducationSelected`).
- **Scrollable Procedures List**:
  - `Nasogastric Tube (NG Tube)` (`ButtonNGTube`)
  - `Port Access` (`ButtonPortAccess`)
  - `Burn Dressing Change` (`ButtonBurnDress`)
  - `Intravenous Start (IV Start)` (`ButtonIVStart`)
- **Up & Down Arrow Navigation Controls**:
  - Interactive floating `IconArrowUp` and `IconArrowDown` buttons on the right side.
  - Tapping **Down Arrow** smoothly scrolls to the next procedure.
  - Tapping **Up Arrow** smoothly scrolls to the previous procedure.
  - Dynamic visibility: at top of list, only Down Arrow is shown (matching Screenshot 1); when scrolled down, both Up and Down arrows appear (matching Screenshot 2).
  - Native touch/finger scrolling is simultaneously supported.
- **Bottom Fade Gradient**:
  - Content fades smoothly into the purple background before reaching the bottom bar.
- **Bottom Navigation Bar**:
  - 5-tab bar (`BottomBarPreparations`) with `PREPARATIONS` active in bright cyan.

---

## 📐 Responsive Scaling & Orientation Behavior

| Device / Orientation | Layout Structure | Sizing Logic |
| :--- | :--- | :--- |
| **iPad (Landscape)** *(Mockup Target)* | Full width with comfortable side margins | Header scales to ~14% height, cards scale up to 840pt width. Arrow buttons anchor to the right. |
| **iPad (Portrait)** | Clean proportional scaling | Cards scale to 72% screen width, maintaining 3.15:1 aspect ratio. All elements fit without clipping. |
| **iPhone (Landscape)** | Compact vertical layout | Header and bottom bar scale down so procedures remain fully viewable. |
| **iPhone (Portrait)** | Vertical mobile layout | Full-width cards with comfortable touch targets (44pt+). |

---

## 🛠 Project Structure

```
iOS/RileyApp/
├── Package.swift                  # Swift Package Manager manifest
├── README.md                      # Documentation & integration guide
├── Assets.xcassets/               # Complete Xcode Asset Catalog
│   ├── Background.imageset/
│   ├── HeaderBanner.imageset/
│   ├── ButtonPreparations.imageset/
│   ├── ButtonGlossary.imageset/
│   ├── ButtonAnatomyExplorer.imageset/
│   ├── ButtonGallery.imageset/
│   ├── ButtonGames.imageset/
│   ├── ButtonAbout.imageset/
│   ├── ButtonLegal.imageset/
│   ├── IconSettings.imageset/
│   ├── IconHome.imageset/
│   ├── IconBack.imageset/
│   ├── IconArrowUp.imageset/
│   ├── IconArrowDown.imageset/
│   ├── ButtonNGTube.imageset/
│   ├── ButtonPortAccess.imageset/
│   ├── ButtonBurnDress.imageset/
│   ├── ButtonIVStart.imageset/
│   ├── RibbonProceduresSelected.imageset/
│   ├── RibbonEducationSelected.imageset/
│   └── BottomBarPreparations.imageset/
└── Sources/
    ├── AppTheme.swift             # Colors, aspect ratios & HapticManager
    ├── HomeNavigationModel.swift  # Navigation destinations & state
    ├── HomeComponents.swift       # Bouncy buttons, pill buttons, sheets
    ├── HomeHeaderView.swift       # Top header banner & action icons
    ├── HomeScreenView.swift       # Responsive Home Screen view
    ├── HomeScreenPreviews.swift   # Previews for iPad & iPhone
    ├── PreparationsView.swift     # Scrollable Preparations view with arrows
    └── RileyApp.swift             # App entry point (@main)
```

---

## 🚀 How to Run in Xcode

1. Open `Package.swift`:
   ```bash
   open iOS/RileyApp/Package.swift
   ```
2. Open `PreparationsView.swift` or `HomeScreenView.swift` to see the Canvas Previews.
3. Tap the "PREPARATIONS" button to transition directly into the Preparations screen!
4. Tap the **Down Arrow** or **Up Arrow** to test the animated scrolling!

---

## 🎮 Interactive Live Simulator

You can test both screens immediately in your web browser:
1. Open [`preview/index.html`](file:///Users/rileytechstudio/Documents/Gemini/App/preview/index.html) in Safari or Chrome.
2. Use the **Screen** dropdown to switch between **Home** and **Preparations** (or tap "PREPARATIONS" on Home).
3. Click the **Down Arrow** and **Up Arrow** buttons to see the smooth scrolling and dynamic arrow visibility!
4. Click the **Rotate** button to test instant 90° orientation changes!
