import Foundation
import Combine

final class ExperienceStore: ObservableObject {
    static let maximumEntries = 10

    static var placeholder: ExperienceStore {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("GreattitudePlaceholder.json")
        return try! ExperienceStore(fileURL: url)
    }

    private struct PersistedState: Codable {
        var experiences: [Experience]
        var nextSequenceNumber: Int64
    }

    @Published private(set) var experiences: [Experience] = []

    private let fileURL: URL
    private let fileManager: FileManager
    private var nextSequenceNumber: Int64 = 1

    init(fileURL: URL? = nil, fileManager: FileManager = .default) throws {
        self.fileManager = fileManager

        if let fileURL {
            self.fileURL = fileURL
        } else {
            let appSupport = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            let appDirectory = appSupport.appendingPathComponent("Greattitude", isDirectory: true)
            try fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)
            self.fileURL = appDirectory.appendingPathComponent("experiences.json")
        }

        if fileManager.fileExists(atPath: self.fileURL.path) {
            let data = try Data(contentsOf: self.fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let state = try decoder.decode(PersistedState.self, from: data)
            apply(state)
            try persist()
        } else {
            experiences = []
            nextSequenceNumber = 1
            try persist()
        }
    }

    var oldestFirst: [Experience] {
        experiences.sorted { $0.sequenceNumber < $1.sequenceNumber }
    }

    func experience(id: UUID) -> Experience? {
        experiences.first { $0.id == id }
    }

    func experienceAfter(_ id: UUID) -> Experience? {
        let ordered = oldestFirst
        guard let index = ordered.firstIndex(where: { $0.id == id }) else {
            return ordered.first
        }
        let nextIndex = ordered.index(after: index)
        if nextIndex < ordered.endIndex {
            return ordered[nextIndex]
        }
        return ordered.first
    }

    @discardableResult
    func add(answers: ReflectionAnswers, at date: Date = Date()) throws -> Experience {
        let experience = Experience(
            createdAt: date,
            sequenceNumber: nextSequenceNumber,
            answers: answers
        )
        nextSequenceNumber += 1
        experiences.append(experience)
        experiences.sort { $0.sequenceNumber < $1.sequenceNumber }
        if experiences.count > Self.maximumEntries {
            experiences.removeFirst()
        }
        try persist()
        return experience
    }

    func edit(id: UUID, answers: ReflectionAnswers, at date: Date = Date()) throws {
        guard let index = experiences.firstIndex(where: { $0.id == id }) else {
            throw ExperienceStoreError.experienceNotFound
        }
        experiences[index].edit(answers: answers, at: date)
        try persist()
    }

    func delete(id: UUID) throws {
        guard experiences.contains(where: { $0.id == id }) else {
            throw ExperienceStoreError.experienceNotFound
        }
        experiences.removeAll { $0.id == id }
        try persist()
    }

    func completeRevisit(id: UUID, at date: Date = Date()) throws {
        guard let index = experiences.firstIndex(where: { $0.id == id }) else {
            throw ExperienceStoreError.experienceNotFound
        }
        experiences[index].recordCompletedRevisit(at: date)
        try persist()
    }

    private func apply(_ state: PersistedState) {
        var loaded = state.experiences.sorted { $0.sequenceNumber < $1.sequenceNumber }
        if loaded.count > Self.maximumEntries {
            loaded = Array(loaded.suffix(Self.maximumEntries))
        }
        experiences = loaded
        nextSequenceNumber = max(
            state.nextSequenceNumber,
            (loaded.map(\.sequenceNumber).max() ?? 0) + 1
        )
    }

    private func persist() throws {
        let directory = fileURL.deletingLastPathComponent()
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let state = PersistedState(
            experiences: experiences,
            nextSequenceNumber: nextSequenceNumber
        )
        let data = try encoder.encode(state)
        try data.write(to: fileURL, options: .atomic)
    }
}

enum ExperienceStoreError: Error, Equatable {
    case experienceNotFound
}
