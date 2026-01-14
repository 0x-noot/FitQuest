import SwiftUI
import SwiftData

struct QuickWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<WorkoutTemplate> { !$0.isCustom }) private var defaultTemplates: [WorkoutTemplate]
    @Query(filter: #Predicate<WorkoutTemplate> { $0.isCustom }) private var customTemplates: [WorkoutTemplate]

    let player: Player
    let onComplete: (Workout) -> Void

    @State private var selectedTemplate: WorkoutTemplate?

    private var cardioTemplates: [WorkoutTemplate] {
        defaultTemplates.filter { $0.workoutType == .cardio }
    }

    private var strengthTemplates: [WorkoutTemplate] {
        defaultTemplates.filter { $0.workoutType == .strength }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Cardio section
                    workoutSection(title: "Cardio", templates: cardioTemplates)

                    // Strength section
                    workoutSection(title: "Strength", templates: strengthTemplates)

                    // Custom workouts section
                    if !customTemplates.isEmpty {
                        workoutSection(title: "My Workouts", templates: customTemplates)
                    }
                }
                .padding(20)
            }
            .background(Theme.background)
            .navigationTitle("Quick Workout")
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

    private func workoutSection(title: String, templates: [WorkoutTemplate]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.textMuted)
                .tracking(1)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(templates) { template in
                    WorkoutTemplateButton(template: template) {
                        selectedTemplate = template
                    }
                }
            }
        }
    }
}

struct WorkoutTemplateButton: View {
    let template: WorkoutTemplate
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: template.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(template.workoutType == .cardio ? Theme.secondary : Theme.primary)

                Text(template.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Theme.elevated, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    QuickWorkoutSheet(
        player: Player(),
        onComplete: { _ in }
    )
    .modelContainer(for: [Player.self, Workout.self, WorkoutTemplate.self], inMemory: true)
}
