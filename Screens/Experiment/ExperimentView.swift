import SwiftUI

struct ExperimentView: View {

    @EnvironmentObject private var labEngine: LabEngine

    let experiment: Experiment

    @State private var result: ExperimentResult?
    @State private var isRunning = false

    var body: some View {
        VStack(spacing: 24) {

            Spacer()

            Text(experiment.icon)
                .font(.system(size: 72))

            Text(experiment.title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text(experiment.subtitle)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let result {
                ResultView(result: result)
            }

            Spacer()

            Button {
                runExperiment()
            } label: {
                Text(
                    isRunning
                    ? "ИССЛЕДОВАНИЕ..."
                    : "НАЧАТЬ"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isRunning)
        }
        .padding()
        .navigationTitle(experiment.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func runExperiment() {
        isRunning = true

        HapticManager.shared.medium()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            result = labEngine.result(
                for: experiment
            )

            isRunning = false

            HapticManager.shared.success()
        }
    }
}
