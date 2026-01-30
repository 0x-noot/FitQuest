import SwiftUI
import SwiftData

// MARK: - Home Tab (Pixel Art Style)

struct HomeTab: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Bindable var player: Player

    // Sheet states
    @State private var showQuickWorkout = false
    @State private var showCustomWorkout = false
    @State private var showPetLevelUp = false
    @State private var petNewLevel = 0
    @State private var showPetDetail = false
    @State private var showTreatSheet = false

    // Pet interaction states
    @State private var showHeartParticles = false
    @State private var showPlaySessionComplete = false
    @State private var playSessionsRemaining = 0
    @State private var currentTapCount = 0  // Local tap tracking for current session

    // Evolution state
    @State private var showEvolution = false
    @State private var evolutionStage: EvolutionStage = .baby

    // Dialogue state
    @State private var showDialogue = false
    @State private var dialogueText: String?
    @State private var idleDialogueTimer: Timer?

    // Motivational quote
    @State private var currentQuote: String = QuoteManager.randomQuote()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: PixelScale.px(3)) {
                // Status bar (top)
                PixelStatusBar(
                    essence: player.essenceCurrency,
                    streak: player.currentStreak
                )
                .padding(.horizontal, PixelScale.px(2))
                .padding(.top, PixelScale.px(2))

                // Pet display area (center) - the main focus
                petDisplaySection
                    .padding(.vertical, PixelScale.px(2))

                // Pet Stats Section
                if let pet = player.pet {
                    xpProgressSection(pet: pet)
                        .padding(.horizontal, PixelScale.px(2))
                }

                // Action buttons row
                actionButtonsRow
                    .padding(.horizontal, PixelScale.px(2))

                // Quote of the day
                quoteSection
                    .padding(.horizontal, PixelScale.px(2))

                // Daily quests panel (at bottom)
                if !player.dailyQuests.isEmpty {
                    questsSection
                        .padding(.horizontal, PixelScale.px(2))
                        .padding(.bottom, PixelScale.px(2))
                }
            }
        }
        .background(PixelTheme.background)
        .sheet(isPresented: $showQuickWorkout) {
            QuickWorkoutSheet(player: player, onComplete: handleWorkoutComplete)
        }
        .sheet(isPresented: $showCustomWorkout) {
            CustomWorkoutSheet(player: player, onComplete: handleWorkoutComplete)
        }
        .fullScreenCover(isPresented: $showPetLevelUp) {
            if let pet = player.pet {
                PixelLevelUpView(
                    petName: pet.name,
                    species: pet.species,
                    level: petNewLevel
                ) {
                    showPetLevelUp = false
                }
            }
        }
        .sheet(isPresented: $showPetDetail) {
            if let pet = player.pet {
                PetDetailView(pet: pet, player: player)
            }
        }
        .sheet(isPresented: $showTreatSheet) {
            if let pet = player.pet {
                TreatSelectionSheet(pet: pet, player: player) {
                    checkPetCareQuest()
                    checkQuestProgress()
                }
            }
        }
        .fullScreenCover(isPresented: $showEvolution) {
            if let pet = player.pet {
                PixelEvolutionView(
                    petName: pet.name,
                    species: pet.species,
                    newStage: evolutionStage
                ) {
                    showEvolution = false
                }
            }
        }
        .onAppear {
            currentQuote = QuoteManager.randomQuote()
            player.resetWeeklyWorkoutsIfNeeded()
            refreshDailyQuestsIfNeeded()

            if let pet = player.pet {
                PetManager.applyPassiveDecay(pet: pet)
                PetManager.resetPlaySessionsIfNeeded(pet: pet)

                if player.notificationsEnabled {
                    // Refresh guilt notifications based on workout status
                    NotificationManager.shared.refreshGuiltNotifications(
                        pet: pet,
                        hasWorkedOutToday: player.hasWorkedOutToday
                    )
                    NotificationManager.shared.schedulePetNotifications(for: pet)
                }

                try? modelContext.save()
                showGreetingDialogue(pet: pet)
                startIdleDialogueTimer(pet: pet)
                checkQuestProgress()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                if let pet = player.pet {
                    PetManager.applyPassiveDecay(pet: pet)
                    PetManager.resetPlaySessionsIfNeeded(pet: pet)

                    if player.notificationsEnabled {
                        // Refresh guilt notifications based on workout status
                        NotificationManager.shared.refreshGuiltNotifications(
                            pet: pet,
                            hasWorkedOutToday: player.hasWorkedOutToday
                        )
                        NotificationManager.shared.schedulePetNotifications(for: pet)
                    }

                    try? modelContext.save()
                    showGreetingDialogue(pet: pet)
                }
            } else if newPhase == .inactive || newPhase == .background {
                stopIdleDialogueTimer()
            }
        }
        .onDisappear {
            stopIdleDialogueTimer()
        }
    }

    // MARK: - Pet Display Section

    private var petDisplaySection: some View {
        ZStack {
            if let pet = player.pet {
                VStack(spacing: PixelScale.px(2)) {
                    // Dialogue bubble (above pet)
                    if showDialogue, let text = dialogueText {
                        PixelSpeechBubble(text: text, isVisible: $showDialogue)
                            .transition(.opacity)
                    }

                    // Pet display
                    PixelPetDisplay(
                        pet: pet,
                        context: .home,
                        isAnimating: true,
                        onTap: { handlePetTap(pet: pet) }
                    )

                    // Play hint
                    if pet.canPlay && !pet.isAway {
                        PixelLabel("TOUCH TO GIVE PETS! (\(pet.remainingPlaySessions) LEFT)")
                    }
                }

                // Play session complete popup
                if showPlaySessionComplete {
                    PixelPlaySessionView(
                        sessionsRemaining: playSessionsRemaining,
                        isVisible: $showPlaySessionComplete
                    )
                }
            } else {
                PixelText("NO PET", size: .large, color: PixelTheme.textSecondary)
            }
        }
    }

    // MARK: - Pet Stats Section

    private func petStatsSection(pet: Pet) -> some View {
        VStack(spacing: PixelScale.px(2)) {
            // XP Progress
            VStack(spacing: PixelScale.px(1)) {
                HStack {
                    PixelIconView(icon: .star, size: 12, color: PixelTheme.gbLightest)
                    PixelText("XP", size: .small, color: PixelTheme.text)
                    Spacer()
                    PixelText("LV.\(pet.currentLevel + 1)", size: .small, color: PixelTheme.gbLightest)
                }

                PixelProgressBar(
                    progress: pet.xpProgress,
                    segments: 12,
                    height: PixelScale.px(2)
                )
            }
            .padding(PixelScale.px(2))
            .background(PixelTheme.cardBackground)
            .pixelOutline()

            // Happiness (Health) Progress
            VStack(spacing: PixelScale.px(1)) {
                HStack {
                    PixelIconView(icon: .heart, size: 12, color: PixelTheme.gbLightest)
                    PixelText("HAPPINESS", size: .small, color: PixelTheme.text)
                    Spacer()
                    PixelText("\(pet.mood.rawValue.uppercased())", size: .small, color: PixelTheme.gbLightest)
                }

                PixelProgressBar(
                    progress: pet.happiness / 100.0,
                    segments: 10,
                    height: PixelScale.px(2)
                )
            }
            .padding(PixelScale.px(2))
            .background(PixelTheme.cardBackground)
            .pixelOutline()

            // Evolution stage indicator
            HStack {
                PixelIconView(icon: .paw, size: 12, color: PixelTheme.gbLightest)
                PixelText("STAGE", size: .small, color: PixelTheme.text)
                Spacer()
                PixelText(pet.evolutionStage.displayName.uppercased(), size: .small, color: PixelTheme.gbLightest)
            }
            .padding(PixelScale.px(2))
            .background(PixelTheme.cardBackground)
            .pixelOutline()
        }
    }

    // Keep for backward compatibility
    private func xpProgressSection(pet: Pet) -> some View {
        petStatsSection(pet: pet)
    }

    // MARK: - Action Buttons Row

    private var actionButtonsRow: some View {
        VStack(spacing: PixelScale.px(2)) {
            // Top row: WORK + CUSTOM (workout-related)
            HStack(spacing: PixelScale.px(2)) {
                PixelIconButton(icon: .dumbbell, label: "WORK") {
                    showQuickWorkout = true
                }

                PixelIconButton(icon: .plus, label: "CUSTOM") {
                    showCustomWorkout = true
                }
            }

            // Bottom row: FEED + SHOP (pet-related)
            HStack(spacing: PixelScale.px(2)) {
                PixelIconButton(icon: .heart, label: "FEED") {
                    showTreatSheet = true
                }

                PixelIconButton(icon: .star, label: "SHOP") {
                    showPetDetail = true
                }
            }
        }
    }

    // MARK: - Quests Section

    private var questsSection: some View {
        PixelPanelWithCounter(
            title: "QUESTS",
            current: player.dailyQuests.filter { $0.isCompleted }.count,
            total: player.dailyQuests.count
        ) {
            VStack(spacing: PixelScale.px(1)) {
                ForEach(player.dailyQuests.prefix(3)) { quest in
                    PixelQuestRow(quest: quest) {
                        claimQuestReward(quest)
                    }
                }
            }
        }
    }

    // MARK: - Quote Section

    private var quoteSection: some View {
        VStack(spacing: PixelScale.px(1)) {
            PixelText("QUOTE OF THE DAY", size: .small, color: PixelTheme.gbLightest)
            PixelText(currentQuote.uppercased(), size: .small, color: PixelTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity)
        .padding(PixelScale.px(2))
        .background(PixelTheme.cardBackground)
        .pixelOutline()
    }

    // MARK: - Pet Interaction

    private func handlePetTap(pet: Pet) {
        // Guard: pet must not be away
        guard !pet.isAway else {
            showPetDetail = true
            return
        }

        // Reset sessions if new day
        PetManager.resetPlaySessionsIfNeeded(pet: pet)

        // Guard: must have sessions remaining
        guard pet.playSessionsToday < Pet.maxPlaySessionsPerDay else {
            dialogueText = "ALL DONE FOR TODAY!"
            showDialogue = true
            return
        }

        // Haptic feedback for tap
        if player.soundEffectsEnabled {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }

        // Increment local tap count
        currentTapCount += 1

        // Check if session complete (3 taps)
        if currentTapCount >= Pet.tapsPerSession {
            // Complete the session
            currentTapCount = 0
            pet.playSessionsToday += 1
            pet.lastPlayDate = Date()

            // Add happiness
            PetManager.modifyHappiness(pet: pet, amount: Pet.happinessPerSession)

            // Update UI
            playSessionsRemaining = Pet.maxPlaySessionsPerDay - pet.playSessionsToday
            showPlaySessionComplete = true

            if player.soundEffectsEnabled {
                let notification = UINotificationFeedbackGenerator()
                notification.notificationOccurred(.success)
            }

            checkPlayTimeQuest()
            checkQuestProgress()

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showDialogue(for: pet, context: .playComplete)
            }

            try? modelContext.save()
        }
    }

    // MARK: - Dialogue Functions

    private func showGreetingDialogue(pet: Pet) {
        guard !showDialogue else { return }

        if let greeting = DialogueManager.shared.getGreetingDialogue(for: pet) {
            dialogueText = greeting.uppercased()
            withAnimation {
                showDialogue = true
            }
        }
    }

    private func showDialogue(for pet: Pet, context: DialogueContext) {
        guard !showDialogue else { return }

        if let text = DialogueManager.shared.getDialogue(for: pet, context: context) {
            dialogueText = text.uppercased()
            withAnimation {
                showDialogue = true
            }
        }
    }

    private func startIdleDialogueTimer(pet: Pet) {
        stopIdleDialogueTimer()

        idleDialogueTimer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 30...60), repeats: true) { _ in
            guard !showDialogue, !pet.isAway else { return }

            if DialogueManager.shared.shouldShowIdleDialogue() {
                if let text = DialogueManager.shared.getDialogue(for: pet, context: .idle) {
                    DispatchQueue.main.async {
                        dialogueText = text.uppercased()
                        withAnimation {
                            showDialogue = true
                        }
                    }
                }
            }
        }
    }

    private func stopIdleDialogueTimer() {
        idleDialogueTimer?.invalidate()
        idleDialogueTimer = nil
    }

    // MARK: - Quest Management

    private func refreshDailyQuestsIfNeeded() {
        // Refresh if it's a new day OR if quests are empty (e.g., after data migration)
        let needsRefresh = QuestManager.shared.shouldRefreshQuests(lastRefresh: player.lastQuestRefresh)
            || player.dailyQuests.isEmpty

        if needsRefresh {
            // Clear old quests
            for quest in player.dailyQuests {
                modelContext.delete(quest)
            }
            player.dailyQuests.removeAll()

            // Generate and store new quests
            let newQuests = QuestManager.shared.generateDailyQuests()
            for quest in newQuests {
                player.dailyQuests.append(quest)
                modelContext.insert(quest)
            }
            player.lastQuestRefresh = Date()
            try? modelContext.save()
        }
    }

    private func checkQuestProgress(workout: Workout? = nil) {
        for quest in player.dailyQuests {
            _ = QuestManager.shared.checkQuestCompletion(
                quest: quest,
                player: player,
                workout: workout
            )
        }

        if let pet = player.pet {
            for quest in player.dailyQuests where quest.questType == .happyPet {
                _ = QuestManager.shared.checkHappyPetQuest(quest: quest, pet: pet)
            }
        }
    }

    private func checkPetCareQuest() {
        for quest in player.dailyQuests where quest.questType == .petCare {
            _ = QuestManager.shared.checkPetCareQuest(quest: quest)
        }
    }

    private func checkPlayTimeQuest() {
        for quest in player.dailyQuests where quest.questType == .playTime {
            _ = QuestManager.shared.checkPlayTimeQuest(quest: quest)
        }
    }

    private func claimQuestReward(_ quest: DailyQuest) {
        QuestManager.shared.claimReward(quest: quest, player: player, pet: player.pet)

        if player.soundEffectsEnabled {
            SoundManager.shared.playSuccessHaptic()
        }

        try? modelContext.save()
    }

    // MARK: - Workout Complete Handler

    private func handleWorkoutComplete(_ workout: Workout) {
        let isFirstWorkoutOfDay = player.isFirstWorkoutOfDay

        player.updateStreak()
        player.updateWeeklyStreak(isFirstWorkout: isFirstWorkoutOfDay)

        workout.player = player
        player.workouts.append(workout)
        modelContext.insert(workout)

        if let pet = player.pet {
            let previousLevel = pet.currentLevel
            let previousStage = pet.evolutionStage

            pet.totalXP += workout.xpEarned

            if pet.evolutionStage != previousStage {
                evolutionStage = pet.evolutionStage
                if player.soundEffectsEnabled {
                    SoundManager.shared.playLevelUp()
                }
                showEvolution = true
            } else if pet.currentLevel > previousLevel {
                petNewLevel = pet.currentLevel
                if player.soundEffectsEnabled {
                    SoundManager.shared.playLevelUp()
                }
                showPetLevelUp = true
            }

            PetManager.onWorkoutComplete(pet: pet)

            if !showPetLevelUp && !showEvolution {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showDialogue(for: pet, context: .workoutComplete)
                }
            }
        }

        let essenceEarned = PetManager.essenceEarnedForWorkout(xp: workout.xpEarned)
        player.essenceCurrency += essenceEarned

        checkQuestProgress(workout: workout)

        if player.notificationsEnabled {
            // Cancel guilt notifications since user worked out
            NotificationManager.shared.cancelTodayGuiltNotifications()
            NotificationManager.shared.cancelTodayPetNotifications()
        }

        if player.soundEffectsEnabled {
            SoundManager.shared.playXPGain()
            SoundManager.shared.playSuccessHaptic()
        }

        try? modelContext.save()
    }
}

