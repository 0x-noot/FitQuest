import SwiftUI
import SwiftData

// MARK: - Quick Workout Sheet (Pixel Art Style)

struct QuickWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<WorkoutTemplate> { !$0.isCustom }) private var defaultTemplates: [WorkoutTemplate]
    @Query(filter: #Predicate<WorkoutTemplate> { $0.isCustom }) private var customTemplates: [WorkoutTemplate]

    let player: Player
    let onComplete: (Workout) -> Void

    @State private var selectedTemplate: WorkoutTemplate?

    // Cardio templates
    private var cardioTemplates: [WorkoutTemplate] {
        defaultTemplates.filter { $0.workoutType == .cardio }
    }

    // Strength templates
    private var strengthTemplates: [WorkoutTemplate] {
        defaultTemplates.filter { $0.workoutType == .strength }
    }

    // Strength templates grouped by muscle group
    private var strengthByMuscleGroup: [(MuscleGroup, [WorkoutTemplate])] {
        let grouped = Dictionary(grouping: strengthTemplates) { $0.muscleGroup ?? .fullBody }
        return MuscleGroup.allCases.compactMap { group in
            guard let templates = grouped[group], !templates.isEmpty else { return nil }
            return (group, templates)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Button {
                    dismiss()
                } label: {
                    PixelText("X", size: .medium)
                }

                Spacer()

                PixelText("ADD WORKOUT", size: .large)

                Spacer()

                // Spacer for balance
                PixelText(" ", size: .medium)
            }
            .padding(PixelScale.px(2))
            .background(PixelTheme.gbDark)

            // Content
            ScrollView {
                VStack(spacing: PixelScale.px(3)) {
                    // Cardio section
                    if !cardioTemplates.isEmpty {
                        PixelPanel(title: "CARDIO") {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: PixelScale.px(2)) {
                                ForEach(cardioTemplates) { template in
                                    PixelWorkoutButton(template: template) {
                                        selectedTemplate = template
                                    }
                                }
                            }
                        }
                    }

                    // Strength sections grouped by muscle group
                    ForEach(strengthByMuscleGroup, id: \.0) { group, templates in
                        PixelPanel(title: group.displayName.uppercased()) {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: PixelScale.px(2)) {
                                ForEach(templates) { template in
                                    PixelWorkoutButton(template: template) {
                                        selectedTemplate = template
                                    }
                                }
                            }
                        }
                    }

                    // Custom workouts
                    if !customTemplates.isEmpty {
                        PixelPanel(title: "CUSTOM") {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: PixelScale.px(2)) {
                                ForEach(customTemplates) { template in
                                    PixelWorkoutButton(template: template) {
                                        selectedTemplate = template
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(PixelScale.px(2))
            }
        }
        .background(PixelTheme.background)
        .sheet(item: $selectedTemplate) { template in
            WorkoutInputSheet(
                template: template,
                player: player,
                onComplete: { workout in
                    onComplete(workout)
                    dismiss()
                }
            )
        }
    }
}

// MARK: - Pixel Workout Button

struct PixelWorkoutButton: View {
    let template: WorkoutTemplate
    let action: () -> Void

    @State private var isPressed = false

    private var icon: PixelIcon {
        template.workoutType == .cardio ? .run : .dumbbell
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: PixelScale.px(1)) {
                PixelIconView(icon: icon, size: 20, color: PixelTheme.gbLightest)

                PixelText(
                    template.name.uppercased(),
                    size: .small,
                    color: PixelTheme.text
                )
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: PixelScale.px(14))
            .padding(.vertical, PixelScale.px(2))
            .padding(.horizontal, PixelScale.px(1))
            .background(isPressed ? PixelTheme.gbDark : PixelTheme.cardBackground)
            .pixelOutline()
            .offset(y: isPressed ? PixelScale.px(1) : 0)
        }
        .buttonStyle(PixelPressStyle(isPressed: $isPressed))
    }
}

// MARK: - Preview

#Preview {
    QuickWorkoutSheet(
        player: Player(),
        onComplete: { _ in }
    )
    .modelContainer(for: [Player.self, Workout.self, WorkoutTemplate.self], inMemory: true)
}
