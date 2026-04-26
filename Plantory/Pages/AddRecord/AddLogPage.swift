import SwiftUI
import SwiftData

struct AddLogPage: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let plant: Plant
    
    @State private var createdAt: Date = .now
    @State private var note = ""
    @State private var recordImage: PlatformImage?
    @State private var isAIDiagnosisEnabled = false
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

                Section("AI Diagnosis") {
                    Toggle("Enable AI Diagnosis", isOn: $isAIDiagnosisEnabled)

                    if isAIDiagnosisEnabled {
                        diagnosisContent
                    }
                }
                
                Section("Log Detail") {
                    DatePicker("Time", selection: $createdAt)
                        .font(.headline)
                    
                    
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes(Optional)")
                            .font(.headline)
                        
                        TextField("Write something about this plant", text: $note, axis: .vertical)
                            .lineLimit(4...8)
                    }
                }
            }
            .navigationTitle("Add Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(primaryActionTitle) {
                        handlePrimaryAction()
                    }
                    .bold()
                    .disabled(!canPerformPrimaryAction)
                }
            }
            .onChange(of: isAIDiagnosisEnabled) { _, isEnabled in
                handleAIDiagnosisPreferenceChange(isEnabled)
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

    var canPerformPrimaryAction: Bool {
        guard canSave else { return false }
        guard isAIDiagnosisEnabled else { return true }

        if case .analyzing = diagnosisState {
            return false
        }
        return true
    }

    var primaryActionTitle: LocalizedStringKey {
        guard isAIDiagnosisEnabled else { return "Save" }

        switch diagnosisState {
        case .analyzing:
            return "Diagnosing..."
        case .complete:
            return "Save"
        case .idle, .failed:
            return "Diagnose"
        }
    }
    
    var compressedPhotoData: Data? {
        guard let recordImage else { return nil }
        return ImageCompression.compressedPNGData(from: recordImage)
    }
    
    func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    @ViewBuilder
    var diagnosisContent: some View {
        switch diagnosisState {
        case .idle:
            if recordImage == nil {
                Text("Import a photo first, then tap Diagnose.")
                    .foregroundStyle(.secondary)
            } else {
                Text("Tap Diagnose to run AI diagnosis for this log.")
                    .foregroundStyle(.secondary)
            }
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

    func handlePrimaryAction() {
        guard canSave else { return }

        guard isAIDiagnosisEnabled else {
            saveLog()
            return
        }

        switch diagnosisState {
        case .complete:
            saveLog()
        case .analyzing:
            return
        case .idle, .failed:
            retryDiagnosis()
        }
    }

    func handleAIDiagnosisPreferenceChange(_ isEnabled: Bool) {
        guard !isEnabled else { return }

        latestDiagnosisRequestID = UUID()
        diagnosisState = .idle
    }

    func handleImageChange(_ image: PlatformImage?) {
        latestDiagnosisRequestID = UUID()

        guard image != nil else {
            diagnosisState = .idle
            return
        }

        diagnosisState = .idle
    }

    func retryDiagnosis() {
        guard isAIDiagnosisEnabled else { return }

        Task {
            await diagnoseCurrentImage()
        }
    }

    @MainActor
    func diagnoseCurrentImage() async {
        guard isAIDiagnosisEnabled else {
            diagnosisState = .idle
            return
        }

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
        guard let photoData else { return }

        let diagnosisReport: PlantDiagnosisReport? = {
            guard case .complete(let report) = diagnosisState else { return nil }
            return report
        }()
        let diagnosisMetadata = diagnosisReport.map { DiagnosisMetadata(result: $0.diagnosisResult) }

        let record = PlantRecord(
            createdAt: createdAt,
            note: trimmedNote,
            photoData: photoData,
            diagnosis: diagnosisMetadata,
            plant: plant
        )

        if let diagnosisReport {
            plant.activeIssues = diagnosedIssues(from: diagnosisReport)
        }
        
        modelContext.insert(record)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            assertionFailure("Failed to save log: \(error.localizedDescription)")
        }
    }

    func diagnosedIssues(from report: PlantDiagnosisReport) -> [PlantIssue] {
        if report.healthStatus == .healthy {
            return []
        }

        if let primaryIssue = report.primaryIssue {
            return [primaryIssue]
        }

        let fallbackSeverity: IssueSeverity = switch report.healthStatus {
        case .healthy:
            .mild
        case .warning:
            .moderate
        case .critical:
            .severe
        }

        return [
            PlantIssue(
                type: .other,
                severity: fallbackSeverity,
                note: report.summary
            )
        ]
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