// MARK: - Pixel Level Up View

struct PixelLevelUpView: View {
    let petName: String
    let species: PetSpecies
    let level: Int
    let onDismiss: () -> Void

    private var petPalette: PixelTheme.PetPalette {
        PixelTheme.PetPalette.palette(for: species)
    }

    var body: some View {
        ZStack {
            PixelTheme.background
                .ignoresSafeArea()

            VStack(spacing: PixelScale.px(4)) {
                Spacer()

                // Pet sprite (large) with species colors
                PixelSpriteView(
                    sprite: PetSpriteLibrary.sprite(for: species, stage: EvolutionStage.from(level: level)),
                    pixelSize: 8,
                    palette: petPalette
                )

                PixelText("LEVEL UP!", size: .xlarge)

                PixelText("\(petName) REACHED LV.\(level)!", size: .medium, color: PixelTheme.textSecondary)

                PixelText("+\(species.baseBonus) \(species.bonusType.uppercased()) BONUS", size: .small, color: PixelTheme.textSecondary)

                Spacer()

                PixelButton("CONTINUE", style: .primary) {
                    onDismiss()
                }
                .padding(.horizontal, PixelScale.px(10))
                .padding(.bottom, PixelScale.px(10))
            }
        }
    }
}

// MARK: - Pixel Evolution View

