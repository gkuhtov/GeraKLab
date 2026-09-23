import Foundation

final class ExperimentEngine {

    private let random: RandomEngine

    init(random: RandomEngine = .shared) {
        self.random = random
    }

    func makeResult(
        for experiment: Experiment,
        results: [String: [ExperimentResultConfig]]
    ) -> ExperimentResult {

        if let configuredResults = results[experiment.id],
           let result = random.randomElement(from: configuredResults) {

            return ExperimentResult(
                title: result.title,
                value: result.value,
                description: result.description
            )
        }

        return fallbackResult(for: experiment)
    }

    private func fallbackResult(
        for experiment: Experiment
    ) -> ExperimentResult {

        ExperimentResult(
            title: "ИССЛЕДОВАНИЕ ЗАВЕРШЕНО",
            value: "\(random.randomPercentage())%",
            description: "Лаборатория не смогла найти более убедительное объяснение."
        )
    }
}
