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
        VStack(spacing: 0) {
            // Header bar
            headerBar

            // Balance header
            balanceHeader

            // Category tabs
            categoryTabs

            // Accessory grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: PixelScale.px(2)) {
                    ForEach(Accessory.accessories(for: selectedCategory), id: \.id) { accessory in
                        PixelAccessoryCard(
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
                .padding(PixelScale.px(2))
            }
        }
        .background(PixelTheme.background)
        .overlay {
            if showPurchaseSuccess, let accessory = purchasedAccessory {
                purchaseSuccessOverlay(accessory: accessory)
            }
        }
    }

    private var headerBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                PixelText("DONE", size: .small, color: PixelTheme.gbLightest)
            }

            Spacer()

            PixelText("ACCESSORY SHOP", size: .medium)

            Spacer()

            // Invisible spacer to center title
            PixelText("DONE", size: .small, color: .clear)
        }
        .padding(.horizontal, PixelScale.px(2))
        .padding(.vertical, PixelScale.px(2))
        .background(PixelTheme.gbDark)
        .pixelOutline()
    }

    private var balanceHeader: some View {
        HStack(spacing: PixelScale.px(3)) {
            // Pet preview with accessories
            ZStack {
                Rectangle()
                    .fill(PixelTheme.cardBackground)
                    .frame(width: PixelScale.px(15), height: PixelScale.px(15))
                    .pixelOutline()

                PixelPetDisplay(
                    pet: pet,
                    context: .card,
                    isAnimating: true,
                    onTap: nil
                )
            }

            VStack(alignment: .leading, spacing: PixelScale.px(1)) {
                PixelText(pet.name, size: .medium)

                HStack(spacing: PixelScale.px(1)) {
                    PixelIconView(icon: .star, size: 12, color: Color(hex: "FFD700"))
                    PixelText("\(player.essenceCurrency)", size: .medium, color: Color(hex: "FFD700"))
                }
            }

            Spacer()
        }
        .padding(PixelScale.px(2))
        .background(PixelTheme.cardBackground)
        .pixelOutline()
    }

    private var categoryTabs: some View {
        HStack(spacing: 0) {
            ForEach(AccessoryCategory.allCases, id: \.self) { category in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCategory = category
                    }
                } label: {
                    VStack(spacing: PixelScale.px(1)) {
                        PixelIconView(
                            icon: categoryIcon(for: category),
                            size: 16,
                            color: selectedCategory == category ? PixelTheme.gbLightest : PixelTheme.textSecondary
                        )

                        PixelText(
                            category.displayName.uppercased(),
                            size: .small,
                            color: selectedCategory == category ? PixelTheme.gbLightest : PixelTheme.textSecondary
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PixelScale.px(2))
                    .background(selectedCategory == category ? PixelTheme.gbDark : PixelTheme.cardBackground)
                }
            }
        }
        .pixelOutline()
    }

    private func categoryIcon(for category: AccessoryCategory) -> PixelIcon {
        switch category {
        case .hat: return .star
        case .background: return .heart
        case .effect: return .sparkle
        }
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
            PixelTheme.background.opacity(0.9)
                .ignoresSafeArea()

            PixelWindow(title: "UNLOCKED!") {
                VStack(spacing: PixelScale.px(3)) {
                    ZStack {
                        Rectangle()
                            .fill(accessory.rarity.color.opacity(0.2))
                            .frame(width: PixelScale.px(20), height: PixelScale.px(20))
                            .pixelOutline()

                        Image(systemName: accessory.iconName)
                            .font(.system(size: 40))
                            .foregroundColor(accessory.rarity.color)
                    }

                    PixelText(accessory.name.uppercased(), size: .large)

                    PixelText(accessory.rarity.displayName.uppercased(), size: .small, color: accessory.rarity.color)
                }
            }
            .padding(PixelScale.px(4))
        }
        .transition(.opacity.combined(with: .scale))
    }
}

// MARK: - Pixel Accessory Card

struct PixelAccessoryCard: View {
    let accessory: Accessory
    let isUnlocked: Bool
    let isEquipped: Bool
    let canAfford: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: PixelScale.px(1)) {
                // Icon
                ZStack {
                    Rectangle()
                        .fill(isUnlocked ? accessory.rarity.color.opacity(0.2) : PixelTheme.gbDark)
                        .frame(width: PixelScale.px(12), height: PixelScale.px(12))

                    Image(systemName: accessory.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(isUnlocked ? accessory.rarity.color : PixelTheme.textSecondary)

                    // Lock overlay for locked items
                    if !isUnlocked {
                        Rectangle()
                            .fill(PixelTheme.background.opacity(0.5))
                            .frame(width: PixelScale.px(12), height: PixelScale.px(12))

                        PixelIconView(icon: .star, size: 14, color: PixelTheme.textSecondary)
                    }

                    // Equipped indicator
                    if isEquipped {
                        Rectangle()
                            .stroke(Color(hex: "50FF50"), lineWidth: 2)
                            .frame(width: PixelScale.px(13), height: PixelScale.px(13))
                    }
                }
                .pixelOutline()

                // Name
                PixelText(accessory.name.uppercased(), size: .small)
                    .lineLimit(1)

                // Rarity badge
                PixelText(accessory.rarity.displayName.uppercased(), size: .small, color: accessory.rarity.color)

                // Price or status
                if isEquipped {
                    HStack(spacing: PixelScale.px(1)) {
                        PixelIconView(icon: .heart, size: 10, color: Color(hex: "50FF50"))
                        PixelText("EQUIPPED", size: .small, color: Color(hex: "50FF50"))
                    }
                } else if isUnlocked {
                    PixelText("TAP TO EQUIP", size: .small, color: PixelTheme.textSecondary)
                } else {
                    HStack(spacing: PixelScale.px(1)) {
                        PixelIconView(icon: .star, size: 10, color: canAfford ? Color(hex: "FFD700") : PixelTheme.textSecondary)
                        PixelText("\(accessory.cost)", size: .small, color: canAfford ? Color(hex: "FFD700") : PixelTheme.textSecondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(PixelScale.px(2))
            .background(isEquipped ? Color(hex: "50FF50").opacity(0.1) : PixelTheme.cardBackground)
            .pixelOutline(color: isEquipped ? Color(hex: "50FF50") : PixelTheme.border)
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
