# FitQuest

A gamified workout tracker iOS app that makes fitness feel like leveling up in a video game. Track your workouts, build daily streaks, earn XP, and customize your pixel-art character as you progress.

![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-purple.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## Overview

FitQuest transforms your fitness journey into an RPG-like experience. Every workout you complete earns XP, helping you level up your character. Maintain daily streaks to unlock bonus multipliers, and customize your avatar as you hit new milestones.

## Features

### Gamification System
- **XP Progression**: Earn experience points for every workout completed
- **Level System**: Progress through levels using a balanced quadratic curve (`100 × level^1.8`)
- **Daily Streaks**: Build consecutive workout days for bonus XP multipliers
  - 3-6 days: +10% bonus
  - 7-13 days: +25% bonus
  - 14-29 days: +50% bonus
  - 30+ days: +100% bonus
- **Level-Up Celebrations**: Animated celebrations when you reach new levels
- **Milestone Rewards**: Special unlocks at levels 5, 10, 15, 20, 25, 30, 40, 50, 75, and 100

### Workout Tracking

#### Pre-filled Workouts
| Cardio | Strength |
|--------|----------|
| Run | Squats |
| Walk | Deadlifts |
| Cycling | Bench Press |
| Swimming | Pull-ups |
| | Push-ups |
| | Planks |

#### Workout Data Entry
- **Strength Training**: Weight, reps, and sets with volume calculation
- **Cardio**: Duration (required), steps (optional), calories burned (optional)
- **Custom Workouts**: Create and save your own workout templates

#### XP Calculation
- Base XP varies by workout type (40-90 XP)
- Strength workouts: Volume multiplier based on weight × reps × sets
- Cardio workouts: Duration multiplier + intensity bonus from calories
- First workout of the day: +25 XP bonus
- Streak multipliers stack on top

### Character Customization
- **Placeholder System**: Shape-based character ready for pixel art upgrade
- **Customization Options**:
  - Body type (Slim, Medium, Athletic)
  - Skin tones (6 options)
  - Hair styles (8 options) and colors (8 options)
  - Outfit colors (tops and bottoms)
  - Headwear (unlockable)
  - Accessories (unlockable)
- **Unlockable Items**: Earn new customization options by reaching level milestones

### User Interface
- **Dark Mode Design**: Sleek, modern UI with purple and cyan accents
- **Home Dashboard**: Character display, level progress, streak counter, quick actions
- **Workout History**: View past workouts grouped by date with weekly stats
- **Animated Components**: Smooth XP bar fills, breathing character animation, level-up effects

## Tech Stack

- **Framework**: SwiftUI
- **Persistence**: SwiftData (iOS 17+)
- **Architecture**: MVVM with @Observable
- **Minimum iOS**: 17.0

## Project Structure

```
FitQuest/
├── App/
│   ├── FitQuestApp.swift              # App entry point
│   └── ContentView.swift              # Root navigation
├── Models/
│   ├── Player.swift                   # Player profile, XP, streaks
│   ├── Workout.swift                  # Workout records
│   ├── WorkoutTemplate.swift          # Workout templates
│   ├── CharacterAppearance.swift      # Character customization
│   └── Enums/
│       ├── WorkoutType.swift          # Cardio vs Strength
│       └── MuscleGroup.swift          # Muscle categories
├── ViewModels/
│   ├── PlayerViewModel.swift          # Player state management
│   └── WorkoutViewModel.swift         # Workout operations
├── Views/
│   ├── Home/
│   │   ├── HomeView.swift             # Main dashboard
│   │   └── CharacterDisplayView.swift # Character rendering
│   ├── Workout/
│   │   ├── QuickWorkoutSheet.swift    # Pre-filled workout selection
│   │   ├── CustomWorkoutSheet.swift   # Custom workout creation
│   │   ├── WorkoutInputSheet.swift    # Workout data entry
│   │   └── WorkoutHistoryView.swift   # Workout history
│   ├── Character/
│   │   └── CharacterCustomizationView.swift
│   └── Components/
│       ├── XPProgressBar.swift        # Animated progress bar
│       ├── StreakBadge.swift          # Streak display
│       ├── LevelBadge.swift           # Level indicator
│       └── PrimaryButton.swift        # Styled buttons
├── Services/
│   ├── LevelManager.swift             # XP thresholds & levels
│   ├── XPCalculator.swift             # XP award calculations
│   └── StreakManager.swift            # Streak logic
└── Extensions/
    └── Color+Theme.swift              # Dark mode color palette
```

## Installation

### Requirements
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/FitQuest.git
   ```

2. Open in Xcode:
   ```bash
   cd FitQuest
   open FitQuest.xcodeproj
   ```

   Or create a new Xcode project and copy the source files.

3. Build and run on simulator or device (iOS 17+)

## Usage

1. **Launch the app** - A new player profile and character are created automatically
2. **Add a workout** - Tap "Add Quick Workout" for pre-filled options or "Add Custom Workout" to create your own
3. **Enter workout details** - Log your weight/reps/sets or duration/steps/calories
4. **Earn XP** - Watch your XP bar fill and level up!
5. **Build streaks** - Work out daily to increase your streak multiplier
6. **Customize your character** - Tap on your character to change appearance

## Version History

### v1.0.0 (Current)
- Initial release
- Core workout tracking (cardio & strength)
- XP and leveling system
- Daily streak tracking with bonus multipliers
- 10 pre-filled workout templates
- Custom workout creation
- Placeholder character with customization
- Dark mode UI
- Workout history view
- Level-up celebrations

## Roadmap

### v1.1.0 (Planned)
- [ ] Real pixel art character sprites
- [ ] Character idle animations
- [ ] Achievement system
- [ ] Workout reminders/notifications

### v1.2.0 (Planned)
- [ ] iCloud sync
- [ ] Apple Health integration
- [ ] Workout statistics and charts
- [ ] Social features (share achievements)

### v2.0.0 (Future)
- [ ] Workout programs/plans
- [ ] Exercise library with instructions
- [ ] Rest timer
- [ ] Apple Watch companion app

## Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Background | `#0D0D0F` | Main background |
| Card | `#1A1A1F` | Card surfaces |
| Primary | `#8B5CF6` | Purple accent |
| Secondary | `#22D3EE` | Cyan accent |
| Success | `#22C55E` | XP gains |
| Streak | `#F97316` | Streak flame |
| Warning | `#F59E0B` | Stars, trophies |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with SwiftUI and SwiftData
- Inspired by fitness apps and RPG games
- Dark mode design influenced by modern iOS design patterns

---

**Made with SwiftUI**
