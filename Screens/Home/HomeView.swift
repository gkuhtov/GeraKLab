import SwiftUI

struct HomeView: View {

    @EnvironmentObject private var labEngine: LabEngine

    var body: some View {
        Group {
            if labEngine.isLoading {
                ProgressView("Загрузка лаборатории...")
            } else if let error = labEngine.errorMessage {
                VStack(spacing: 16) {
                    Text("ОШИБКА ЛАБОРАТОРИИ")
                        .font(.headline)

                    Text(error)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else if let config = labEngine.config {
                content(config)
            } else {
                ProgressView("Инициализация...")
            }
        }
        .task {
            labEngine.load()
        }
    }

    private func content(_ config: AppConfig) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    VStack(alignment: .leading, spacing: 6) {
                        Text(config.home.title)
                            .font(.largeTitle.bold())

                        Text(config.home.subtitle)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(config.home.status.title)
                            .font(.caption.bold())

                        Text(config.home.status.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: config.appearance.glass.cornerRadius
                        )
                    )

                    Text("ДОСТУПНЫЕ ИССЛЕДОВАНИЯ")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)

                    ForEach(
                        config.experiments.filter(\.enabled)
                    ) { experiment in

                        NavigationLink {
                            ExperimentView(
                                experiment: experiment
                            )
                        } label: {
                            HStack(spacing: 14) {
                                Text(experiment.icon)
                                    .font(.largeTitle)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(experiment.title)
                                        .font(.headline)

                                    Text(experiment.subtitle)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.ultraThinMaterial)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: config.appearance.glass.cornerRadius
                                )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