struct PixelEvolutionView: View {
    let petName: String
    let species: PetSpecies
    let newStage: EvolutionStage
    let onDismiss: () -> Void

    private var petPalette: PixelTheme.PetPalette {
        PixelTheme.PetPalette.palette(for: species)
    }

    var body: some View {
        ZStack {
            PixelTheme.background
                .ignoresSafeArea()

            VStack(spacing: PixelScale.px(4)) {
                Spacer()

                // Pet sprite (large) with species colors
                PixelSpriteView(
                    sprite: PetSpriteLibrary.sprite(for: species, stage: newStage),
                    pixelSize: 10,
                    palette: petPalette
                )

                PixelText("EVOLUTION!", size: .xlarge)

                PixelText("\(petName) EVOLVED TO \(newStage.displayName.uppercased())!", size: .medium, color: PixelTheme.textSecondary)

                PixelText(newStage.description.uppercased(), size: .small, color: PixelTheme.textSecondary)

                Spacer()

                PixelButton("AMAZING!", style: .primary) {
                    onDismiss()
                }
                .padding(.horizontal, PixelScale.px(10))
                .padding(.bottom, PixelScale.px(10))
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HomeTab(player: {
        let p = Player(name: "Test")
        p.currentStreak = 7
        p.highestStreak = 14
        p.weeklyWorkoutGoal = 4
        p.daysWorkedOutThisWeek = 2
        p.currentWeeklyStreak = 3
        p.highestWeeklyStreak = 8
        p.essenceCurrency = 150
        let pet = Pet(name: "Ember", species: .dragon)
        pet.totalXP = 500
        pet.happiness = 85
        p.pet = pet
        return p
    }())
    .modelContainer(for: [Player.self, Workout.self, WorkoutTemplate.self, Pet.self, DailyQuest.self], inMemory: true)
}
