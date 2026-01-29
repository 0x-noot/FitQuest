import SwiftUI

struct WorkoutInputSheet: View {
    @Environment(\.dismiss) private var dismiss

    let template: WorkoutTemplate
    let player: Player
    let onComplete: (Workout) -> Void

    // Strength inputs
    @State private var weight: Double = 135
    @State private var reps: Int = 10
    @State private var sets: Int = 3

    // Cardio inputs
    @State private var durationMinutes: Int = 30
    @State private var steps: String = ""
    @State private var calories: String = ""

    // Walking-specific inputs
    @State private var incline: Double = 0
    @State private var speed: Double = 3.0

    private var isWalkingWorkout: Bool {
        template.name == "Walk"
    }

    private var estimatedXP: Int {
        let stepsValue = Int(steps)
        let caloriesValue = Int(calories)

        return XPCalculator.calculateTotalXP(
            baseXP: template.baseXP,
            workoutType: template.workoutType,
            streak: player.currentStreak,
            isFirstWorkoutOfDay: player.isFirstWorkoutOfDay,
            pet: player.pet,
            weight: template.workoutType == .strength ? weight : nil,
            reps: template.workoutType == .strength ? reps : nil,
            sets: template.workoutType == .strength ? sets : nil,
            durationMinutes: template.workoutType == .cardio ? durationMinutes : nil,
            steps: stepsValue,
            calories: caloriesValue,
            incline: isWalkingWorkout ? incline : nil,
            speed: isWalkingWorkout ? speed : nil
        )
    }

    private var petBonusText: String? {
        XPCalculator.petBonusDescription(pet: player.pet, workoutType: template.workoutType)
    }

    private var essenceEarned: Int {
        PetManager.essenceEarnedForWorkout(xp: estimatedXP)
    }

    private var walkingIntensityBonus: (inclineBonus: Int, speedBonus: Int) {
        XPCalculator.calculateWalkingIntensityBonus(incline: incline, speed: speed)
    }

