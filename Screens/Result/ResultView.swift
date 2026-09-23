import SwiftUI

struct ResultView: View {

    let result: ExperimentResult

    var body: some View {
        VStack(spacing: 10) {

            Text(result.title)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text(result.value)
                .font(.system(size: 48, weight: .bold))
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(result.description)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 24)
        )
    }
}
