import Foundation

enum ConfigLoaderError: LocalizedError {
    case fileNotFound(String)
    case invalidData(String)
    case decodingFailed(String, Error)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let file):
            return "Файл конфигурации не найден: \(file)"

        case .invalidData(let file):
            return "Файл конфигурации пуст или повреждён: \(file)"

        case .decodingFailed(let file, let error):
            return "Ошибка чтения \(file): \(error.localizedDescription)"
        }
    }
}

final class ConfigLoader {

    static let shared = ConfigLoader()

    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func load<T: Decodable>(
        _ type: T.Type,
        fileName: String
    ) throws -> T {

        guard let url = bundle.url(
            forResource: fileName,
            withExtension: "json"
        ) else {
            throw ConfigLoaderError.fileNotFound(fileName)
        }

        let data = try Data(contentsOf: url)

        guard !data.isEmpty else {
            throw ConfigLoaderError.invalidData(fileName)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw ConfigLoaderError.decodingFailed(fileName, error)
        }
    }

    func loadAppConfig() throws -> AppConfig {

        let appearance = try load(
            AppearanceConfig.self,
            fileName: "appearance"
        )

        let home = try load(
            HomeConfig.self,
            fileName: "home"
        )

        let experimentsConfig = try load(
            ExperimentsConfig.self,
            fileName: "experiments"
        )

        let texts = try load(
            TextsConfig.self,
            fileName: "texts"
        )

        let resultsConfig = try load(
            ResultsConfig.self,
            fileName: "results"
        )

        let achievementsConfig = try load(
            AchievementsConfig.self,
            fileName: "achievements"
        )

        let results = resultsConfig.results.mapValues { values in
            values.map {
                ExperimentResultConfig(
                    title: $0.title,
                    value: $0.value,
                    description: $0.description
                )
            }
        }

        return AppConfig(
            appearance: appearance,
            home: home,
            experiments: experimentsConfig.experiments,
            texts: texts,
            results: results,
            achievements: achievementsConfig.achievements
        )
    }
}

private struct ExperimentsConfig: Codable {
    let version: Int
    let experiments: [Experiment]
}

private struct ResultsConfig: Codable {
    let version: Int
    let results: [String: [ExperimentResultConfig]]
}

private struct AchievementsConfig: Codable {
    let version: Int
    let achievements: [Achievement]
}
