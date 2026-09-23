import Foundation

struct ExperimentResult: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let value: String
    let description: String

    init(
        id: UUID = UUID(),
        title: String,
        value: String,
        description: String
    ) {
        self.id = id
        self.title = title
        self.value = value
        self.description = description
    }
}
