import SwiftUI

struct Achievement: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let color: Color
    let isEarned: (Player) -> Bool

    static let all: [Achievement] = [
        Achievement(
            id: "first_steps",
            name: "First Steps",
            description: "Complete your first workout",
            icon: "figure.walk",
            color: Theme.success,
            isEarned: { ($0.workouts ?? []).count >= 1 }
        ),
        Achievement(
            id: "week_warrior",
            name: "Week Warrior",
            description: "Maintain a 7-day streak",
            icon: "flame.fill",
            color: Theme.streak,
            isEarned: { $0.highestStreak >= 7 }
        ),
        Achievement(
            id: "dedicated",
            name: "Dedicated",
            description: "Maintain a 14-day streak",
            icon: "flame.fill",
            color: Color.orange,
            isEarned: { $0.highestStreak >= 14 }
        ),
        Achievement(
            id: "unstoppable",
            name: "Unstoppable",
            description: "Maintain a 30-day streak",
            icon: "flame.circle.fill",
            color: Color.red,
            isEarned: { $0.highestStreak >= 30 }
        ),
        Achievement(
            id: "century",
            name: "Century",
            description: "Complete 100 workouts",
            icon: "100.circle.fill",
            color: Theme.primary,
            isEarned: { ($0.workouts ?? []).count >= 100 }
        ),
        Achievement(
            id: "pet_xp_hunter",
            name: "XP Hunter",
            description: "Help your pet earn 10,000 XP",
            icon: "bolt.circle.fill",
            color: Theme.warning,
            isEarned: { $0.pet?.totalXP ?? 0 >= 10000 }
        ),
        Achievement(
            id: "pet_level_10",
            name: "Rising Star",
            description: "Help your pet reach level 10",
            icon: "sparkles",
            color: Theme.primary,
            isEarned: { $0.pet?.currentLevel ?? 0 >= 10 }
        ),
        Achievement(
            id: "pet_level_25",
            name: "Champion",
            description: "Help your pet reach level 25",
            icon: "star.fill",
            color: Theme.warning,
            isEarned: { $0.pet?.currentLevel ?? 0 >= 25 }
        ),
        Achievement(
            id: "pet_level_50",
            name: "Legend",
            description: "Help your pet reach level 50",
            icon: "crown.fill",
            color: Color.purple,
            isEarned: { $0.pet?.currentLevel ?? 0 >= 50 }
        ),
        Achievement(
            id: "early_bird",
            name: "Early Bird",
            description: "Complete a workout before 9 AM",
            icon: "sunrise.fill",
            color: Color.yellow,
            isEarned: { player in
                (player.workouts ?? []).contains { workout in
                    let hour = Calendar.current.component(.hour, from: workout.completedAt)
                    return hour < 9
                }
            }
        ),
        Achievement(
            id: "night_owl",
            name: "Night Owl",
            description: "Complete a workout after 9 PM",
            icon: "moon.stars.fill",
            color: Theme.secondary,
            isEarned: { player in
                (player.workouts ?? []).contains { workout in
                    let hour = Calendar.current.component(.hour, from: workout.completedAt)
                    return hour >= 21
                }
            }
        )
    ]

    static func earnedCount(for player: Player) -> Int {
        all.filter { $0.isEarned(player) }.count
    }
}
