import SwiftUI
import SwiftData

struct CustomWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let player: Player
    let onComplete: (Workout) -> Void

    @State private var workoutName: String = ""
    @State private var workoutType: WorkoutType = .strength
    @State private var muscleGroup: MuscleGroup = .fullBody
    @State private var usesWeight: Bool = true
    @State private var saveAsTemplate: Bool = true
    @State private var showInputView = false

    private var isValid: Bool {
        !workoutName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Workout name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Workout Name")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Theme.textSecondary)

                        TextField("e.g., Morning HIIT", text: $workoutName)
                            .font(.system(size: 18))
                            .foregroundColor(Theme.textPrimary)
                            .padding(16)
                            .background(Theme.cardBackground)
                            .cornerRadius(12)
                    }

                    // Workout type
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Type")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Theme.textSecondary)

                        Picker("Type", selection: $workoutType) {
                            Text("Cardio").tag(WorkoutType.cardio)
                            Text("Strength").tag(WorkoutType.strength)
                        }
                        .pickerStyle(.segmented)
                    }

                    // Muscle group (for strength only)
                    if workoutType == .strength {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Muscle Group")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Theme.textSecondary)

                            Picker("Muscle Group", selection: $muscleGroup) {
                                ForEach(MuscleGroup.allCases) { group in
                                    Text(group.displayName).tag(group)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.cardBackground)
                            .cornerRadius(12)
                        }

                        // Uses weight toggle
                        Toggle(isOn: $usesWeight) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Uses Weight")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Theme.textPrimary)
                                Text("Turn off for bodyweight exercises")
                                    .font(.system(size: 12))
                                    .foregroundColor(Theme.textMuted)
                            }
                        }
                        .tint(Theme.primary)
                        .padding(16)
                        .background(Theme.cardBackground)
                        .cornerRadius(12)
                    }

                    // Save as template toggle
                    Toggle(isOn: $saveAsTemplate) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Save as template")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Theme.textPrimary)
                            Text("Reuse this workout from Quick Workout")
                                .font(.system(size: 12))
                                .foregroundColor(Theme.textMuted)
                        }
                    }
                    .tint(Theme.primary)
                    .padding(16)
                    .background(Theme.cardBackground)
                    .cornerRadius(12)

                    Spacer(minLength: 40)

                    // Continue button
                    PrimaryButton("Continue to Log", icon: "arrow.right") {
                        showInputView = true
                    }
                    .disabled(!isValid)
                    .opacity(isValid ? 1 : 0.5)
                }
                .padding(20)
            }
            .background(Theme.background)
            .navigationTitle("Custom Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.cardBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.textSecondary)
                }
            }
            .sheet(isPresented: $showInputView) {
                CustomWorkoutInputSheet(
                    workoutName: workoutName,
                    workoutType: workoutType,
                    muscleGroup: muscleGroup,
                    usesWeight: usesWeight,
                    saveAsTemplate: saveAsTemplate,
                    player: player,
                    modelContext: modelContext,
                    onComplete: { workout in
                        onComplete(workout)
                        dismiss()
                    }
                )
            }
        }
    }
}

struct CustomWorkoutInputSheet: View {
    @Environment(\.dismiss) private var dismiss

    let workoutName: String
    let workoutType: WorkoutType
    let muscleGroup: MuscleGroup
    let usesWeight: Bool
    let saveAsTemplate: Bool
    let player: Player
    let modelContext: ModelContext
    let onComplete: (Workout) -> Void

    // Strength inputs
    @State private var weight: Double = 135
    @State private var reps: Int = 10
    @State private var sets: Int = 3

    // Cardio inputs
    @State private var durationMinutes: Int = 30
    @State private var steps: String = ""
    @State private var calories: String = ""

    private var estimatedXP: Int {
        XPCalculator.calculateTotalXP(
            baseXP: XPCalculator.defaultBaseXP,
            workoutType: workoutType,
            streak: player.currentStreak,
            isFirstWorkoutOfDay: player.isFirstWorkoutOfDay,
            weight: workoutType == .strength && usesWeight ? weight : nil,
            reps: workoutType == .strength ? reps : nil,
            sets: workoutType == .strength ? sets : nil,
            durationMinutes: workoutType == .cardio ? durationMinutes : nil,
            steps: Int(steps),
            calories: Int(calories)
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack(spacing: 12) {
                        Image(systemName: workoutType == .cardio ? "figure.run" : "dumbbell.fill")
                            .font(.system(size: 28))
                            .foregroundColor(workoutType == .cardio ? Theme.secondary : Theme.primary)

                        Text(workoutName)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Theme.textPrimary)

                        Spacer()
                    }

                    // Inputs based on type
                    if workoutType == .strength {
                        strengthInputsView
                    } else {
                        cardioInputsView
                    }

                    Divider()
                        .background(Theme.elevated)

                    // XP Preview
                    xpPreviewView

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

    private var strengthInputsView: some View {
        VStack(spacing: 20) {
            // Weight (only if usesWeight is true)
            if usesWeight {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weight")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.textSecondary)

                    HStack {
                        Button { weight = max(0, weight - 5) } label: {
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

                        Button { weight += 5 } label: {
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
            }

            HStack(spacing: 16) {
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
        }
    }

    private var cardioInputsView: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Duration")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.textSecondary)

                HStack {
                    Button { durationMinutes = max(1, durationMinutes - 5) } label: {
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

                    Button { durationMinutes += 5 } label: {
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

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Steps (optional)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.textSecondary)

                    TextField("0", text: $steps)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.textPrimary)
                        .keyboardType(.numberPad)
                }
                .padding(16)
                .background(Theme.cardBackground)
                .cornerRadius(12)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Calories (optional)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.textSecondary)

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

    private var xpPreviewView: some View {
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

            if let bonus = XPCalculator.streakBonusDescription(streak: player.currentStreak) {
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
        }
        .padding(16)
        .background(Theme.elevated)
        .cornerRadius(12)
    }

    private func completeWorkout() {
        // Create template if requested
        if saveAsTemplate {
            let template = WorkoutTemplate(
                name: workoutName,
                workoutType: workoutType,
                muscleGroup: workoutType == .strength ? muscleGroup : nil,
                isCustom: true,
                iconName: workoutType == .cardio ? "figure.run" : "dumbbell.fill",
                baseXP: XPCalculator.defaultBaseXP
            )
            template.defaultWeight = workoutType == .strength && usesWeight ? weight : nil
            template.defaultReps = workoutType == .strength ? reps : nil
            template.defaultSets = workoutType == .strength ? sets : nil
            template.defaultDuration = workoutType == .cardio ? durationMinutes : nil
            modelContext.insert(template)
        }

        // Create workout
        let workout: Workout
        if workoutType == .strength {
            workout = Workout(
                name: workoutName,
                workoutType: .strength,
                xpEarned: estimatedXP,
                weight: usesWeight ? weight : nil,
                reps: reps,
                sets: sets
            )
        } else {
            workout = Workout(
                name: workoutName,
                workoutType: .cardio,
                xpEarned: estimatedXP,
                steps: Int(steps),
                durationMinutes: durationMinutes,
                caloriesBurned: Int(calories)
            )
        }

        onComplete(workout)
    }
}

#Preview {
    CustomWorkoutSheet(
        player: Player(),
        onComplete: { _ in }
    )
    .modelContainer(for: [Player.self, Workout.self, WorkoutTemplate.self], inMemory: true)
}
