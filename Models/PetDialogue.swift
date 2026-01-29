import Foundation

enum DialogueContext {
    case greeting           // When app opens
    case workoutComplete    // After completing a workout
    case lowHappiness       // When happiness is below 30%
    case highHappiness      // When happiness is above 90%
    case idle               // Random idle dialogue
    case levelUp            // After leveling up
    case evolution          // After evolving
    case playComplete       // After play session
}

struct PetDialogue {
    let context: DialogueContext
    let text: String
}

extension PetSpecies {
    func dialogues(for context: DialogueContext, mood: PetMood) -> [String] {
        switch self {
        case .plant:
            return plantDialogues(for: context, mood: mood)
        case .cat:
            return catDialogues(for: context, mood: mood)
        case .dog:
            return dogDialogues(for: context, mood: mood)
        case .wolf:
            return wolfDialogues(for: context, mood: mood)
        case .dragon:
            return dragonDialogues(for: context, mood: mood)
        }
    }

    private func plantDialogues(for context: DialogueContext, mood: PetMood) -> [String] {
        switch context {
        case .greeting:
            switch mood {
            case .ecstatic: return ["I'm blooming beautifully today!", "The sun feels wonderful!"]
            case .happy: return ["Good to see you!", "Ready to grow together?"]
            case .content: return ["Hello there.", "Nice day for growing."]
            case .sad: return ["I could use some water...", "Feeling a bit wilted."]
            case .unhappy: return ["My leaves are drooping...", "Please don't forget me."]
            case .miserable: return ["I'm withering away...", "Please help me..."]
            }
        case .workoutComplete:
            return ["Your energy helps me grow!", "I can feel myself getting stronger!", "Patience pays off!"]
        case .lowHappiness:
            return ["I need some attention...", "My soil feels dry...", "A little care goes a long way."]
        case .highHappiness:
            return ["I'm thriving!", "Look how tall I've grown!", "Thank you for nurturing me!"]
        case .idle:
            return ["*rustles leaves*", "Growing steadily...", "Photosynthesis in progress!"]
        case .levelUp:
            return ["I've grown a new leaf!", "My roots are stronger!", "Steady growth wins!"]
        case .evolution:
            return ["I've blossomed into something new!", "Watch me flourish!", "Nature is amazing!"]
        case .playComplete:
            return ["That was refreshing!", "*happy leaf wiggle*", "I love the attention!"]
        }
    }

    private func catDialogues(for context: DialogueContext, mood: PetMood) -> [String] {
        switch context {
        case .greeting:
            switch mood {
            case .ecstatic: return ["Purrfect timing!", "*excited meow*"]
            case .happy: return ["Oh, you're back!", "*purrs*"]
            case .content: return ["Meow.", "*stretches*"]
            case .sad: return ["Finally...", "*quiet meow*"]
            case .unhappy: return ["You forgot about me.", "*hisses softly*"]
            case .miserable: return ["...", "*turns away*"]
            }
        case .workoutComplete:
            return ["That was quick! Like me!", "Impressive agility!", "*approving purr*"]
        case .lowHappiness:
            return ["I demand attention.", "My food bowl is looking empty...", "*stares judgmentally*"]
        case .highHappiness:
            return ["You've earned my approval!", "*loud purring*", "I suppose you're acceptable."]
        case .idle:
            return ["*grooms self*", "*knocks something over*", "*stares at wall*", "Nap time soon?"]
        case .levelUp:
            return ["As expected of my human!", "I'm becoming legendary!", "*proud meow*"]
        case .evolution:
            return ["I've ascended!", "Fear my new form!", "*dramatic pose*"]
        case .playComplete:
            return ["*purrs loudly*", "Acceptable entertainment.", "Again! ...if you want."]
        }
    }

