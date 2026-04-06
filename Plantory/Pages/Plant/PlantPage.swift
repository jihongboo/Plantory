import SwiftUI
import SwiftData

struct PlantPage: View {
    let plant: Plant
    @State private var isPresentingAddCareRecord = false
    @State private var isPresentingAddLog = false
    @State private var isPresentingDiagnosis = false
    @State private var diagnosisImage: PlatformImage?
    
    private var sortedRecords: [PlantRecord] {
        (plant.records ?? []).sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                PlantPhotoView(photoData: plant.photoData)
                
                CardView {
                    PlantHeaderView(plant: plant)
                }

                AIDiagnosisEntryCard { image in
                    diagnosisImage = image
                    isPresentingDiagnosis = true
                }
                         
                CardView(title: "Status") {
                    PlantStatusView(plant: plant)
                }
                
                if let info = plant.information {
                    CardView(title: "Wiki") {
                        PlantWikiCell(info: info)
                    }
                }
                
                CardView(title: "Care Records") {
                    if sortedRecords.isEmpty {
                        VStack {
                            Label("No Records Yet", systemImage: "clock.arrow.circlepath")
                                .font(.headline)
                            
                            Text("Watering, fertilizing, pest control, and photo records will appear here.")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        ForEach(sortedRecords) { record in
                            PlantRecordCard(record: record)
                            Divider()
                        }
                    }
                }
            }
            .scenePadding()
        }
        .navigationTitle(plant.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Menu {
                    Button {
                        isPresentingAddCareRecord = true
                    } label: {
                        Label("Add Care Record", systemImage: "cross.case.fill")
                    }
                    
                    Button {
                        isPresentingAddLog = true
                    } label: {
                        Label("Add Log", systemImage: "text.badge.plus")
                    }
                } label: {
                    Label("Add", systemImage: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $isPresentingAddCareRecord) {
            AddCareRecordPage(plant: plant)
        }
        .sheet(isPresented: $isPresentingAddLog) {
            AddLogPage(plant: plant)
        }
        .navigationDestination(isPresented: $isPresentingDiagnosis) {
            if let diagnosisImage {
                AIDiagnosisPage(plant: plant, sourceImage: diagnosisImage)
            }
        }
        .onChange(of: isPresentingDiagnosis) {
            if !isPresentingDiagnosis {
                diagnosisImage = nil
            }
        }
        .background(
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
        )
    }
}

#Preview {
    HeroPlantPagePreview()
}

private struct HeroPlantPagePreview: View {
    var body: some View {
        NavigationStack {
            PlantPage(plant: PreviewData.healthyPlant)
        }
        .modelContainer(.preview)
    }
}
