import Foundation

// MARK: - Seeded Random Number Generator

struct SeededRNG: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        // xorshift64
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}

// MARK: - Workout Plan Generator

struct WorkoutPlanGenerator {

    // MARK: - Equipment Requirements

    /// Which equipment access levels allow each template
    private static let templateEquipment: [String: Set<EquipmentAccess>] = [
        // Cardio
        "Run":            [.fullGym, .homeGym, .bodyweight, .cardioEquipment],
        "Walk":           [.fullGym, .homeGym, .bodyweight, .cardioEquipment],
        "Cycling":        [.fullGym, .cardioEquipment],
        "Swimming":       [.fullGym],
        "Stair Climber":  [.fullGym, .cardioEquipment],
        "Padel":          [.fullGym, .bodyweight],

        // Chest
        "Barbell Bench Press":  [.fullGym],
        "Dumbbell Bench Press": [.fullGym, .homeGym],
        "Incline Bench Press":  [.fullGym],
        "Chest Fly":            [.fullGym, .homeGym],

        // Back
        "Lat Pulldown": [.fullGym],
        "Seated Row":   [.fullGym],
        "Pull-ups":     [.fullGym, .homeGym, .bodyweight],

        // Shoulders
        "Shoulder Press":  [.fullGym, .homeGym],
        "Lateral Raises":  [.fullGym, .homeGym],

        // Biceps
        "Barbell Curl":  [.fullGym],
        "Dumbbell Curl": [.fullGym, .homeGym],

        // Triceps
        "Triceps Pushdown":           [.fullGym],
        "Overhead Triceps Extension": [.fullGym, .homeGym],

        // Legs
        "Squats":         [.fullGym, .homeGym, .bodyweight],
        "Leg Press":      [.fullGym],
        "Leg Extensions": [.fullGym],
        "Leg Curls":      [.fullGym],
        "Lunges":         [.fullGym, .homeGym, .bodyweight],
        "Deadlift":       [.fullGym, .homeGym],

        // Core
        "Plank":          [.fullGym, .homeGym, .bodyweight],
        "Cable Crunch":   [.fullGym],
        "Russian Twists": [.fullGym, .homeGym, .bodyweight],
    ]

    // MARK: - Day Labels

    private static let dayLabels = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

    // MARK: - Public API

