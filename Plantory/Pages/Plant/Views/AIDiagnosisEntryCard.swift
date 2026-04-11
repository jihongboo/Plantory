import SwiftUI
import SwiftData

struct AIDiagnosisEntryCard: View {
    @Environment(\.modelContext) private var modelContext

    let plant: Plant

    @State private var isPresentingCamera = false
    @State private var isPresentingPhotoLibrary = false
    @State private var pickedImage: PlatformImage?
    @State private var lastSelectedImage: PlatformImage?
    @State private var diagnosisState: DiagnosisState = .idle
    @State private var latestDiagnosisRequestID = UUID()

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.15, green: 0.39, blue: 0.23),
                            Color(red: 0.36, green: 0.67, blue: 0.42),
                            Color(red: 0.80, green: 0.92, blue: 0.69)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 56, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.18))
                        .padding(20)
                }

            VStack(alignment: .leading, spacing: 14) {
                Label("AI Diagnosis", systemImage: "stethoscope")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)

                Text("Snap a leaf photo or use one from your library to get a quick health read, likely causes, and next-step suggestions.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.92))

                diagnosisDetails

                diagnosisMenu
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 186)
        .glassEffect(in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 18, y: 12)
        .cameraPicker(isPresented: $isPresentingCamera, image: pickedImageBinding)
        .plantPhotoPicker(isPresented: $isPresentingPhotoLibrary, image: pickedImageBinding)
    }

    private var pickedImageBinding: Binding<PlatformImage?> {
        Binding(
            get: { pickedImage },
            set: { newValue in
                pickedImage = newValue
                guard let newValue else { return }
                lastSelectedImage = newValue
                Task {
                    await diagnose(newValue)
                    pickedImage = nil
                }
            }
        )
    }

    @ViewBuilder
    var diagnosisDetails: some View {
        switch diagnosisState {
        case .idle:
            if let latestResult = latestDiagnosisResult {
                diagnosisResultView(
                    title: latestResult.problem,
                    summary: latestResult.rawResponse,
                    nextStep: latestResult.suggestions.first,
                    badgeText: "Latest diagnosis"
                )
            }
        case .analyzing:
            HStack(spacing: 10) {
                ProgressView()
                    .tint(.white)

                Text("Analyzing the imported photo and saving the result to this plant.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.92))
            }
        case .failed(let message):
            Label(message, systemImage: "exclamationmark.triangle.fill")
                .font(.subheadline)
                .foregroundStyle(.white)
        case .complete(let report):
            diagnosisResultView(
                title: report.title,
                summary: report.summary,
                nextStep: report.carePlan.first?.title,
                badgeText: "Just added"
            )
        }
    }

    var diagnosisMenu: some View {
        Menu {
            Button(action: presentCamera) {
                Label("Take Photo", systemImage: "camera.fill")
            }

            Button(action: presentPhotoLibrary) {
                Label("Choose from Library", systemImage: "photo.on.rectangle")
            }

            if case .failed = diagnosisState {
                Button(action: retryDiagnosis) {
                    Label("Retry Last Photo", systemImage: "arrow.clockwise")
                }
            }
        } label: {
            Label(buttonTitle, systemImage: "sparkles.rectangle.stack.fill")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.regularMaterial, in: Capsule())
                .foregroundStyle(.primary)
        }
    }

    func diagnosisResultView(
        title: String,
        summary: String,
        nextStep: String?,
        badgeText: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(badgeText.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.78))

            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            Text(summary)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.92))
                .lineLimit(3)

            if let nextStep, !nextStep.isEmpty {
                Label("Next step: \(nextStep)", systemImage: "checkmark.circle")
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
        }
    }

    var buttonTitle: String {
        switch diagnosisState {
        case .complete:
            "Diagnose Another Photo"
        case .analyzing:
            "Diagnosing..."
        case .failed:
            "Try Again"
        case .idle:
            latestDiagnosisResult == nil ? "Start Diagnosis" : "Update Diagnosis"
        }
    }

    var latestDiagnosisResult: DiagnosisResult? {
        plant.records?
            .sorted { $0.createdAt > $1.createdAt }
            .compactMap { $0.metadata?.diagnosis?.result }
            .first
    }

    func presentCamera() {
        isPresentingCamera = true
    }

    func presentPhotoLibrary() {
        isPresentingPhotoLibrary = true
    }

    func retryDiagnosis() {
        guard let lastSelectedImage else { return }
        Task {
            await diagnose(lastSelectedImage)
        }
    }

    @MainActor
    func diagnose(_ image: PlatformImage) async {
        let requestID = UUID()
        latestDiagnosisRequestID = requestID
        diagnosisState = .analyzing

        do {
            let report = try await DoubaoPlantDiagnosisService.analyze(
                plant: plant,
                image: image
            )
            guard latestDiagnosisRequestID == requestID else { return }
            if persistDiagnosis(report, with: image) {
                diagnosisState = .complete(report)
            }
        } catch {
            guard latestDiagnosisRequestID == requestID else { return }
            diagnosisState = .failed(error.localizedDescription)
        }
    }

    @MainActor
    func persistDiagnosis(_ report: PlantDiagnosisReport, with image: PlatformImage) -> Bool {
        let record = PlantRecord(
            type: .diagnosis,
            note: "AI diagnosis suggests \(report.title.lowercased()).",
            photoData: image.pngDataRepresentation(),
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
            return true
        } catch {
            diagnosisState = .failed(error.localizedDescription)
            return false
        }
    }
}

private extension AIDiagnosisEntryCard {
    enum DiagnosisState {
        case idle
        case analyzing
        case failed(String)
        case complete(PlantDiagnosisReport)
    }
}
