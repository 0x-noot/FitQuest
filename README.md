# Fitogatchi

A Tamagotchi-style fitness app where you care for a virtual pet by working out. Your workouts feed your pet XP, helping it level up and stay happy. Miss workouts and your pet's happiness decays—neglect it too long and it runs away!

![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-purple.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## Overview

Fitogatchi transforms your fitness journey into a pet care experience. Every workout you complete earns XP for your pet, helping it level up and grow stronger. Keep your pet happy by staying consistent with your workouts, and use Essence currency to buy treats when you need a happiness boost.

## Features

### Pet System

Choose from 5 unique pet species, each with their own personality and XP bonuses:

| Pet | Icon | Bonus | Personality |
|-----|------|-------|-------------|
| **Plant** | 🌿 | +3% all XP | Grows with consistency |
| **Cat** | 🐱 | +5% cardio XP | Cardio specialist |
| **Dog** | 🐕 | +3% all XP | Loyal balanced companion |
| **Wolf** | 🐺 | +5% strength XP | Strength specialist |
| **Dragon** | 🔥 | +7% strength XP | Highest strength bonus |

### Pet Mechanics

- **XP Leveling**: Your pet levels up using XP from your workouts (formula: `100 × level^1.8`)
- **Happiness System**: Pet happiness decays 33.33% per day without workouts
- **Mood States**: Happy (≥75%), Content (50-74%), Sad (25-49%), Miserable (<25%)
- **XP Bonus**: Happy pets (≥90% happiness) give +10% XP multiplier
- **Running Away**: If happiness hits 0%, your pet runs away
- **Recovery**: Bring back your pet with 3 workouts in 7 days OR 150 Essence

### Essence Currency

- Earn 1 Essence for every 10 XP your pet gains
- Use Essence to buy treats that boost your pet's happiness
- Treats available: Small Treat (10 Essence, +10 happiness), Regular Treat (25 Essence, +25 happiness), Premium Treat (50 Essence, +50 happiness)

### Tab-Based Navigation

| Tab | Icon | Description |
|-----|------|-------------|
| **Home** | 🏠 | Main dashboard with pet display, stats, and workout buttons |
| **History** | 📅 | 30-day calendar heatmap and workout history |
| **Profile** | 👤 | Pet info, stats, achievements, and preferences |

### Streak System

- **Daily Streaks**: Build consecutive workout days for bonus XP multipliers
  - 3-6 days: +10% bonus
  - 7-13 days: +25% bonus
  - 14-29 days: +50% bonus
  - 30+ days: +100% bonus
- **Weekly Streaks**: Set a weekly workout goal and track your progress
- **Rest Days**: Use up to 2 rest days per week to protect your streak

### Achievements (11 Badges)

| Badge | Requirement |
|-------|-------------|
| First Steps | Complete 1 workout |
| Week Warrior | Maintain a 7-day streak |
| Dedicated | Maintain a 14-day streak |
| Unstoppable | Maintain a 30-day streak |
| Century | Complete 100 workouts |
| XP Hunter | Help your pet earn 10,000 XP |
| Rising Star | Help your pet reach level 10 |
| Champion | Help your pet reach level 25 |
| Legend | Help your pet reach level 50 |
| Early Bird | Workout before 9 AM |
| Night Owl | Workout after 9 PM |

### Workout Tracking (27 Pre-filled Workouts)

#### Cardio (5 workouts) - High XP
| Workout | Base XP |
|---------|---------|
| Run | 200 |
| Walk | 120 |
| Cycling | 175 |
| Swimming | 225 |
| Stair Climber | 200 |

#### Strength by Muscle Group (22 workouts)

| Muscle Group | Exercises |
|--------------|-----------|
| **Chest** | Barbell Bench Press, Dumbbell Bench Press, Incline Bench Press, Chest Fly |
| **Back** | Lat Pulldown, Seated Row, Pull-ups |
| **Shoulders** | Shoulder Press, Lateral Raises |
| **Biceps** | Barbell Curl, Dumbbell Curl |
| **Triceps** | Triceps Pushdown, Overhead Triceps Extension |
| **Legs** | Squats, Leg Press, Leg Extensions, Leg Curls, Lunges, Deadlift |
| **Core** | Plank, Cable Crunch, Russian Twists |

### User Interface

- **Dark Mode Design**: Sleek, modern UI with purple and cyan accents
- **Pet-Centric Layout**: Large animated pet display as the focal point
- **Animated Components**: Breathing pet animation, XP bars, level-up celebrations

## Tech Stack

- **Framework**: SwiftUI
- **Persistence**: SwiftData (iOS 17+)
- **Architecture**: MVVM with @Observable
- **Minimum iOS**: 17.0

## Project Structure

```
Fitogatchi/
├── App/
│   ├── FitogatchiApp.swift           # App entry point
│   └── ContentView.swift             # TabView navigation
├── Models/
│   ├── Player.swift                  # Player profile, streaks, essence
│   ├── Pet.swift                     # Pet with XP, happiness, leveling
│   ├── Workout.swift                 # Workout records
│   ├── WorkoutTemplate.swift         # 27 workout templates
│   ├── Achievement.swift             # Achievement definitions
│   └── Enums/
│       ├── WorkoutType.swift         # Cardio vs Strength
│       ├── MuscleGroup.swift         # 8 muscle categories
│       ├── PetSpecies.swift          # 5 pet types
│       ├── PetMood.swift             # Happy, Content, Sad, Miserable
│       └── PetTreat.swift            # Treat types and costs
├── Views/
│   ├── Home/
│   │   └── HomeView.swift            # Pet-centric home dashboard
│   ├── History/
│   │   └── HistoryTab.swift          # Calendar heatmap & history
│   ├── Profile/
│   │   ├── ProfileTab.swift          # Pet stats, achievements, settings
│   │   └── AchievementBadgeView.swift
│   ├── Workout/
│   │   ├── QuickWorkoutSheet.swift
│   │   ├── CustomWorkoutSheet.swift
│   │   └── WorkoutInputSheet.swift
│   ├── Pet/
│   │   └── PetDetailView.swift       # Detailed pet view with treats
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   ├── OnboardingWelcomeStep.swift
│   │   ├── OnboardingPetStep.swift   # Pet selection
│   │   ├── OnboardingGoalStep.swift
│   │   └── OnboardingCompleteStep.swift
│   └── Components/
│       ├── PetCompanionView.swift
│       ├── PetDisplayCard.swift
│       ├── XPProgressBar.swift
│       ├── StreakBadge.swift
│       ├── EssenceBadge.swift
│       └── PrimaryButton.swift
├── Services/
│   ├── PetManager.swift              # Pet happiness, treats, recovery
│   ├── LevelManager.swift            # XP thresholds & levels
│   ├── XPCalculator.swift            # XP award calculations
│   ├── StreakManager.swift           # Streak logic
│   ├── NotificationManager.swift     # Push notifications
│   └── SoundManager.swift            # Sound effects
└── Extensions/
    └── Color+Theme.swift             # Dark mode color palette
```

## Installation

### Requirements
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/Fitogatchi.git
   ```

2. Open in Xcode:
   ```bash
   cd Fitogatchi
   open Fitogatchi.xcodeproj
   ```

3. Build and run on simulator or device (iOS 17+)

## Usage

1. **Launch the app** - Complete onboarding to choose your pet
2. **Home Tab** - View your pet, its happiness, level, and XP progress
3. **Add a workout** - Tap workout buttons to log exercises
4. **Earn XP** - Watch your pet gain XP and level up!
5. **Feed treats** - Use Essence to buy treats and boost happiness
6. **Stay consistent** - Keep your pet happy by working out regularly

## Version History

### v2.0.0 (Current) - Fitogatchi
- **Complete overhaul**: Transformed from player-focused to pet-focused app
- **5 Pet Species**: Plant, Cat, Dog, Wolf, Dragon with unique bonuses
- **Pet Leveling**: XP now goes to your pet instead of player
- **Happiness System**: Pet happiness decays daily, boosted by workouts
- **Treat System**: Use Essence to buy treats for your pet
- **Pet Recovery**: Bring back runaway pets with workouts or Essence
- **Renamed**: FitQuest → Fitogatchi

### v1.x (Legacy - FitQuest)
- Player avatar and leveling system
- Ranking system (Bronze to Diamond)
- Character customization

## Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Background | `#0D0D0F` | Main background |
| Card | `#1A1A1F` | Card surfaces |
| Primary | `#8B5CF6` | Purple accent |
| Secondary | `#22D3EE` | Cyan accent |
| Success | `#22C55E` | XP gains |
| Streak | `#F97316` | Streak flame |
| Warning | `#F59E0B` | Essence, treats |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Made with SwiftUI**