    static func generatePlan(
        player: Player,
        templates: [WorkoutTemplate]
    ) -> WeeklyPlan {
        let weeklyGoal = max(1, min(7, player.weeklyWorkoutGoal))
        let equipment = player.equipmentAccess.isEmpty ? EquipmentAccess.allCases : player.equipmentAccess

        // Create seeded RNG from the current week + regeneration count
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        let seed = UInt64(abs(weekStart.timeIntervalSince1970.hashValue)) &+ UInt64(player.planRegenerationCount)
        var rng = SeededRNG(seed: max(1, seed))

        // Step 1: Determine cardio/strength split
        let (strengthDays, cardioDays) = calculateSplit(
            weeklyGoal: weeklyGoal,
            style: player.workoutStyle,
            goals: player.fitnessGoals
        )

        // Step 2: Distribute workout days across the week
        let daySlots = distributeDays(
            weeklyGoal: weeklyGoal,
            strengthDays: strengthDays,
            cardioDays: cardioDays,
            rng: &rng
        )

        // Step 3: Build each day
        let availableTemplates = filterTemplates(templates, forEquipment: equipment)
        let strengthTemplates = availableTemplates.filter { $0.workoutType == .strength }
        let planCardioNames: Set<String> = ["Run", "Walk", "Stair Climber"]
        let cardioTemplates = availableTemplates.filter { $0.workoutType == .cardio && planCardioNames.contains($0.name) }

        let muscleGroupSchedule = buildMuscleGroupSchedule(
            strengthDayCount: strengthDays,
            focusAreas: player.focusAreas,
            fitnessLevel: player.fitnessLevel,
            hasBuildMuscleGoal: player.hasBuildMuscleGoal,
            rng: &rng
        )

        var strengthDayIndex = 0
        var cardioDayIndex = 0
        var days: [PlannedDay] = []

        for dayIndex in 0..<7 {
            let label = dayLabels[dayIndex]

            switch daySlots[dayIndex] {
            case .rest:
                days.append(PlannedDay(
                    dayOfWeek: dayIndex + 1,
                    label: label,
                    exercises: [],
                    isRestDay: true,
                    theme: "REST"
                ))

            case .strength:
                let groups: [MuscleGroup]
                if strengthDayIndex < muscleGroupSchedule.count {
                    groups = muscleGroupSchedule[strengthDayIndex]
                } else {
                    let fallbacks: [[MuscleGroup]] = [[.chest], [.back], [.legs]]
                    groups = fallbacks[strengthDayIndex % fallbacks.count]
                }
                strengthDayIndex += 1

                let exercises = selectStrengthExercises(
                    muscleGroups: groups,
                    from: strengthTemplates,
                    fitnessLevel: player.fitnessLevel,
                    rng: &rng
                )
                let theme = groups.map { $0.displayName.uppercased() }.joined(separator: " + ")

                days.append(PlannedDay(
                    dayOfWeek: dayIndex + 1,
                    label: label,
                    exercises: exercises,
                    isRestDay: false,
                    theme: theme
                ))

            case .cardio:
                let exercise = selectCardioExercise(
                    from: cardioTemplates,
                    index: cardioDayIndex,
                    rng: &rng
                )
                cardioDayIndex += 1

                days.append(PlannedDay(
                    dayOfWeek: dayIndex + 1,
                    label: label,
                    exercises: exercise.map { [$0] } ?? [],
                    isRestDay: false,
                    theme: "CARDIO"
                ))
            }
        }

        return WeeklyPlan(days: days, workoutDayCount: weeklyGoal)
    }

    // MARK: - Step 1: Cardio/Strength Split

    private enum DayType {
        case rest, strength, cardio
    }

    private static func calculateSplit(
        weeklyGoal: Int,
        style: WorkoutStyle?,
        goals: [FitnessGoal]
    ) -> (strength: Int, cardio: Int) {
        let ratio: Double
        switch style {
        case .weights:  ratio = 0.8
        case .cardio:   ratio = 0.2
        case .balanced, .notSure, .none: ratio = 0.5
        }

        var strengthDays = Int(round(Double(weeklyGoal) * ratio))
        var cardioDays = weeklyGoal - strengthDays

        // Goal adjustments
        if goals.contains(.buildMuscle) && cardioDays > 0 {
            strengthDays += 1
            cardioDays -= 1
        }
        if (goals.contains(.improveCardio) || goals.contains(.trainForEvent)) && strengthDays > 0 {
            cardioDays += 1
            strengthDays -= 1
        }
        if goals.contains(.loseWeight) && strengthDays > 1 {
            cardioDays += 1
            strengthDays -= 1
        }

        // Clamp
        strengthDays = max(0, min(weeklyGoal, strengthDays))
        cardioDays = weeklyGoal - strengthDays

        return (strengthDays, cardioDays)
    }

    // MARK: - Step 2: Distribute Days

