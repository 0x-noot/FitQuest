import SwiftUI
import SwiftData

struct AccessoryShopView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var player: Player
    @Bindable var pet: Pet

    @State private var selectedCategory: AccessoryCategory = .hat
    @State private var showPurchaseSuccess = false
    @State private var purchasedAccessory: Accessory?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Balance header
                balanceHeader

                // Category tabs
                categoryTabs

                // Accessory grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(Accessory.accessories(for: selectedCategory), id: \.id) { accessory in
                            AccessoryCard(
                                accessory: accessory,
                                isUnlocked: player.hasUnlocked(accessory),
                                isEquipped: pet.equippedAccessories.contains(accessory.id),
                                canAfford: player.essenceCurrency >= accessory.cost,
                                onTap: {
                                    handleAccessoryTap(accessory)
                                }
                            )
                        }
                    }
                    .padding(16)
                }
            }
            .background(Theme.background)
            .navigationTitle("Accessory Shop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.cardBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.primary)
                }
            }
            .overlay {
                if showPurchaseSuccess, let accessory = purchasedAccessory {
                    purchaseSuccessOverlay(accessory: accessory)
                }
            }
        }
    }

    private var balanceHeader: some View {
        HStack {
            // Pet preview with accessories
            ZStack {
                if let bg = pet.equippedBackground?.backgroundGradient {
                    Circle()
                        .fill(bg)
                        .frame(width: 60, height: 60)
                } else {
                    Circle()
                        .fill(pet.mood.color.opacity(0.2))
                        .frame(width: 60, height: 60)
                }

                Image(systemName: pet.evolutionIconName)
                    .font(.system(size: 28))
                    .foregroundColor(pet.mood.color)

                // Hat overlay
                if let hat = pet.equippedHat {
                    Image(systemName: hat.iconName)
                        .font(.system(size: 14))
                        .foregroundColor(hat.rarity.color)
                        .offset(y: -22)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(pet.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)

                HStack(spacing: 2) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12))
                    Text("\(player.essenceCurrency)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundColor(Theme.warning)
            }

            Spacer()
        }
        .padding(16)
        .background(Theme.cardBackground)
    }

    private var categoryTabs: some View {
        HStack(spacing: 0) {
            ForEach(AccessoryCategory.allCases, id: \.self) { category in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCategory = category
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: category.iconName)
                            .font(.system(size: 20))

                        Text(category.displayName)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(selectedCategory == category ? Theme.primary : Theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedCategory == category ? Theme.primary.opacity(0.1) : Color.clear
                    )
                }
            }
        }
        .background(Theme.elevated)
    }

    private func handleAccessoryTap(_ accessory: Accessory) {
        if player.hasUnlocked(accessory) {
            // Toggle equip
            if pet.equippedAccessories.contains(accessory.id) {
                pet.unequipAccessory(accessory)
            } else {
                pet.equipAccessory(accessory)
            }
            try? modelContext.save()
        } else if AccessoryManager.shared.canPurchase(accessory: accessory, player: player) {
            // Purchase
            if AccessoryManager.shared.purchase(accessory: accessory, player: player) {
                purchasedAccessory = accessory
                withAnimation {
                    showPurchaseSuccess = true
                }
                try? modelContext.save()

                // Auto-dismiss success after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        showPurchaseSuccess = false
                        purchasedAccessory = nil
                    }
                }
            }
        }
    }

    private func purchaseSuccessOverlay(accessory: Accessory) -> some View {
        ZStack {
            Theme.background.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(accessory.rarity.color.opacity(0.2))
                        .frame(width: 100, height: 100)

                    Image(systemName: accessory.iconName)
                        .font(.system(size: 50))
                        .foregroundColor(accessory.rarity.color)
                }

                Text("Unlocked!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Text(accessory.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(accessory.rarity.color)

                Text(accessory.rarity.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .transition(.opacity.combined(with: .scale))
    }
}

struct AccessoryCard: View {
    let accessory: Accessory
    let isUnlocked: Bool
    let isEquipped: Bool
    let canAfford: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isUnlocked ? accessory.rarity.color.opacity(0.2) : Theme.elevated)
                        .frame(width: 60, height: 60)

                    Image(systemName: accessory.iconName)
                        .font(.system(size: 28))
                        .foregroundColor(isUnlocked ? accessory.rarity.color : Theme.textMuted)

                    // Lock overlay for locked items
                    if !isUnlocked {
                        Circle()
                            .fill(Theme.background.opacity(0.5))
                            .frame(width: 60, height: 60)

                        Image(systemName: "lock.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.textMuted)
                    }

                    // Equipped indicator
                    if isEquipped {
                        Circle()
                            .stroke(Theme.success, lineWidth: 3)
                            .frame(width: 66, height: 66)
                    }
                }

                // Name
                Text(accessory.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)

                // Rarity badge
                Text(accessory.rarity.displayName)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(accessory.rarity.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(accessory.rarity.color.opacity(0.15))
                    .cornerRadius(4)

                // Price or status
                if isEquipped {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                        Text("Equipped")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(Theme.success)
                } else if isUnlocked {
                    Text("Tap to equip")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11))
                        Text("\(accessory.cost)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(canAfford ? Theme.warning : Theme.textMuted)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEquipped ? Theme.success.opacity(0.1) : Theme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isEquipped ? Theme.success : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked && !canAfford)
        .opacity(!isUnlocked && !canAfford ? 0.6 : 1.0)
    }
}

#Preview {
    AccessoryShopView(
        player: {
            let p = Player(name: "Test")
            p.essenceCurrency = 200
            p.unlockAccessory(Accessory.all[0])
            p.unlockAccessory(Accessory.all[3])
            return p
        }(),
        pet: {
            let pet = Pet(name: "Ember", species: .dragon)
            pet.happiness = 85
            pet.totalXP = 500
            return pet
        }()
    )
    .preferredColorScheme(.dark)
}
