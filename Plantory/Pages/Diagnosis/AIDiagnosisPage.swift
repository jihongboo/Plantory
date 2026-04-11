import SwiftUI
import SwiftData

struct AIDiagnosisPage: View {
    let plant: Plant
    let sourceImage: PlatformImage

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var analysisState: AnalysisState = .analyzing
    @State private var hasPersistedRecord = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                diagnosisHero

                switch analysisState {
                case .analyzing:
                    DiagnosisLoadingCard()
                case .failed:
                    DiagnosisFailedCard {
                        Task {
                            await runDiagnosis()
                        }
                    }
                case .complete(let report):
                    DiagnosisSummaryCard(report: report)
                    DiagnosisSignalCard(signals: report.observedSignals)
                    DiagnosisCausesCard(causes: report.possibleCauses)
                    DiagnosisActionCard(actions: report.carePlan)
                    DiagnosisWatchCard(report: report)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(backgroundGradient)
        .navigationTitle("AI Diagnosis")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard case .analyzing = analysisState else { return }
            await runDiagnosis()
        }
        .toolbar {
            if case .complete = analysisState {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var diagnosisHero: some View {
        ZStack(alignment: .bottomLeading) {
            sourceDiagnosisImage
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .background(.background)

            LinearGradient(
                colors: [.clear, Color.primary.opacity(0.55)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading) {
                Text(plant.displayName)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)

                Text(heroSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
            .padding(20)
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .primary.opacity(0.08), radius: 10)
    }

    private var heroSubtitle: String {
        if let species = plant.information?.species {
            return species
        }
        return "Photo-based issue screening"
    }

    private var sourceDiagnosisImage: Image {
        #if canImport(UIKit)
        Image(uiImage: sourceImage)
        #elseif canImport(AppKit)
        Image(nsImage: sourceImage)
        #endif
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.98, blue: 0.95),
                Color(red: 0.98, green: 0.97, blue: 0.93),
                Color.white
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    @MainActor
    private func runDiagnosis() async {
        analysisState = .analyzing
        do {
            let report = try await DoubaoPlantDiagnosisService.analyze(
                plant: plant,
                image: sourceImage
            )
            analysisState = .complete(report)
            persistDiagnosisIfNeeded(report)
        } catch {
            analysisState = .failed
        }
    }

    @MainActor
    private func persistDiagnosisIfNeeded(_ report: PlantDiagnosisReport) {
        guard !hasPersistedRecord else { return }

        let note = "AI diagnosis suggests \(report.title.lowercased())."
        let record = PlantRecord(
            type: .diagnosis,
            note: note,
            photoData: sourceImage.pngDataRepresentation(),
            metadata: RecordMetadata(
                diagnosis: DiagnosisMetadata(result: report.diagnosisResult)
            ),
            plant: plant
        )

        if let primaryIssue = report.primaryIssue {
            plant.activeIssues = [primaryIssue]
        }

        if plant.records == nil {
            plant.records = []
        }
        plant.records?.insert(record, at: 0)
        modelContext.insert(record)

        do {
            try modelContext.save()
            hasPersistedRecord = true
        } catch {
            analysisState = .failed
        }
    }
}

private extension AIDiagnosisPage {
    enum AnalysisState {
        case analyzing
        case failed
        case complete(PlantDiagnosisReport)
    }
}

private struct DiagnosisLoadingCard: View {
    var body: some View {
        CardView(title: "Analyzing plant photo") {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 14) {
                    ProgressView()
                        .controlSize(.large)

                    Text("The photo is being analyzed by AI to identify likely issues and next care steps.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 10) {
                    DiagnosisSkeletonBar(width: 0.92)
                    DiagnosisSkeletonBar(width: 0.64)
                    DiagnosisSkeletonBar(width: 0.78)
                }
            }
        }
    }
}

private struct DiagnosisFailedCard: View {
    let retry: () -> Void

    var body: some View {
        CardView(title: "Could not prepare diagnosis") {
            VStack(alignment: .leading, spacing: 12) {
                Label("The AI diagnosis could not be completed. Retry to analyze the photo again.", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)

                Button("Retry", action: retry)
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
            }
        }
    }
}

private struct DiagnosisSummaryCard: View {
    let report: PlantDiagnosisReport

    var body: some View {
        CardView(title: report.title) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    DiagnosisBadge(title: "\(report.confidence)%", subtitle: "Confidence", tint: .green)
                    DiagnosisBadge(title: report.urgency.title, subtitle: report.urgency.subtitle, tint: urgencyColor)
                }

                Text(report.summary)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                DiagnosisMetricPill(
                    title: report.speciesName,
                    systemImage: "leaf.circle.fill",
                    tint: .green
                )
                DiagnosisMetricPill(
                    title: report.healthStatus.label,
                    systemImage: report.healthStatus.systemImage,
                    tint: healthColor
                )
            }
        }
    }

    private var urgencyColor: Color {
        switch report.urgency {
        case .low:
            .green
        case .medium:
            .orange
        case .high:
            .red
        }
    }

    private var healthColor: Color {
        switch report.healthStatus {
        case .healthy:
            .green
        case .warning:
            .orange
        case .critical:
            .red
        }
    }
}

private struct DiagnosisSignalCard: View {
    let signals: [DiagnosisSignal]

    var body: some View {
        CardView(title: "What the AI noticed") {
            ForEach(signals) { signal in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: signal.systemImage)
                        .font(.title3)
                        .foregroundStyle(.green)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(signal.title)
                            .font(.subheadline.weight(.semibold))

                        Text(signal.detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

private struct DiagnosisCausesCard: View {
    let causes: [String]

    var body: some View {
        CardView(title: "Possible causes") {
            ForEach(causes, id: \.self) { cause in
                Label(cause, systemImage: "circle.hexagongrid.fill")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct DiagnosisActionCard: View {
    let actions: [DiagnosisAction]

    var body: some View {
        CardView(title: "Recommended next steps") {
            ForEach(actions) { action in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(action.title)
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(action.timing)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.green)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.green.opacity(0.12), in: Capsule())
                    }

                    Text(action.detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .background(Color.white.opacity(0.65), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
    }
}

private struct DiagnosisWatchCard: View {
    let report: PlantDiagnosisReport

    var body: some View {
        CardView(title: "Keep watching") {
            ForEach(report.watchItems, id: \.self) { item in
                Label(item, systemImage: "eye.fill")
                    .foregroundStyle(.secondary)
            }

            Divider()

            Label(report.preventionTip, systemImage: "lightbulb.max.fill")
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}

private struct DiagnosisBadge: View {
    let title: String
    let subtitle: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(tint)

            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct DiagnosisMetricPill: View {
    let title: String
    let systemImage: String
    let tint: Color

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.footnote.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(tint.opacity(0.12), in: Capsule())
            .foregroundStyle(tint)
    }
}

private struct DiagnosisSkeletonBar: View {
    let width: CGFloat

    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.primary.opacity(0.08))
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.green.opacity(0.15),
                                    Color.mint.opacity(0.45),
                                    Color.green.opacity(0.15)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * width)
                }
        }
        .frame(height: 12)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        AIDiagnosisPage(
            plant: PreviewData.healthyPlant,
            sourceImage: PlatformImage(data: PlatformImageData.named("Monstera deliciosa")!)!
        )
    }
    .modelContainer(.preview)
}
