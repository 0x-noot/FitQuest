import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    var highlightedFeature: PremiumFeature?

    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    @State private var showError = false

    var body: some View {
        VStack(spacing: 0) {
            // Dismiss button
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    PixelIconView(icon: .settings, size: 16, color: PixelTheme.textSecondary)
                }
            }
            .padding(.horizontal, PixelScale.px(4))
            .padding(.top, PixelScale.px(2))

            ScrollView {
                VStack(spacing: PixelScale.px(4)) {
                    // Header
                    VStack(spacing: PixelScale.px(2)) {
                        PixelIconView(icon: .star, size: 48, color: PixelTheme.gbLightest)
                        PixelText("FITOGATCHI PRO", size: .xlarge)
                    }
                    .padding(.top, PixelScale.px(2))

                    // Feature list
                    PixelPanel(title: "PERKS") {
                        VStack(spacing: PixelScale.px(2)) {
                            ForEach(PremiumFeature.allCases, id: \.rawValue) { feature in
                                featureRow(feature)
                            }
                        }
                    }
                    .padding(.horizontal, PixelScale.px(4))

                    // Plan selection
                    if subscriptionManager.isLoading {
                        PixelText("LOADING...", size: .small, color: PixelTheme.textSecondary)
                            .padding(.vertical, PixelScale.px(4))
                    } else {
                        VStack(spacing: PixelScale.px(2)) {
                            HStack(spacing: PixelScale.px(2)) {
                                if let monthly = subscriptionManager.monthlyProduct {
                                    planCard(
                                        product: monthly,
                                        title: "MONTHLY",
                                        subtitle: "\(monthly.displayPrice)/MO",
                                        badge: nil
                                    )
                                }

                                if let yearly = subscriptionManager.yearlyProduct {
                                    planCard(
                                        product: yearly,
                                        title: "YEARLY",
                                        subtitle: "\(yearly.displayPrice)/YR",
                                        badge: "SAVE 27%"
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, PixelScale.px(4))
                    }

                    // Subscribe button
                    VStack(spacing: PixelScale.px(2)) {
                        PixelButton("SUBSCRIBE", icon: .star, style: .primary) {
                            Task { await purchase() }
                        }
                        .disabled(selectedProduct == nil || isPurchasing)
                        .opacity(selectedProduct == nil ? 0.5 : 1.0)

                        // Restore purchases
                        Button {
                            Task { await subscriptionManager.restorePurchases() }
                        } label: {
                            PixelText("RESTORE PURCHASES", size: .small, color: PixelTheme.textSecondary)
                        }
                    }
                    .padding(.horizontal, PixelScale.px(4))

                    // Legal
                    VStack(spacing: PixelScale.px(1)) {
                        PixelText("RECURRING BILLING. CANCEL ANYTIME.", size: .small, color: PixelTheme.textSecondary)
                        HStack(spacing: PixelScale.px(2)) {
                            Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                                PixelText("TERMS", size: .small, color: PixelTheme.gbLight)
                            }
                            PixelText("|", size: .small, color: PixelTheme.textSecondary)
                            Link(destination: URL(string: "https://www.apple.com/legal/privacy/")!) {
                                PixelText("PRIVACY", size: .small, color: PixelTheme.gbLight)
                            }
                        }
                    }
                    .padding(.bottom, PixelScale.px(4))
                }
            }
        }
        .background(PixelTheme.background)
        .onAppear {
            // Default to yearly
            selectedProduct = subscriptionManager.yearlyProduct ?? subscriptionManager.monthlyProduct
        }
        .onChange(of: subscriptionManager.products) { _, _ in
            if selectedProduct == nil {
                selectedProduct = subscriptionManager.yearlyProduct ?? subscriptionManager.monthlyProduct
            }
        }
        .onChange(of: subscriptionManager.isPremium) { _, isPremium in
            if isPremium { dismiss() }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "Something went wrong.")
        }
    }

    // MARK: - Feature Row

    private func featureRow(_ feature: PremiumFeature) -> some View {
        HStack(spacing: PixelScale.px(2)) {
            PixelIconView(
                icon: feature.icon,
                size: 16,
                color: feature == highlightedFeature ? PixelTheme.gbLightest : PixelTheme.gbLight
            )
            VStack(alignment: .leading, spacing: 0) {
                PixelText(feature.rawValue, size: .medium,
                          color: feature == highlightedFeature ? PixelTheme.gbLightest : PixelTheme.text)
                PixelText(feature.featureDescription, size: .small, color: PixelTheme.textSecondary)
            }
            Spacer()
        }
    }

    // MARK: - Plan Card

    private func planCard(product: Product, title: String, subtitle: String, badge: String?) -> some View {
        let isSelected = selectedProduct?.id == product.id

        return Button {
            selectedProduct = product
        } label: {
            VStack(spacing: PixelScale.px(1)) {
                if let badge = badge {
                    PixelText(badge, size: .small, color: PixelTheme.gbLightest)
                }
                PixelText(title, size: .medium, color: isSelected ? PixelTheme.gbLightest : PixelTheme.text)
                PixelText(subtitle, size: .small, color: isSelected ? PixelTheme.gbLightest : PixelTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(PixelScale.px(3))
            .background(isSelected ? PixelTheme.gbDark : PixelTheme.background)
            .overlay(
                RoundedRectangle(cornerRadius: PixelScale.cornerRadius)
                    .stroke(isSelected ? PixelTheme.gbLightest : PixelTheme.border, lineWidth: PixelTheme.borderThickness)
            )
        }
    }

    // MARK: - Purchase

    private func purchase() async {
        guard let product = selectedProduct else { return }
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let success = try await subscriptionManager.purchase(product)
            if success {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