    private static func distributeDays(
        weeklyGoal: Int,
        strengthDays: Int,
        cardioDays: Int,
        rng: inout SeededRNG
    ) -> [DayType] {
        var slots: [DayType] = Array(repeating: .rest, count: 7)

        // Pick evenly-spaced workout day indices (Mon-based: indices 1-6, then 0 for Sun)
        // Prefer Mon(1), Tue(2), Wed(3), Thu(4), Fri(5), Sat(6), Sun(0)
        let preferredOrder = [1, 2, 3, 4, 5, 6, 0] // Mon first, Sun last

        var workoutIndices: [Int] = []
        if weeklyGoal >= 7 {
            workoutIndices = Array(0..<7)
        } else {
            let spacing = 7.0 / Double(weeklyGoal)
            for i in 0..<weeklyGoal {
                let idx = Int(Double(i) * spacing)
                workoutIndices.append(preferredOrder[idx])
            }
        }

        // Assign types: interleave strength and cardio
        var types: [DayType] = []
        var sRemaining = strengthDays
        var cRemaining = cardioDays

        // Alternate starting with the more common type
        let startWithStrength = strengthDays >= cardioDays
        for _ in 0..<weeklyGoal {
            if startWithStrength {
                if sRemaining > 0 {
                    types.append(.strength)
                    sRemaining -= 1
                } else {
                    types.append(.cardio)
                    cRemaining -= 1
                }
            } else {
                if cRemaining > 0 {
                    types.append(.cardio)
                    cRemaining -= 1
                } else {
                    types.append(.strength)
                    sRemaining -= 1
                }
            }
        }

        // Interleave: rearrange so strength and cardio alternate when possible
        var interleavedTypes: [DayType] = []
        var sQueue = types.filter { if case .strength = $0 { return true }; return false }
        var cQueue = types.filter { if case .cardio = $0 { return true }; return false }
        var lastWasStrength = false

        for _ in 0..<weeklyGoal {
            if !sQueue.isEmpty && !cQueue.isEmpty {
                if lastWasStrength {
                    interleavedTypes.append(.cardio)
                    cQueue.removeFirst()
                    lastWasStrength = false
                } else {
                    interleavedTypes.append(.strength)
                    sQueue.removeFirst()
                    lastWasStrength = true
                }
            } else if !sQueue.isEmpty {
                interleavedTypes.append(.strength)
                sQueue.removeFirst()
                lastWasStrength = true
            } else {
                interleavedTypes.append(.cardio)
                cQueue.removeFirst()
                lastWasStrength = false
            }
        }

        // Place into slots
        for (i, dayIndex) in workoutIndices.enumerated() {
            if i < interleavedTypes.count {
                slots[dayIndex] = interleavedTypes[i]
            }
        }

        return slots
    }

    // MARK: - Step 3a: Muscle Group Schedule

    private static func buildMuscleGroupSchedule(
        strengthDayCount: Int,
        focusAreas: [FocusArea],
        fitnessLevel: FitnessLevel?,
        hasBuildMuscleGoal: Bool,
        rng: inout SeededRNG
    ) -> [[MuscleGroup]] {
        guard strengthDayCount > 0 else { return [] }

        let level = fitnessLevel ?? .beginner

        if hasBuildMuscleGoal && !focusAreas.isEmpty {
            return buildFocusAreaSchedule(
                strengthDayCount: strengthDayCount,
                focusAreas: focusAreas,
                level: level,
                rng: &rng
            )
        }

        return buildDefaultSchedule(
            strengthDayCount: strengthDayCount,
            level: level,
            rng: &rng
        )
    }

    private static func buildFocusAreaSchedule(
        strengthDayCount: Int,
        focusAreas: [FocusArea],
        level: FitnessLevel,
        rng: inout SeededRNG
    ) -> [[MuscleGroup]] {
        // Collect all targeted muscle groups
        var allGroups: [MuscleGroup] = []
        for area in focusAreas {
            allGroups.append(contentsOf: area.muscleGroups)
        }
        // Remove duplicates while preserving order
        var seen = Set<MuscleGroup>()
        allGroups = allGroups.filter { seen.insert($0).inserted }

        // If fullBody, use all groups
        if focusAreas.contains(.fullBody) {
            allGroups = Array(MuscleGroup.allCases)
        }

        // Distribute groups across strength days
        var schedule: [[MuscleGroup]] = Array(repeating: [], count: strengthDayCount)
        for (i, group) in allGroups.enumerated() {
            schedule[i % strengthDayCount].append(group)
        }

        // Make sure no day is empty - fill with core if needed
        for i in 0..<schedule.count {
            if schedule[i].isEmpty {
                schedule[i] = [.core]
            }
        }

        return schedule
    }

