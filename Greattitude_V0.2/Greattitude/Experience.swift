import Foundation

struct Experience: Codable, Identifiable, Equatable, Hashable, Sendable {
    let id: UUID
    let createdAt: Date
    let sequenceNumber: Int64
    private(set) var updatedAt: Date
    private(set) var answers: ReflectionAnswers
    private(set) var lastCompletedRevisitAt: Date?
    private(set) var completedRevisitCount: Int

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        sequenceNumber: Int64,
        answers: ReflectionAnswers,
        updatedAt: Date? = nil,
        lastCompletedRevisitAt: Date? = nil,
        completedRevisitCount: Int = 0
    ) {
        self.id = id
        self.createdAt = createdAt
        self.sequenceNumber = sequenceNumber
        self.updatedAt = updatedAt ?? createdAt
        self.answers = answers
        self.lastCompletedRevisitAt = lastCompletedRevisitAt
        self.completedRevisitCount = max(0, completedRevisitCount)
    }

    mutating func edit(answers newAnswers: ReflectionAnswers, at date: Date = Date()) {
        answers = newAnswers
        updatedAt = date
    }

    mutating func recordCompletedRevisit(at date: Date = Date()) {
        lastCompletedRevisitAt = date
        completedRevisitCount += 1
    }
}

struct ReflectionAnswers: Codable, Equatable, Hashable, Sendable {
    let answer1: String
    let answer2: String
    let answer3: String
    let answer4: String

    var all: [String] {
        [answer1, answer2, answer3, answer4]
    }

    init(answer1: String, answer2: String, answer3: String, answer4: String) throws {
        let values = [answer1, answer2, answer3, answer4]
        guard values.allSatisfy({ !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else {
            throw ReflectionValidationError.allFourAnswersRequired
        }
        self.answer1 = answer1
        self.answer2 = answer2
        self.answer3 = answer3
        self.answer4 = answer4
    }
}

enum ReflectionValidationError: Error, Equatable {
    case allFourAnswersRequired
}

enum ReflectionPrompt: Int, CaseIterable, Identifiable {
    case experience = 1
    case whyItWasGood
    case tellSomeone
    case whatYouLearned

    var id: Int { rawValue }

    var entryQuestion: String {
        switch self {
        case .experience:
            return "Tell me a recent positive experience. It doesn’t matter how small."
        case .whyItWasGood:
            return "What made this a positive experience?"
        case .tellSomeone:
            return "What would you say to someone else who had this experience?"
        case .whatYouLearned:
            return "What does this experience show you - What have you learnt from this?"
        }
    }

    /// Unbolded coaching line shown under the step question.
    var entryGuidance: String {
        switch self {
        case .experience:
            return "Look for the day-to-day experiences that often pass us by. Short and sharp is fine."
        case .whyItWasGood:
            return "You should add detail here that describes what it was about this experience that made it positive."
        case .tellSomeone:
            return "Think about what you would say to someone else if you heard them say they had experienced the same thing or achieved the same success."
        case .whatYouLearned:
            return "Think about what this experience is demonstrating about you, your life, your successes, your awesomeness!"
        }
    }

    /// Italic example lines for the entry step.
    var entryExamples: String {
        switch self {
        case .experience:
            return "I went for a run; I had a nice hot shower; I messaged my friend to see how she was going; My daughter gave me an unprompted hug"
        case .whyItWasGood:
            return "Feeling motivated like other runners after a good run; The comfort and privilege of hot water; Knowing I checked in on a friend; Feeling loved in that hug"
        case .tellSomeone:
            return "Well done on getting out for a run; Enjoy that hot shower; You’re a good friend for checking in"
        case .whatYouLearned:
            return "I’m determined; I’m grateful for hot water; I have good friends; I love my kids and family"
        }
    }

    var revisitHeading: String {
        switch self {
        case .experience:
            return "The Experience"
        case .whyItWasGood:
            return "Why it was good"
        case .tellSomeone:
            return "What you’d tell someone else"
        case .whatYouLearned:
            return "What you learned"
        }
    }

    func answer(in answers: ReflectionAnswers) -> String {
        switch self {
        case .experience: return answers.answer1
        case .whyItWasGood: return answers.answer2
        case .tellSomeone: return answers.answer3
        case .whatYouLearned: return answers.answer4
        }
    }
}
