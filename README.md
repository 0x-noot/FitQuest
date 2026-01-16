# FitQuest

A gamified workout tracker iOS app that makes fitness feel like leveling up in a video game. Track your workouts, build daily streaks, earn XP, and customize your avatar as you progress.

![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-purple.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## Overview

FitQuest transforms your fitness journey into an RPG-like experience. Every workout you complete earns XP, helping you level up your character. Maintain daily streaks to unlock bonus multipliers, and customize your avatar as you hit new milestones.

## Features

### Tab-Based Navigation

The app features three main tabs:

| Tab | Icon | Description |
|-----|------|-------------|
| **Home** | 🏠 | Main dashboard with character, stats, and workout buttons |
| **History** | 📅 | 30-day calendar heatmap and workout history |
| **Profile** | 👤 | Avatar customization, name, stats, and preferences |

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

### Workout Tracking (27 Pre-filled Workouts)

#### Cardio (5 workouts) - High XP
| Workout | Base XP |
|---------|---------|
| Run | 200 |
| Walk | 120 |
| Cycling | 175 |
| Swimming | 225 |
| Stair Climber | 200 |

#### Strength by Muscle Group (22 workouts) - Lower XP per exercise

| Muscle Group | Exercises |
|--------------|-----------|
| **Chest** | Barbell Bench Press, Dumbbell Bench Press, Incline Bench Press, Chest Fly |
| **Back** | Lat Pulldown, Seated Row, Pull-ups |
| **Shoulders** | Shoulder Press, Lateral Raises |
| **Biceps** | Barbell Curl, Dumbbell Curl |
| **Triceps** | Triceps Pushdown, Overhead Triceps Extension |
| **Legs** | Squats, Leg Press, Leg Extensions, Leg Curls, Lunges, Deadlift |
| **Core** | Plank, Cable Crunch, Russian Twists |

#### XP Philosophy
- **Cardio** = Full workout session (120-225 XP base)
- **Strength** = Individual exercise (30-50 XP base)
- **1 cardio session ≈ 4-5 strength exercises in XP**

This balances XP for users who do cardio vs. those who do multiple strength exercises per gym session.

#### Workout Data Entry
- **Strength Training**: Weight (optional), reps, and sets
- **Cardio**: Duration (required), steps (optional), calories burned (optional)
- **Custom Workouts**: Create and save your own workout templates with "Uses Weight" toggle for bodyweight exercises

### History Tab
- **30-Day Calendar Heatmap**: Visual representation of workout consistency
  - Color intensity based on number of workouts per day
  - Today highlighted with border
  - Legend showing intensity scale
- **Statistics Cards**: Total workouts and total XP earned
- **Recent Workouts**: List of workouts grouped by date with XP earned

### Profile Tab
- **Avatar Display**: View and customize your character
- **Editable Display Name**: Tap to change your player name
- **Statistics Overview**:
  - Current Level
  - Total XP
  - Total Workouts
  - Current Streak
  - Highest Streak
  - Member Since date
- **Preferences**: Notification settings, weight unit selection
- **About**: Version information

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
- **Tab Bar Navigation**: Easy access to Home, History, and Profile
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
│   └── ContentView.swift              # TabView navigation
├── Models/
│   ├── Player.swift                   # Player profile, XP, streaks
│   ├── Workout.swift                  # Workout records
│   ├── WorkoutTemplate.swift          # 27 workout templates
│   ├── CharacterAppearance.swift      # Character customization
│   └── Enums/
│       ├── WorkoutType.swift          # Cardio vs Strength
│       └── MuscleGroup.swift          # 8 muscle categories
├── ViewModels/
│   ├── PlayerViewModel.swift          # Player state management
│   └── WorkoutViewModel.swift         # Workout operations
├── Views/
│   ├── Home/
│   │   ├── HomeTab.swift              # Home tab dashboard
│   │   └── CharacterDisplayView.swift # Character rendering
│   ├── History/
│   │   └── HistoryTab.swift           # Calendar heatmap & history
│   ├── Profile/
│   │   └── ProfileTab.swift           # Avatar, name, settings
│   ├── Workout/
│   │   ├── QuickWorkoutSheet.swift    # Muscle group organized selection
│   │   ├── CustomWorkoutSheet.swift   # Custom workout creation
│   │   └── WorkoutInputSheet.swift    # Workout data entry
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
2. **Home Tab** - View your character, level, XP progress, and streaks
3. **Add a workout** - Tap "Add Quick Workout" to select from 27 pre-filled exercises organized by muscle group, or "Add Custom Workout" to create your own
4. **Enter workout details** - Log your weight/reps/sets or duration/steps/calories
5. **Earn XP** - Watch your XP bar fill and level up!
6. **History Tab** - View your 30-day workout heatmap and past workouts
7. **Profile Tab** - Customize your avatar, change your name, view detailed statistics

## Version History

### v1.1.0 (Current)
- **Tab-based navigation**: Home, History, Profile tabs
- **Expanded workouts**: 27 pre-filled templates (was 10)
- **Muscle group organization**: Chest, Back, Shoulders, Biceps, Triceps, Legs, Core
- **Calendar heatmap**: 30-day visual workout history
- **Profile tab**: Avatar customization, editable name, statistics, preferences
- **XP rebalancing**: Cardio gives more XP per session, strength gives less per exercise
- **Bodyweight support**: "Uses Weight" toggle for custom workouts

### v1.0.0
- Initial release
- Core workout tracking (cardio & strength)
- XP and leveling system
- Daily streak tracking with bonus multipliers
- 10 pre-filled workout templates
- Custom workout creation
- Placeholder character with customization
- Dark mode UI
- Level-up celebrations

## Roadmap

### v1.2.0 (Planned)
- [ ] Real pixel art character sprites
- [ ] Character idle animations
- [ ] Achievement system
- [ ] Workout reminders/notifications

### v1.3.0 (Planned)
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
