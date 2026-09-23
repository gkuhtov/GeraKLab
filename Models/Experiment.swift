import Foundation

struct Experiment: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let type: String
    let enabled: Bool
}
