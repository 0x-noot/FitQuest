import AVFoundation
import AudioToolbox

class SoundManager {
    static let shared = SoundManager()

    private init() {}

    /// Play XP gain sound (subtle positive feedback)
    func playXPGain() {
        // System sound 1057 - soft positive tone
        AudioServicesPlaySystemSound(1057)
    }

    /// Play level up sound (celebratory)
    func playLevelUp() {
        // System sound 1025 - triumphant fanfare-like
        AudioServicesPlaySystemSound(1025)
    }

    /// Play rank up sound (epic achievement)
    func playRankUp() {
        // System sound 1026 - bigger celebration
        AudioServicesPlaySystemSound(1026)
    }

    /// Play streak milestone sound
    func playStreakMilestone() {
        // System sound 1054 - achievement unlocked type
        AudioServicesPlaySystemSound(1054)
    }

    /// Play workout complete sound
    func playWorkoutComplete() {
        // System sound 1001 - completion chime
        AudioServicesPlaySystemSound(1001)
    }

    /// Play button tap haptic feedback
    func playHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// Play success haptic feedback
    func playSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Play warning haptic feedback (for rest day use)
    func playWarningHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}
