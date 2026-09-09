# Refract

**Learn photo color grading by actually doing it, not by reading a wall of text.**

Refract is an iOS app that teaches you how Brightness, Contrast, Saturation, and Vibrance actually change a photo. No jargon-heavy tutorials, no guessing. You drag a slider, you watch the image change in real time, and you get instant feedback on whether your edit actually looks good or just blew out the highlights.

## What's inside

### Tutorial Module
Pick a parameter, get a short explanation of what it does and when to use it, then play with it yourself:
- A live slider synced to a preview image, so you *see* the effect instead of imagining it.
- Side-by-side extreme previews, crank a parameter all the way up or down and see exactly where it breaks.
- A "Try This" shortcut that jumps the slider to a sensible example value.
- Progress that actually sticks; finish a module once, and it stays marked complete (saved locally, survives app restarts).
- A share button once you've completed a module, so you can show off what you learned.

### Practice Mode
This is where the training wheels come off:
- Import any photo from your library.
- Tweak all four parameters at once with smooth, debounced live previews.
- Get real feedback, not just a filter. Refract analyzes the histogram of your edit and flags things like blown-out highlights, crushed shadows, or oversaturated colors, then tells you in plain language how to fix it.

## Built with

- **Swift + UIKit** programmatic UIKit for the main flow
- **CoreImage** (`CIColorControls`, `CIVibrance`) doing the actual grading math
- **MVVM**, wired up with lightweight closures instead of a heavy framework
- **XCTest** for unit + UI tests
- **SwiftLint** keeping everyone honest on code style
- **Jenkins** running build + test on every push

## Project layout

```
Refract/
├── App/                        # AppDelegate & SceneDelegate
├── Features/
│   ├── Home/                   # Module list + progress overview
│   ├── TutorialModule/         # The guided, per-parameter lesson screen
│   └── PracticeMode/           # Free-form editing with your own photo
├── Models/                     # GradingParameter, HistogramStats, FeedbackMessage, etc.
├── Services/                   # ImageGradingEngine, RealHistogramAnalyzer, FeedbackRuleEngine, etc.
└── Resources/                  # Assets, LaunchScreen

RefractTests/                   # Unit tests for Services & ViewModels
RefractUITests/                 # UI tests
```

## Running it

You'll need Xcode (recent enough to target iOS 15+) and either a simulator or a physical device on iOS 15.0+.

```bash
git clone https://github.com/mewcurryy/Refract.git
open Refract.xcodeproj
```

Pick a simulator (iPhone 17 Pro works great), hit `Cmd + R`, and you're in.

## Testing

```bash
xcodebuild test \
  -project Refract.xcodeproj \
  -scheme Refract \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'
```

Or just hit `Cmd + U` in Xcode. Coverage focuses on the stuff that actually matters: the grading math, the feedback rules, progress persistence, and every ViewModel driving the UI.

## CI

Every push gets built and tested automatically via Jenkins (`Jenkinsfile`) -> `xcodebuild` + `xcpretty`, results reported as JUnit. No "works on my machine."
