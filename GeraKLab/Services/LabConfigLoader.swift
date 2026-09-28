import Foundation
import SwiftUI

public struct ConfigExperimentItem: Codable, Identifiable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let emoji: String
    public let category: String
    public let requiredHardware: String
    public let accentColorHex: String
    public let triggerDecibels: Int
    public let durationSeconds: Int
    public let phrases: [String]

    public var accentColor: Color {
        Color(hex: accentColorHex)
    }
}

public final class LabConfigLoader {
    public static let shared = LabConfigLoader()

    private(set) var experiments: [ConfigExperimentItem] = []

    private init() {
        loadConfig()
    }

    public func loadConfig() {
        guard let url = Bundle.main.url(forResource: "experiments", withExtension: "json") else {
            print("[LabConfigLoader] experiments.json не найден в бандле.")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            self.experiments = try JSONDecoder().decode([ConfigExperimentItem].self, from: data)
        } catch {
            print("[LabConfigLoader] Ошибка парсинга experiments.json: \(error)")
        }
    }
}

// Хелпер создания цвета из HEX
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var int: UInt64 = 0
        scanner.scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 7: // #RRGGBB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 255, 135)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
