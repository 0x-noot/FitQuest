import Foundation

struct QuoteManager {
    static let quotes: [String] = [
        // Fitness & Health
        "The only bad workout is the one that didn't happen.",
        "Your body can stand almost anything. It's your mind you have to convince.",
        "Take care of your body. It's the only place you have to live.",
        "Strength doesn't come from what you can do. It comes from overcoming what you thought you couldn't.",
        "The pain you feel today will be the strength you feel tomorrow.",

        // Perseverance
        "It does not matter how slowly you go as long as you do not stop.",
        "Success is not final, failure is not fatal: it is the courage to continue that counts.",
        "The secret of getting ahead is getting started.",
        "Don't watch the clock; do what it does. Keep going.",
        "Perseverance is not a long race; it is many short races one after the other.",

        // Motivation
        "Believe you can and you're halfway there.",
        "The future belongs to those who believe in the beauty of their dreams.",
        "What lies behind us and what lies before us are tiny matters compared to what lies within us.",
        "You are never too old to set another goal or to dream a new dream.",
        "The only way to do great work is to love what you do.",

        // Self-improvement
        "Be the change you wish to see in the world.",
        "In the middle of difficulty lies opportunity.",
        "The best time to plant a tree was 20 years ago. The second best time is now.",
        "Every day is a new beginning. Take a deep breath and start again.",
        "Small progress is still progress.",

        // Mindset
        "Your only limit is your mind.",
        "Whether you think you can or you think you can't, you're right.",
        "The mind is everything. What you think you become.",
        "Doubt kills more dreams than failure ever will.",
        "A positive attitude gives you power over your circumstances.",

        // Action
        "The journey of a thousand miles begins with one step.",
        "Action is the foundational key to all success.",
        "Don't wait for opportunity. Create it.",
        "The best way to predict the future is to create it.",
        "Dreams don't work unless you do.",

        // Growth
        "Growth is painful. Change is painful. But nothing is as painful as staying stuck.",
        "Fall seven times, stand up eight.",
        "Challenges are what make life interesting. Overcoming them is what makes life meaningful.",
        "Comfort is the enemy of progress.",
        "The only person you are destined to become is the person you decide to be.",

        // Courage
        "Courage is not the absence of fear, but rather the judgment that something else is more important than fear.",
        "Life shrinks or expands in proportion to one's courage.",
        "You gain strength, courage, and confidence by every experience in which you stop to look fear in the face.",
        "Do one thing every day that scares you.",
        "Feel the fear and do it anyway.",

        // Success
        "Success usually comes to those who are too busy to be looking for it.",
        "Don't be afraid to give up the good to go for the great.",
        "Success is walking from failure to failure with no loss of enthusiasm.",
        "It's not about being the best. It's about being better than you were yesterday.",
        "Champions keep playing until they get it right.",

        // Inspiration
        "Stars can't shine without darkness.",
        "Difficult roads often lead to beautiful destinations.",
        "The harder you work for something, the greater you'll feel when you achieve it.",
        "Don't limit your challenges. Challenge your limits.",
        "Your potential is endless. Go do what you were created to do."
    ]

    /// Get a random motivational quote
    static func randomQuote() -> String {
        quotes.randomElement() ?? quotes[0]
    }
}
