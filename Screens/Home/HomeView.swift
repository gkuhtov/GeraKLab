import SwiftUI

struct HomeView: View {

    @EnvironmentObject private var labEngine: LabEngine

    var body: some View {
        Group {
            if labEngine.isLoading {
                loadingView
            } else if let error = labEngine.errorMessage {
                errorView(error)
            } else if let config = labEngine.config {
                content(config)
            } else {
                loadingView
            }
        }
        .task {
            labEngine.load()
        }
    }

    private var loadingView: some View {
        ZStack {
            Color(hex: "#08080C")
                .ignoresSafeArea()

            VStack(spacing: 12) {
                ProgressView()
                    .tint(Color(hex: "#20E0D0"))

                Text("ЗАГРУЗКА ЛАБОРАТОРИИ")
                    .font(.system(
                        size: 11,
                        weight: .semibold,
                        design: .rounded
                    ))
                    .tracking(1)
                    .foregroundStyle(Color(hex: "#A7A7B3"))
            }
        }
    }

    private func errorView(_ error: String) -> some View {
        ZStack {
            Color(hex: "#08080C")
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 30))
                    .foregroundStyle(Color(hex: "#FF4FA3"))

                Text("ОШИБКА ЛАБОРАТОРИИ")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(error)
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "#A7A7B3"))
                    .multilineTextAlignment(.center)
            }
            .padding(24)
        }
    }

    private func content(_ config: AppConfig) -> some View {
        let theme = LabTheme(config.appearance)

        return NavigationStack {
            ZStack {
                theme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        header(config, theme: theme)

                        statusCard(config, theme: theme)

                        experimentsSection(
                            config,
                            theme: theme
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(theme.accent)
    }

    private func header(
        _ config: AppConfig,
        theme: LabTheme
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {

            Text(config.home.title)
                .font(.system(
                    size: 30,
                    weight: .bold,
                    design: .rounded
                ))
                .foregroundStyle(theme.text)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(config.home.subtitle)
                .font(.system(
                    size: 14,
                    weight: .regular,
                    design: .rounded
                ))
                .foregroundStyle(theme.secondaryText)
                .lineLimit(1)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    private func statusCard(
        _ config: AppConfig,
        theme: LabTheme
    ) -> some View {
        HStack(spacing: 12) {

            ZStack {
                Circle()
                    .fill(theme.secondaryAccent.opacity(0.12))
                    .frame(width: 38, height: 38)

                Circle()
                    .fill(theme.secondaryAccent)
                    .frame(width: 7, height: 7)
            }

            VStack(alignment: .leading, spacing: 2) {

                Text(config.home.status.title)
                    .font(.system(
                        size: 11,
                        weight: .bold,
                        design: .rounded
                    ))
                    .tracking(0.5)
                    .foregroundStyle(theme.secondaryAccent)

                Text(config.home.status.description)
                    .font(.system(
                        size: 13,
                        weight: .regular,
                        design: .rounded
                    ))
                    .foregroundStyle(theme.secondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity)
        .frame(height: 64)
        .background(
            RoundedRectangle(
                cornerRadius: theme.cornerRadius,
                style: .continuous
            )
            .fill(theme.surface.opacity(theme.glassOpacity))
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: theme.cornerRadius,
                style: .continuous
            )
            .stroke(
                theme.secondaryAccent.opacity(0.12),
                lineWidth: 1
            )
        )
    }

    private func experimentsSection(
        _ config: AppConfig,
        theme: LabTheme
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(
                config.home.sections.first(
                    where: { $0.id == "experiments" }
                )?.title
                ?? "ДОСТУПНЫЕ ИССЛЕДОВАНИЯ"
            )
            .font(.system(
                size: 11,
                weight: .bold,
                design: .rounded
            ))
            .tracking(0.8)
            .foregroundStyle(theme.secondaryText)

            VStack(spacing: 8) {
                ForEach(
                    config.experiments.filter(\.enabled)
                ) { experiment in

                    NavigationLink {
                        ExperimentView(
                            experiment: experiment
                        )
                    } label: {
                        experimentCard(
                            experiment,
                            theme: theme
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func experimentCard(
        _ experiment: Experiment,
        theme: LabTheme
    ) -> some View {
        HStack(spacing: 12) {

            ZStack {
                RoundedRectangle(
                    cornerRadius: 12,
                    style: .continuous
                )
                .fill(theme.accent.opacity(0.10))
                .frame(width: 42, height: 42)

                Text(experiment.icon)
                    .font(.system(size: 22))
            }

            VStack(alignment: .leading, spacing: 2) {

                Text(experiment.title)
                    .font(.system(
                        size: 15,
                        weight: .semibold,
                        design: .rounded
                    ))
                    .foregroundStyle(theme.text)
                    .lineLimit(1)

                Text(experiment.subtitle)
                    .font(.system(
                        size: 12,
                        weight: .regular,
                        design: .rounded
                    ))
                    .foregroundStyle(theme.secondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            Image(systemName: "chevron.right")
                .font(.system(
                    size: 11,
                    weight: .bold
                ))
                .foregroundStyle(
                    theme.accent.opacity(0.8)
                )
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .frame(height: 66)
        .background(
            RoundedRectangle(
                cornerRadius: theme.cornerRadius,
                style: .continuous
            )
            .fill(theme.surface.opacity(theme.glassOpacity))
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: theme.cornerRadius,
                style: .continuous
            )
            .stroke(
                theme.accent.opacity(0.10),
                lineWidth: 1
            )
        )
    }
}
