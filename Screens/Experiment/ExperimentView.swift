import SwiftUI

struct ExperimentView: View {

    @EnvironmentObject private var labEngine: LabEngine

    let experiment: Experiment

    @State private var result: ExperimentResult?
    @State private var isRunning = false

    var body: some View {
        VStack(spacing: 0) {

            ScrollView {
                VStack(spacing: 24) {

                    Text(experiment.icon)
                        .font(.system(size: 72))

                    Text(experiment.title)
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    Text(experiment.subtitle)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    if let result {
                        ResultView(result: result)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.top, 24)
                .padding(.bottom, 20)
            }

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
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isRunning)
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
