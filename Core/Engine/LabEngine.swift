import Foundation
import Combine

@MainActor
final class LabEngine: ObservableObject {

    @Published private(set) var config: AppConfig?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let loader: ConfigLoader
    private let experimentEngine: ExperimentEngine

    init(
        loader: ConfigLoader = .shared,
        experimentEngine: ExperimentEngine = ExperimentEngine()
    ) {
        self.loader = loader
        self.experimentEngine = experimentEngine
    }

    func load() {
        guard config == nil else {
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            config = try loader.loadAppConfig()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func result(
        for experiment: Experiment
    ) -> ExperimentResult? {

        guard let config else {
            return nil
        }

        return experimentEngine.makeResult(
            for: experiment,
            results: config.results
        )
    }
}
