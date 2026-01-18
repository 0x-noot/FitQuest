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

    private var walkingIntensityBonus: (incline: Int, speed: Int) {
        XPCalculator.calculateWalkingIntensityBonus(incline: incline, speed: speed)
    }

    private var streakBonusText: String? {
        XPCalculator.streakBonusDescription(streak: player.currentStreak)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Workout header
                    HStack(spacing: 12) {
                        Image(systemName: template.iconName)
                            .font(.system(size: 28))
                            .foregroundColor(template.workoutType == .cardio ? Theme.secondary : Theme.primary)

                        Text(template.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Theme.textPrimary)

                        Spacer()
                    }

                    // Input fields
                    if template.workoutType == .strength {
                        strengthInputs
                    } else {
                        cardioInputs
                    }

                    Divider()
                        .background(Theme.elevated)

                    // XP Preview
                    xpPreview

                    // Complete button
                    PrimaryButton("Complete Workout", icon: "checkmark") {
                        completeWorkout()
                    }
                    .padding(.top, 8)
                }
                .padding(20)
            }
            .background(Theme.background)
            .navigationTitle("Log Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.cardBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") {
                        dismiss()
                    }
                    .foregroundColor(Theme.textSecondary)
                }
            }
        }
    }

    private var strengthInputs: some View {
        VStack(spacing: 20) {
            // Weight
            VStack(alignment: .leading, spacing: 8) {
                Text("Weight")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.textSecondary)

                HStack {
                    Button {
                        weight = max(0, weight - 5)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Theme.primary)
                    }

                    TextField("0", value: $weight, format: .number)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                        .frame(width: 100)

                    Text("lbs")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Theme.textMuted)

                    Button {
                        weight += 5
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Theme.primary)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(16)
            .background(Theme.cardBackground)
            .cornerRadius(12)

            HStack(spacing: 16) {
                // Reps
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reps")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.textSecondary)

                    Stepper(value: $reps, in: 1...100) {
                        Text("\(reps)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.textPrimary)
                    }
                }
                .padding(16)
                .background(Theme.cardBackground)
                .cornerRadius(12)

                // Sets
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sets")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.textSecondary)

                    Stepper(value: $sets, in: 1...20) {
                        Text("\(sets)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.textPrimary)
                    }
                }
                .padding(16)
                .background(Theme.cardBackground)
                .cornerRadius(12)
            }

            // Volume display
            if weight > 0 && reps > 0 && sets > 0 {
                HStack {
                    Text("Total Volume:")
                        .foregroundColor(Theme.textSecondary)
                    Text("\(Int(weight * Double(reps * sets)).formatted()) lbs")
                        .foregroundColor(Theme.textPrimary)
                        .fontWeight(.semibold)
                }
                .font(.system(size: 14))
            }
        }
    }

    private var cardioInputs: some View {
        VStack(spacing: 20) {
            // Duration
            VStack(alignment: .leading, spacing: 8) {
                Text("Duration")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.textSecondary)

                HStack {
                    Button {
                        durationMinutes = max(1, durationMinutes - 5)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Theme.secondary)
                    }

                    Text("\(durationMinutes)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.textPrimary)
                        .frame(width: 80)

                    Text("min")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Theme.textMuted)

                    Button {
                        durationMinutes += 5
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Theme.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(16)
            .background(Theme.cardBackground)
            .cornerRadius(12)

            // Walking-specific inputs
            if isWalkingWorkout {
                walkingIntensityInputs
            }

            HStack(spacing: 16) {
                // Steps (optional)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Steps")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Theme.textSecondary)
                        Text("(optional)")
                            .font(.system(size: 11))
                            .foregroundColor(Theme.textMuted)
                    }

                    TextField("0", text: $steps)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.textPrimary)
                        .keyboardType(.numberPad)
                }
                .padding(16)
                .background(Theme.cardBackground)
                .cornerRadius(12)

                // Calories (optional)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Calories")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Theme.textSecondary)
                        Text("(optional)")
                            .font(.system(size: 11))
                            .foregroundColor(Theme.textMuted)
                    }

                    TextField("0", text: $calories)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.textPrimary)
                        .keyboardType(.numberPad)
                }
                .padding(16)
                .background(Theme.cardBackground)
                .cornerRadius(12)
            }
        }
    }

    private var walkingIntensityInputs: some View {
        VStack(spacing: 16) {
            // Incline
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Incline")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.textSecondary)

                    Spacer()

                    Text("\(String(format: "%.1f", incline))%")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.textPrimary)

                    if walkingIntensityBonus.incline > 0 {
                        Text("+\(walkingIntensityBonus.incline)%")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Theme.success)
                    }
                }

                Slider(value: $incline, in: 0...15, step: 0.5)
                    .tint(Theme.secondary)

                HStack {
                    Text("Flat")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.textMuted)
                    Spacer()
                    Text("15%")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.textMuted)
                }
            }
            .padding(16)
            .background(Theme.cardBackground)
            .cornerRadius(12)

            // Speed
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Speed")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.textSecondary)

                    Spacer()

                    Text("\(String(format: "%.1f", speed)) mph")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.textPrimary)

                    if walkingIntensityBonus.speed > 0 {
                        Text("+\(walkingIntensityBonus.speed)%")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Theme.success)
                    }
                }

                Slider(value: $speed, in: 1.0...5.0, step: 0.1)
                    .tint(Theme.secondary)

                HStack {
                    Text("Slow (1.0)")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.textMuted)
                    Spacer()
                    Text("Fast (5.0)")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.textMuted)
                }
            }
            .padding(16)
            .background(Theme.cardBackground)
            .cornerRadius(12)
        }
    }

    private var xpPreview: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Estimated XP")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Theme.textSecondary)

                Spacer()

                HStack(spacing: 4) {
                    Text("+\(estimatedXP)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.success)

                    Image(systemName: "bolt.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Theme.warning)
                }
            }

            // Walking intensity bonuses
            if isWalkingWorkout && (walkingIntensityBonus.incline > 0 || walkingIntensityBonus.speed > 0) {
                HStack {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.secondary)

                    if walkingIntensityBonus.incline > 0 && walkingIntensityBonus.speed > 0 {
                        Text("+\(walkingIntensityBonus.incline)% incline, +\(walkingIntensityBonus.speed)% speed bonus")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Theme.secondary)
                    } else if walkingIntensityBonus.incline > 0 {
                        Text("+\(walkingIntensityBonus.incline)% incline bonus")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Theme.secondary)
                    } else {
                        Text("+\(walkingIntensityBonus.speed)% speed bonus")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Theme.secondary)
                    }
                    Spacer()
                }
            }

            if let bonus = streakBonusText {
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.streak)
                    Text(bonus)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.streak)
                    Spacer()
                }
            }

            if player.isFirstWorkoutOfDay {
                HStack {
                    Image(systemName: "sunrise.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.warning)
                    Text("+\(XPCalculator.dailyBonusXP) first workout bonus")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.warning)
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(Theme.elevated)
        .cornerRadius(12)
    }

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
