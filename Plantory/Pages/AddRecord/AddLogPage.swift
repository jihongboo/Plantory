import SwiftUI
import SwiftData

struct AddLogPage: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let plant: Plant
    
    @State private var createdAt: Date = .now
    @State private var note = ""
    @State private var recordImage: PlatformImage?
    @State private var diagnosisState: DiagnosisState = .idle
    @State private var latestDiagnosisRequestID = UUID()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    RecordPhotoButton(image: diagnosisImageBinding)
                        .aspectRatio(1.8, contentMode: .fit)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }

                if recordImage != nil || !diagnosisState.isIdle {
                    Section("AI Diagnosis") {
                        diagnosisContent
                    }
                }
                
                Section("Log Detail") {
                    DatePicker("Time", selection: $createdAt)
                        .font(.headline)
                    
                    
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        
                        TextField("Write something about this plant", text: $note, axis: .vertical)
                            .lineLimit(4...8)
                    }
                }
            }
            .navigationTitle("Add Log")
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveLog()
                    }
                    .bold()
                    .disabled(!canSave)
                }
            }
        }
    }
}

private extension AddLogPage {
    var diagnosisImageBinding: Binding<PlatformImage?> {
        Binding(
            get: { recordImage },
            set: { newValue in
                recordImage = newValue
                handleImageChange(newValue)
            }
        )
    }

    var canSave: Bool {
        compressedPhotoData != nil
    }
    
    var compressedPhotoData: Data? {
        guard let recordImage else { return nil }
        return ImageCompression.compressedJPEGData(from: recordImage)
    }
    
    func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    @ViewBuilder
    var diagnosisContent: some View {
        switch diagnosisState {
        case .idle:
            Text("Import a photo to run AI diagnosis automatically.")
                .foregroundStyle(.secondary)
        case .analyzing:
            HStack(spacing: 12) {
                ProgressView()
                Text("Analyzing the photo and preparing diagnosis details for this record.")
                    .foregroundStyle(.secondary)
            }
        case .failed(let message):
            VStack(alignment: .leading, spacing: 8) {
                Label(message, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)

                Button("Retry Diagnosis", action: retryDiagnosis)
            }
        case .complete(let report):
            VStack(alignment: .leading, spacing: 10) {
                Text(report.title)
                    .font(.headline)

                Text(report.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let firstAction = report.carePlan.first {
                    Label("Next step: \(firstAction.title)", systemImage: "checkmark.circle")
                        .font(.subheadline)
                }
            }
        }
    }

    func handleImageChange(_ image: PlatformImage?) {
        guard image != nil else {
            diagnosisState = .idle
            return
        }

        Task {
            await diagnoseCurrentImage()
        }
    }

    func retryDiagnosis() {
        Task {
            await diagnoseCurrentImage()
        }
    }

    @MainActor
    func diagnoseCurrentImage() async {
        guard let recordImage else {
            diagnosisState = .idle
            return
        }

        let requestID = UUID()
        latestDiagnosisRequestID = requestID
        diagnosisState = .analyzing

        do {
            let report = try await DoubaoPlantDiagnosisService.analyze(
                plant: plant,
                image: recordImage
            )
            guard latestDiagnosisRequestID == requestID else { return }
            diagnosisState = .complete(report)
        } catch {
            guard latestDiagnosisRequestID == requestID else { return }
            diagnosisState = .failed(error.localizedDescription)
        }
    }
    
    func saveLog() {
        let trimmedNote = trimmed(note)
        let photoData = compressedPhotoData
        let diagnosisMetadata: DiagnosisMetadata? = {
            guard case .complete(let report) = diagnosisState else { return nil }
            return DiagnosisMetadata(result: report.diagnosisResult)
        }()
        guard let photoData else { return }

        let record = PlantRecord(
            createdAt: createdAt,
            note: trimmedNote,
            photoData: photoData,
            diagnosis: diagnosisMetadata,
            plant: plant
        )

        if case .complete(let report) = diagnosisState,
           let primaryIssue = report.primaryIssue {
            plant.activeIssues = [primaryIssue]
        }
        
        modelContext.insert(record)
        dismiss()
    }
}

private extension AddLogPage {
    enum DiagnosisState {
        case idle
        case analyzing
        case failed(String)
        case complete(PlantDiagnosisReport)

        var isIdle: Bool {
            if case .idle = self {
                return true
            }
            return false
        }
    }
}

#Preview {
    AddLogPage(plant: PreviewData.healthyPlant)
        .modelContainer(.preview)
}
