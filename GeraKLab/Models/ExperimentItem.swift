import SwiftUI

public struct ExperimentItem: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let description: String
    public let emoji: String
    public let dangerLevel: Int
    public let requiredHardware: String
    public let hexColor: String
    public var mechanic: String?
    public var runCount: Int
    public var isFavorite: Bool

    public var accentColor: Color {
        Color(hex: hexColor) ?? LabTheme.cyanBeam
    }

    public var resolvedMechanic: String {
        if let m = mechanic, !m.isEmpty { return m }
        let hw = requiredHardware.lowercased()
        if hw.contains("гироскоп") { return "core_balance" }
        if hw.contains("акселерометр") { return "shake_gforce" }
        if hw.contains("вспышка") || hw.contains("камера") { return "strobe_touch" }
        if hw.contains("приближения") { return "proximity_facepalm" }
        return "audio_scream"
    }

    public init(
        id: String,
        title: String,
        description: String,
        emoji: String,
        dangerLevel: Int,
        requiredHardware: String,
        hexColor: String,
        mechanic: String? = nil,
        runCount: Int = 0,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.emoji = emoji
        self.dangerLevel = dangerLevel
        self.requiredHardware = requiredHardware
        self.hexColor = hexColor
        self.mechanic = mechanic
        self.runCount = runCount
        self.isFavorite = isFavorite
    }
}
