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
        VStack(spacing: 0) {
            // Custom pixel title bar
            HStack {
                Button {
                    dismiss()
                } label: {
                    PixelText("CANCEL", size: .small)
                }

                Spacer()

                PixelText("CUSTOM WORKOUT", size: .medium)

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
                    // Workout name
                    PixelPanel(title: "NAME") {
                        TextField("E.G. MORNING HIIT", text: $workoutName)
                            .font(.custom("Menlo-Bold", size: PixelFontSize.medium.pointSize))
                            .foregroundColor(PixelTheme.text)
                            .textInputAutocapitalization(.characters)
                    }

                    // Workout type
                    PixelPanel(title: "TYPE") {
                        HStack(spacing: PixelScale.px(2)) {
                            PixelButton(
                                "CARDIO",
                                style: workoutType == .cardio ? .primary : .secondary
                            ) {
                                workoutType = .cardio
                            }

                            PixelButton(
                                "STRENGTH",
                                style: workoutType == .strength ? .primary : .secondary
                            ) {
                                workoutType = .strength
                            }
                        }
                    }

                    // Muscle group (for strength only)
                    if workoutType == .strength {
                        PixelPanel(title: "MUSCLE GROUP") {
                            VStack(spacing: PixelScale.px(1)) {
                                // Row 1
                                HStack(spacing: PixelScale.px(1)) {
                                    muscleGroupButton(.fullBody)
                                    muscleGroupButton(.chest)
                                    muscleGroupButton(.back)
                                }
                                // Row 2
                                HStack(spacing: PixelScale.px(1)) {
                                    muscleGroupButton(.legs)
                                    muscleGroupButton(.shoulders)
                                    muscleGroupButton(.core)
                                }
                            }
                        }

                        // Uses weight toggle
                        PixelPanel(title: "OPTIONS") {
                            VStack(spacing: PixelScale.px(2)) {
                                Button {
                                    usesWeight.toggle()
                                } label: {
                                    HStack {
                                        PixelText("USES WEIGHT", size: .small)
                                        Spacer()
                                        PixelCheckbox(isChecked: usesWeight)
                                    }
                                }
                                .buttonStyle(.plain)

                                PixelText("TURN OFF FOR BODYWEIGHT", size: .small, color: PixelTheme.textSecondary)
                            }
                        }
                    }

                    // Save as template toggle
                    PixelPanel(title: "SAVE") {
                        VStack(spacing: PixelScale.px(2)) {
                            Button {
                                saveAsTemplate.toggle()
                            } label: {
                                HStack {
                                    PixelText("SAVE AS TEMPLATE", size: .small)
                                    Spacer()
                                    PixelCheckbox(isChecked: saveAsTemplate)
                                }
                            }
                            .buttonStyle(.plain)

                            PixelText("REUSE FROM QUICK WORKOUT", size: .small, color: PixelTheme.textSecondary)
                        }
                    }

                    Spacer(minLength: PixelScale.px(4))

                    // Continue button
                    PixelButton("CONTINUE >", style: .primary) {
                        showInputView = true
                    }
                    .disabled(!isValid)
                    .opacity(isValid ? 1 : 0.5)
                }
                .padding(PixelScale.px(2))
            }
        }
        .background(PixelTheme.background)
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

    @ViewBuilder
    private func muscleGroupButton(_ group: MuscleGroup) -> some View {
        Button {
            muscleGroup = group
        } label: {
            PixelText(
                group.displayName.uppercased(),
                size: .small,
                color: muscleGroup == group ? PixelTheme.gbLightest : PixelTheme.text
            )
            .padding(.horizontal, PixelScale.px(2))
            .padding(.vertical, PixelScale.px(1))
            .background(muscleGroup == group ? PixelTheme.gbDark : PixelTheme.cardBackground)
            .pixelOutline()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Custom Workout Input Sheet

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
            pet: player.pet,
            weight: workoutType == .strength && usesWeight ? weight : nil,
            reps: workoutType == .strength ? reps : nil,
            sets: workoutType == .strength ? sets : nil,
            durationMinutes: workoutType == .cardio ? durationMinutes : nil,
            steps: Int(steps),
            calories: Int(calories)
        )
    }

    private var petBonusText: String? {
        XPCalculator.petBonusDescription(pet: player.pet, workoutType: workoutType)
    }

    private var essenceEarned: Int {
        PetManager.essenceEarnedForWorkout(xp: estimatedXP)
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
                    // Header
                    PixelPanel(title: workoutName.uppercased()) {
                        HStack(spacing: PixelScale.px(2)) {
                            PixelIconView(
                                icon: workoutType == .cardio ? .run : .dumbbell,
                                size: 24
                            )

                            PixelText(
                                workoutType == .cardio ? "CARDIO" : "STRENGTH",
                                size: .small,
                                color: PixelTheme.textSecondary
                            )

                            Spacer()
                        }
                    }

                    // Inputs based on type
                    if workoutType == .strength {
                        strengthInputsView
                    } else {
                        cardioInputsView
                    }

                    // XP Preview
                    xpPreviewView

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

    private var strengthInputsView: some View {
        VStack(spacing: PixelScale.px(2)) {
            // Weight (only if usesWeight is true)
            if usesWeight {
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
        }
    }

    // MARK: - Cardio Inputs

    private var cardioInputsView: some View {
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

    // MARK: - XP Preview

    private var xpPreviewView: some View {
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

                // Pet bonus
                if let petBonus = petBonusText {
                    HStack(spacing: PixelScale.px(1)) {
                        PixelIconView(icon: .paw, size: 12)
                        PixelText(petBonus.uppercased(), size: .small, color: PixelTheme.textSecondary)
                        Spacer()
                    }
                }

                // Streak bonus
                if let bonus = XPCalculator.streakBonusDescription(streak: player.currentStreak) {
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
