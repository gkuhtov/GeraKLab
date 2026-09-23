import Foundation

struct AppConfig {
    let appearance: AppearanceConfig
    let home: HomeConfig
    let experiments: [Experiment]
    let texts: TextsConfig
    let results: [String: [ExperimentResultConfig]]
    let achievements: [Achievement]
}

struct AppearanceConfig: Codable {
    let appName: String
    let subtitle: String
    let theme: ThemeConfig
    let glass: GlassConfig
    let animation: AnimationConfig
    let haptics: HapticsConfig
    let sounds: SoundsConfig
}

struct ThemeConfig: Codable {
    let background: String
    let surface: String
    let accent: String
    let secondaryAccent: String
    let text: String
    let secondaryText: String
}

struct GlassConfig: Codable {
    let enabled: Bool
    let opacity: Double
    let blur: Double
    let cornerRadius: Double
}

struct AnimationConfig: Codable {
    let enabled: Bool
    let duration: Double
}

struct HapticsConfig: Codable {
    let enabled: Bool
}

struct SoundsConfig: Codable {
    let enabled: Bool
}

struct HomeConfig: Codable {
    let title: String
    let subtitle: String
    let status: StatusConfig
    let sections: [HomeSectionConfig]
}

struct StatusConfig: Codable {
    let title: String
    let description: String
}

struct HomeSectionConfig: Codable, Identifiable {
    let id: String
    let title: String
    let enabled: Bool
}

struct TextsConfig: Codable {
    let common: CommonTextsConfig
    let laboratory: LaboratoryTextsConfig
}

struct CommonTextsConfig: Codable {
    let start: String
    let back: String
    let cancel: String
    let again: String
    let close: String
    let save: String
    let settings: String
}

struct LaboratoryTextsConfig: Codable {
    let initializing: String
    let scanning: String
    let analyzing: String
    let processing: String
    let completed: String
    let anomaly: String
}

struct ExperimentResultConfig: Codable, Hashable {
    let title: String
    let value: String
    let description: String
}