    private func dogDialogues(for context: DialogueContext, mood: PetMood) -> [String] {
        switch context {
        case .greeting:
            switch mood {
            case .ecstatic: return ["YOU'RE HERE! I MISSED YOU!", "*tail wagging intensifies*"]
            case .happy: return ["Best friend is back!", "*excited barking*"]
            case .content: return ["Hello, friend!", "*wags tail*"]
            case .sad: return ["I waited for you...", "*soft whine*"]
            case .unhappy: return ["Where were you?", "*sad eyes*"]
            case .miserable: return ["Please don't leave again...", "*whimpers*"]
            }
        case .workoutComplete:
            return ["We did it together!", "GOOD JOB!", "That was so fun!", "Again! Let's go again!"]
        case .lowHappiness:
            return ["Can we play?", "I miss our walks...", "*brings you a toy*"]
        case .highHappiness:
            return ["BEST DAY EVER!", "I love you so much!", "*happy zoomies*"]
        case .idle:
            return ["*chases tail*", "*pants happily*", "Wanna play?", "*tilts head*"]
        case .levelUp:
            return ["Did I do good?!", "We're the best team!", "*proud bark*"]
        case .evolution:
            return ["Look at me now!", "Still your best friend!", "Let's celebrate!"]
        case .playComplete:
            return ["THAT WAS AMAZING!", "*licks your face*", "Best human ever!", "More pets please!"]
        }
    }

    private func wolfDialogues(for context: DialogueContext, mood: PetMood) -> [String] {
        switch context {
        case .greeting:
            switch mood {
            case .ecstatic: return ["The hunt begins!", "Ready for greatness!"]
            case .happy: return ["Pack leader returns.", "*nods approvingly*"]
            case .content: return ["You're here.", "*watches silently*"]
            case .sad: return ["The pack feels incomplete.", "*lonely howl*"]
            case .unhappy: return ["You've been gone too long.", "*growls softly*"]
            case .miserable: return ["...", "*turns away into shadows*"]
            }
        case .workoutComplete:
            return ["The prey is conquered!", "Strength builds strength!", "A worthy hunt!"]
        case .lowHappiness:
            return ["A wolf needs its pack.", "The wilderness calls...", "Don't abandon your pack."]
        case .highHappiness:
            return ["*triumphant howl*", "We are unstoppable!", "The pack thrives!"]
        case .idle:
            return ["*scans the horizon*", "*sharpens claws*", "Waiting for the hunt.", "*silent and watchful*"]
        case .levelUp:
            return ["Power courses through me!", "The pack grows stronger!", "*fierce howl*"]
        case .evolution:
            return ["I've become ALPHA!", "Witness true power!", "None can challenge us!"]
        case .playComplete:
            return ["A worthy bond.", "*affectionate nudge*", "Pack bonding complete."]
        }
    }

    private func dragonDialogues(for context: DialogueContext, mood: PetMood) -> [String] {
        switch context {
        case .greeting:
            switch mood {
            case .ecstatic: return ["ROAR! Today we conquer!", "My flames burn bright!"]
            case .happy: return ["The dragon stirs!", "*smoke puffs from nostrils*"]
            case .content: return ["Ah, you've returned.", "*yawns, showing fangs*"]
            case .sad: return ["Even dragons need companionship.", "*dim flame*"]
            case .unhappy: return ["My fire grows cold...", "*curls up alone*"]
            case .miserable: return ["...", "*embers dying*"]
            }
        case .workoutComplete:
            return ["LEGENDARY!", "Feel the burn!", "We forge greatness in fire!", "UNSTOPPABLE!"]
        case .lowHappiness:
            return ["A dragon's flame needs fuel.", "Don't let my fire die.", "Treasure your dragon..."]
        case .highHappiness:
            return ["WITNESS MY GLORY!", "*breathes fire triumphantly*", "We are LEGENDARY!"]
        case .idle:
            return ["*sleeps on gold pile*", "*polishes scales*", "Mortals fascinate me.", "*tiny fire sneeze*"]
        case .levelUp:
            return ["MY POWER GROWS!", "FEAR ME!", "*earth-shaking roar*"]
        case .evolution:
            return ["I HAVE ASCENDED!", "BEHOLD TRUE POWER!", "LEGENDARY EVOLUTION!"]
        case .playComplete:
            return ["A worthy tribute!", "*purrs like a giant cat*", "You've pleased the dragon!"]
        }
    }
}
