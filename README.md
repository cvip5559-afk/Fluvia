# Fluvia

Fluvia is an iOS app that helps people who stutter practice evidence-based speech techniques, track their progress, and reflect on their wins — all in one place.

Built with SwiftUI and an on-device Core ML model, Fluvia listens to a short voice sample, classifies the type of stutter it hears, and recommends the right exercise for it — no internet connection required.

## Features

### 🎙️ Voice Assessment
Record a short reading sample and get instant, on-device analysis of your speech pattern. The app classifies your recording into one of five stutter types and links you straight to the matching exercise.

### 🧘 Five Guided Exercises
Each exercise targets a specific stutter type with an interactive, evidence-based technique:

| Exercise | Technique | Targets |
|---|---|---|
| **Say It Slow** | Prolongation — stretch sounds gently | Sound prolongation |
| **Easy Start** | Gentle onset / guided breathing | Blocks |
| **Smooth Start** | Stretch & glide into repeated sounds | Sound repetition |
| **Say It Once** | Say the whole word smoothly, once | Word repetition |
| **Silent Pause** | Swap filler words for a silent pause | Interjections |

Every exercise session ends with a completion screen and logs your progress for the day.

### 📈 Progress Tracking
A calendar-based streak system (aligned to real Sunday–Saturday weeks) shows which days you practiced, which you missed, and your current weekly completion percentage — visible right from the home screen and in full detail on the Progress page.

### 📝 Positive Journal
Jot down a quick positive reflection after a win — big or small. Notes are timestamped, color-coded, and fully editable or deletable.

### 🏠 One Home Screen
No tab bar to dig through — Voice Assessment, Exercises, Progress, and Journal are all one tap away from a single home hub.

## Tech Stack

- **SwiftUI** — entire UI, no UIKit
- **Core ML + SoundAnalysis** — on-device stutter classification (`SNAudioFileAnalyzer` / `SNClassifySoundRequest`), no network calls, fully private
- **AVFoundation** — audio recording
- **UserDefaults** — lightweight local persistence for streaks and journal entries

## Project Structure

```
Fluvia/
├── App/                  # Entry point, launch flow
├── Onboarding/           # Welcome screen
├── Home/                 # Single home hub (replaces tab navigation)
├── Assess/                # Voice recording + on-device ML analysis
├── Exercises/             # The 5 stutter-technique exercises
├── Progress/               # Streak tracking & weekly history
├── Journal/                # Positive Journal (list, compose, edit)
```

## Privacy

Voice recordings are analyzed **entirely on-device** using Core ML. Nothing is uploaded, stored remotely, or shared with any third party.

## Team

Built by [add your names here] as part of [add course/hackathon/project context here].

## Getting Started

1. Clone the repo
2. Open `Fluvia.xcodeproj` in Xcode 16+
3. Build and run on an iOS 17+ simulator or device
4. Grant microphone permission when prompted to use Voice Assessment

---

*Every voice deserves to be heard.*
