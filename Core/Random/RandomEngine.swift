import Foundation

final class RandomEngine {

    static let shared = RandomEngine()

    private init() {}

    func randomElement<T>(from items: [T]) -> T? {
        items.randomElement()
    }

    func randomInt(
        from lowerBound: Int,
        to upperBound: Int
    ) -> Int {
        Int.random(in: lowerBound...upperBound)
    }

    func randomPercentage() -> Int {
        randomInt(from: 1, to: 100)
    }
}
