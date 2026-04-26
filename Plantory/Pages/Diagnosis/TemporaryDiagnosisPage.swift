import SwiftUI

struct TemporaryDiagnosisPage: View {
    @State private var imageData: Data?
    @State private var diagnosisState: AddPlantDiagnosisState = .idle

    init(imageData: Data? = nil) {
        _imageData = State(initialValue: imageData)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                photoSection

                AddPlantDiagnosisCard(
                    state: diagnosisState,
                    retryAction: {
                        Task { await diagnoseCurrentImage() }
                    }
                )

                if case .complete(let report) = diagnosisState {
                    diagnosisDetails(for: report)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .background(.background)
        .navigationTitle("Diagnose")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: imageData) {
            await diagnoseCurrentImage()
        }
    }
}

private extension TemporaryDiagnosisPage {
    @ViewBuilder
    var photoSection: some View {
        CardView(
            titleKey: "Temporary Diagnosis",
            subtitleKey: "Import a plant photo to check its health without adding it to your collection.",
            systemImage: "stethoscope",
            iconTint: .orange
        ) {
            VStack(alignment: .leading, spacing: 14) {
                if let imageData, let image = Image(data: imageData) {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 260)
                        .clipShape(.rect(cornerRadius: 22, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(.green.opacity(0.08))
                        .frame(height: 220)
                        .overlay {
                            VStack(spacing: 10) {
                                Image(systemName: "camera.on.rectangle")
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundStyle(.green)

                                Text("No diagnosis photo")
                                    .font(.headline)

                                Text("Choose a clear photo of the plant's leaves or stem.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        }
                }

                PlantImageImportMenu(purpose: .diagnosis) { preparedImageData in
                    imageData = preparedImageData
                } label: { isPreparingImage in
                    Label(
                        isPreparingImage ? "Processing..." : "Choose Photo",
                        systemImage: isPreparingImage ? "hourglass" : "camera.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
    }

    @ViewBuilder
    func diagnosisDetails(for report: PlantDiagnosisReport) -> some View {
        CardView(
            titleKey: "Care Plan",
            subtitleKey: report.urgency.title,
            systemImage: "list.bullet.clipboard",
            iconTint: report.healthStatus.themeColor
        ) {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(report.carePlan) { action in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(action.title)
                            .font(.headline)
                        Text(action.detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(action.timing)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.green)
                    }
                }
            }
        }

        CardView(
            titleKey: "Observed Signals",
            systemImage: "eye",
            iconTint: .orange
        ) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(report.observedSignals) { signal in
                    Label {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(signal.title)
                                .font(.subheadline.weight(.semibold))
                            Text(signal.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: signal.systemImage)
                    }
                }
            }
        }
    }

    func diagnoseCurrentImage() async {
        guard let imageData, let image = PlatformImage(data: imageData) else {
            diagnosisState = .idle
            return
        }

        diagnosisState = .analyzing

        if AppEnvironment.isPreview {
            diagnosisState = .complete(AddPlantCardPreviewSupport.diagnosisReport)
            return
        }

        do {
            let report = try await DoubaoPlantDiagnosisService.analyze(image: image)
            diagnosisState = .complete(report)
        } catch {
            diagnosisState = .failed(error.localizedDescription)
        }
    }
}

#Preview {
    NavigationStack {
        TemporaryDiagnosisPage()
    }
}
