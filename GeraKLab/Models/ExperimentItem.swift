import SwiftUI

public struct ExperimentItem: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let emoji: String
    public let requiredHardware: String
    public let isOnline: Bool
    public let accentColor: Color

    public init(
        id: String,
        title: String,
        subtitle: String,
        emoji: String,
        requiredHardware: String,
        isOnline: Bool = false,
        accentColor: Color = LabTheme.toxicGreen
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.emoji = emoji
        self.requiredHardware = requiredHardware
        self.isOnline = isOnline
        self.accentColor = accentColor
    }
}