    private var streakBonusText: String? {
        XPCalculator.streakBonusDescription(streak: player.currentStreak)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Custom pixel title bar
            HStack {
                Button {
                    dismiss()
                } label: {
                    PixelText("< BACK", size: .small)
                }

                Spacer()

                PixelText("LOG WORKOUT", size: .medium)

                Spacer()

                // Spacer for balance
                PixelText("      ", size: .small)
            }
            .padding(.horizontal, PixelScale.px(2))
            .padding(.vertical, PixelScale.px(2))
            .background(PixelTheme.gbDark)

            Rectangle()
                .fill(PixelTheme.border)
                .frame(height: PixelScale.px(1))

            // Content
            ScrollView {
                VStack(spacing: PixelScale.px(3)) {
                    // Workout header
                    PixelPanel(title: template.name.uppercased()) {
                        HStack(spacing: PixelScale.px(2)) {
                            PixelIconView(
                                icon: template.workoutType == .cardio ? .run : .dumbbell,
                                size: 24
                            )

                            PixelText(
                                template.workoutType == .cardio ? "CARDIO" : "STRENGTH",
                                size: .small,
                                color: PixelTheme.textSecondary
                            )

                            Spacer()

                            PixelText("BASE: \(template.baseXP) XP", size: .small, color: PixelTheme.textSecondary)
                        }
                    }

                    // Input fields
                    if template.workoutType == .strength {
                        strengthInputs
                    } else {
                        cardioInputs
                    }

                    // XP Preview
                    xpPreview

                    // Complete button
                    PixelButton("COMPLETE", style: .primary) {
                        completeWorkout()
                    }
                    .padding(.top, PixelScale.px(2))
                }
                .padding(PixelScale.px(2))
            }
        }
        .background(PixelTheme.background)
    }

    // MARK: - Strength Inputs

    private var strengthInputs: some View {
        VStack(spacing: PixelScale.px(2)) {
            // Weight
            PixelPanel(title: "WEIGHT") {
                HStack(spacing: PixelScale.px(2)) {
                    PixelSmallButton(label: "-5") {
                        weight = max(0, weight - 5)
                    }

                    Spacer()

                    PixelText("\(Int(weight))", size: .xlarge)

                    PixelText("LBS", size: .small, color: PixelTheme.textSecondary)

                    Spacer()

                    PixelSmallButton(label: "+5") {
                        weight += 5
                    }
                }
            }

            HStack(spacing: PixelScale.px(2)) {
                // Reps
                PixelPanel(title: "REPS") {
                    HStack(spacing: PixelScale.px(1)) {
                        PixelSmallButton(label: "-") {
                            reps = max(1, reps - 1)
                        }

                        Spacer()

                        PixelText("\(reps)", size: .large)

                        Spacer()

                        PixelSmallButton(label: "+") {
                            reps += 1
                        }
                    }
                }

                // Sets
                PixelPanel(title: "SETS") {
                    HStack(spacing: PixelScale.px(1)) {
                        PixelSmallButton(label: "-") {
                            sets = max(1, sets - 1)
                        }

                        Spacer()

                        PixelText("\(sets)", size: .large)

                        Spacer()

                        PixelSmallButton(label: "+") {
                            sets += 1
                        }
                    }
                }
            }

            // Volume display
            if weight > 0 && reps > 0 && sets > 0 {
                HStack {
                    PixelText("VOLUME:", size: .small, color: PixelTheme.textSecondary)
                    Spacer()
                    PixelText("\(Int(weight * Double(reps * sets))) LBS", size: .small)
                }
                .padding(.horizontal, PixelScale.px(2))
            }
        }
    }

    // MARK: - Cardio Inputs

    private var cardioInputs: some View {
        VStack(spacing: PixelScale.px(2)) {
            // Duration
            PixelPanel(title: "DURATION") {
                HStack(spacing: PixelScale.px(2)) {
                    PixelSmallButton(label: "-5") {
                        durationMinutes = max(1, durationMinutes - 5)
                    }

                    Spacer()

                    PixelText("\(durationMinutes)", size: .xlarge)

                    PixelText("MIN", size: .small, color: PixelTheme.textSecondary)

                    Spacer()

                    PixelSmallButton(label: "+5") {
                        durationMinutes += 5
                    }
                }
            }

            // Walking-specific inputs
            if isWalkingWorkout {
                walkingIntensityInputs
            }

            HStack(spacing: PixelScale.px(2)) {
                // Steps (optional)
                PixelPanel(title: "STEPS") {
                    VStack(spacing: PixelScale.px(1)) {
                        PixelText("(OPTIONAL)", size: .small, color: PixelTheme.textSecondary)
                        TextField("0", text: $steps)
                            .font(.custom("Menlo-Bold", size: PixelFontSize.large.pointSize))
                            .foregroundColor(PixelTheme.text)
                            .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                    }
                }

                // Calories (optional)
                PixelPanel(title: "CALORIES") {
                    VStack(spacing: PixelScale.px(1)) {
                        PixelText("(OPTIONAL)", size: .small, color: PixelTheme.textSecondary)
                        TextField("0", text: $calories)
                            .font(.custom("Menlo-Bold", size: PixelFontSize.large.pointSize))
                            .foregroundColor(PixelTheme.text)
                            .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                    }
                }
            }
        }
    }

    // MARK: - Walking Intensity Inputs

    private var walkingIntensityInputs: some View {
        VStack(spacing: PixelScale.px(2)) {
            // Incline
            PixelPanel(title: "INCLINE") {
                VStack(spacing: PixelScale.px(1)) {
                    HStack {
                        PixelText(String(format: "%.1f%%", incline), size: .medium)
                        Spacer()
                        if walkingIntensityBonus.inclineBonus > 0 {
                            PixelText("+\(walkingIntensityBonus.inclineBonus)%", size: .small, color: PixelTheme.gbDark)
                        }
                    }

                    // Pixel-style slider using buttons
                    HStack(spacing: PixelScale.px(1)) {
                        PixelSmallButton(label: "-") {
                            incline = max(0, incline - 0.5)
                        }

                        PixelProgressBar(
                            progress: incline / 15.0,
                            segments: 10,
                            height: PixelScale.px(2),
                            onSegmentTap: { segment in
                                // Each segment represents 1.5% incline (15% / 10 segments)
                                // Tap on segment sets value to the end of that segment
                                incline = Double(segment + 1) * 1.5
                            }
                        )

                        PixelSmallButton(label: "+") {
                            incline = min(15, incline + 0.5)
                        }
                    }

                    HStack {
                        PixelText("FLAT", size: .small, color: PixelTheme.textSecondary)
                        Spacer()
                        PixelText("15%", size: .small, color: PixelTheme.textSecondary)
                    }
                }
            }

            // Speed
            PixelPanel(title: "SPEED") {
                VStack(spacing: PixelScale.px(1)) {
                    HStack {
                        PixelText(String(format: "%.1f MPH", speed), size: .medium)
                        Spacer()
                        if walkingIntensityBonus.speedBonus > 0 {
                            PixelText("+\(walkingIntensityBonus.speedBonus)%", size: .small, color: PixelTheme.gbDark)
                        }
                    }

                    // Pixel-style slider using buttons
                    HStack(spacing: PixelScale.px(1)) {
                        PixelSmallButton(label: "-") {
                            speed = max(1.0, speed - 0.1)
                        }

                        PixelProgressBar(
                            progress: (speed - 1.0) / 4.0,
                            segments: 10,
                            height: PixelScale.px(2),
                            onSegmentTap: { segment in
                                // Speed range is 1.0-5.0 (4.0 range), 10 segments = 0.4 per segment
                                // Tap on segment sets value to the end of that segment
                                speed = 1.0 + Double(segment + 1) * 0.4
                            }
                        )

                        PixelSmallButton(label: "+") {
                            speed = min(5.0, speed + 0.1)
                        }
                    }

                    HStack {
                        PixelText("1.0", size: .small, color: PixelTheme.textSecondary)
                        Spacer()
                        PixelText("5.0", size: .small, color: PixelTheme.textSecondary)
                    }
                }
            }
        }
    }

    // MARK: - XP Preview

    private var xpPreview: some View {
        PixelPanel(title: "REWARDS") {
            VStack(spacing: PixelScale.px(1)) {
                // Main XP display
                HStack {
                    if let pet = player.pet {
                        PixelText("\(pet.name) EARNS", size: .small, color: PixelTheme.textSecondary)
                    } else {
                        PixelText("XP EARNED", size: .small, color: PixelTheme.textSecondary)
                    }

                    Spacer()

                    HStack(spacing: PixelScale.px(1)) {
                        PixelText("+\(estimatedXP)", size: .large)
                        PixelText("XP", size: .small)
                    }
                }

                Rectangle()
                    .fill(PixelTheme.border)
                    .frame(height: PixelScale.px(1))
                    .padding(.vertical, PixelScale.px(1))

                // Walking intensity bonuses
                if isWalkingWorkout && (walkingIntensityBonus.inclineBonus > 0 || walkingIntensityBonus.speedBonus > 0) {
                    HStack(spacing: PixelScale.px(1)) {
                        PixelIconView(icon: .bolt, size: 12)
                        if walkingIntensityBonus.inclineBonus > 0 && walkingIntensityBonus.speedBonus > 0 {
                            PixelText("+\(walkingIntensityBonus.inclineBonus)% INC +\(walkingIntensityBonus.speedBonus)% SPD", size: .small, color: PixelTheme.textSecondary)
                        } else if walkingIntensityBonus.inclineBonus > 0 {
                            PixelText("+\(walkingIntensityBonus.inclineBonus)% INCLINE", size: .small, color: PixelTheme.textSecondary)
                        } else {
                            PixelText("+\(walkingIntensityBonus.speedBonus)% SPEED", size: .small, color: PixelTheme.textSecondary)
                        }
                        Spacer()
                    }
                }

                // Pet bonus
                if let petBonus = petBonusText {
                    HStack(spacing: PixelScale.px(1)) {
                        PixelIconView(icon: .paw, size: 12)
                        PixelText(petBonus.uppercased(), size: .small, color: PixelTheme.textSecondary)
                        Spacer()
                    }
                }

                // Streak bonus
                if let bonus = streakBonusText {
                    HStack(spacing: PixelScale.px(1)) {
                        PixelIconView(icon: .flame, size: 12)
                        PixelText(bonus.uppercased(), size: .small, color: PixelTheme.textSecondary)
                        Spacer()
                    }
                }

                // First workout bonus
                if player.isFirstWorkoutOfDay {
                    HStack(spacing: PixelScale.px(1)) {
                        PixelIconView(icon: .sun, size: 12)
                        PixelText("+\(XPCalculator.dailyBonusXP) FIRST WORKOUT", size: .small, color: PixelTheme.textSecondary)
                        Spacer()
                    }
                }

                // Essence earned
                if player.pet != nil {
                    HStack(spacing: PixelScale.px(1)) {
                        PixelIconView(icon: .sparkle, size: 12)
                        PixelText("+\(essenceEarned) ESSENCE", size: .small, color: PixelTheme.textSecondary)
                        Spacer()
                    }
                }
            }
        }
    }

    // MARK: - Complete Workout

    private func completeWorkout() {
        let workout: Workout

        if template.workoutType == .strength {
            workout = Workout(
                name: template.name,
                workoutType: .strength,
                xpEarned: estimatedXP,
                weight: weight,
                reps: reps,
                sets: sets
            )
        } else {
            workout = Workout(
                name: template.name,
                workoutType: .cardio,
                xpEarned: estimatedXP,
                steps: Int(steps),
                durationMinutes: durationMinutes,
                caloriesBurned: Int(calories),
                incline: isWalkingWorkout ? incline : nil,
                speed: isWalkingWorkout ? speed : nil
            )
        }

        onComplete(workout)
    }
}

#Preview {
    WorkoutInputSheet(
        template: WorkoutTemplate(name: "Bench Press", workoutType: .strength, baseXP: 70),
        player: {
            let p = Player()
            p.currentStreak = 5
            return p
        }(),
        onComplete: { _ in }
    )
}
