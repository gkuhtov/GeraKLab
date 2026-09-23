import Foundation

struct Achievement: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let icon: String
}