    private static func buildDefaultSchedule(
        strengthDayCount: Int,
        level: FitnessLevel,
        rng: inout SeededRNG
    ) -> [[MuscleGroup]] {
        switch level {
        case .beginner:
            // Full body each day
            return Array(repeating: Array(MuscleGroup.allCases), count: strengthDayCount)

        case .intermediate:
            // Upper/lower split
            let upper: [MuscleGroup] = [.chest, .back, .shoulders, .biceps, .triceps]
            let lower: [MuscleGroup] = [.legs, .core]
            var schedule: [[MuscleGroup]] = []
            for i in 0..<strengthDayCount {
                schedule.append(i % 2 == 0 ? upper : lower)
            }
            return schedule

        case .advanced:
            // Push/Pull/Legs
            let push: [MuscleGroup] = [.chest, .shoulders, .triceps]
            let pull: [MuscleGroup] = [.back, .biceps]
            let legs: [MuscleGroup] = [.legs, .core]
            let splits = [push, pull, legs]
            var schedule: [[MuscleGroup]] = []
            for i in 0..<strengthDayCount {
                schedule.append(splits[i % 3])
            }
            return schedule
        }
    }

    // MARK: - Step 3b: Select Exercises

    private static func selectStrengthExercises(
        muscleGroups: [MuscleGroup],
        from templates: [WorkoutTemplate],
        fitnessLevel: FitnessLevel?,
        rng: inout SeededRNG
    ) -> [PlannedExercise] {
        let level = fitnessLevel ?? .beginner
        let targetCount: Int
        switch level {
        case .beginner:     targetCount = 3
        case .intermediate: targetCount = 4
        case .advanced:     targetCount = 5
        }

        var exercises: [PlannedExercise] = []
        var usedNames = Set<String>()

        // Pick exercises from each muscle group
        let exercisesPerGroup = max(1, targetCount / max(1, muscleGroups.count))

        for group in muscleGroups {
            let groupTemplates = templates.filter { $0.muscleGroup == group }
            var shuffled = groupTemplates
            shuffled.shuffle(using: &rng)

            for template in shuffled.prefix(exercisesPerGroup) {
                guard !usedNames.contains(template.name) else { continue }
                usedNames.insert(template.name)
                exercises.append(PlannedExercise(
                    templateName: template.name,
                    workoutType: template.workoutType,
                    muscleGroup: template.muscleGroup,
                    iconName: template.iconName,
                    baseXP: template.baseXP
                ))
            }

            if exercises.count >= targetCount { break }
        }

        // If we still need more (sparse muscle groups), fill from remaining
        if exercises.count < targetCount {
            let remaining = templates.filter { !usedNames.contains($0.name) }
            var shuffled = remaining
            shuffled.shuffle(using: &rng)
            for template in shuffled {
                guard exercises.count < targetCount else { break }
                exercises.append(PlannedExercise(
                    templateName: template.name,
                    workoutType: template.workoutType,
                    muscleGroup: template.muscleGroup,
                    iconName: template.iconName,
                    baseXP: template.baseXP
                ))
            }
        }

        return exercises
    }

    private static func selectCardioExercise(
        from templates: [WorkoutTemplate],
        index: Int,
        rng: inout SeededRNG
    ) -> PlannedExercise? {
        guard !templates.isEmpty else { return nil }
        var shuffled = templates
        shuffled.shuffle(using: &rng)
        let template = shuffled[index % shuffled.count]
        return PlannedExercise(
            templateName: template.name,
            workoutType: template.workoutType,
            muscleGroup: nil,
            iconName: template.iconName,
            baseXP: template.baseXP
        )
    }

    // MARK: - Equipment Filtering

    private static func filterTemplates(
        _ templates: [WorkoutTemplate],
        forEquipment equipment: [EquipmentAccess]
    ) -> [WorkoutTemplate] {
        let equipmentSet = Set(equipment)
        return templates.filter { template in
            guard !template.isCustom else { return false }
            guard let requirements = templateEquipment[template.name] else {
                return true // Unknown templates are always available
            }
            return !equipmentSet.isDisjoint(with: requirements)
        }
    }
}
