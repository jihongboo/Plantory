//
//  PlantRecordsView.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/5.
//

import SwiftData
import SwiftUI

struct PlantRecordsView: View {
    @Environment(\.modelContext) private var modelContext
    
    let records: [PlantRecord]
    
    @State private var recordPendingDeletion: PlantRecord?
    
    var body: some View {
        PixelRoundedRectangleCard(title: "Care Records", systemImage: "list.clipboard.fill") {
            if records.isEmpty {
                PixelContentUnavailableView(error: AppError.empty, style: .plain)
            } else {
                VStack(spacing: 0) {
                    ForEach(records) { record in
                        PlantRecordView(record: record)
                            .contextMenu {
                                Button(role: .destructive) {
                                    recordPendingDeletion = record
                                } label: {
                                    Label("Delete Record", systemImage: "trash")
                                }
                            }
                        
                        if record != records.last {
                            PixelDashedDivider()
                        }
                    }
                }
                .animation(.smooth, value: records)
            }
        }
        .confirmationDialog(
            "Delete this record?",
            isPresented: deletionBinding,
            presenting: recordPendingDeletion
        ) { record in
            Button("Delete Record", role: .destructive) {
                deleteRecord(record)
            }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text("This will remove the care record and any attached photo.")
        }
    }
}

#Preview {
    PlantRecordsView(records: PlantRecord.monstera)
        .padding()
}

#Preview("Empty") {
    PlantRecordsView(records: [])
        .padding()
}

private extension PlantRecordsView {
    var deletionBinding: Binding<Bool> {
        Binding(
            get: { recordPendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    recordPendingDeletion = nil
                }
            }
        )
    }
    
    func deleteRecord(_ record: PlantRecord) {
        let plant = record.plant
        let photoID = record.photoID
        let shouldSyncNotifications = record.actionType != nil
        recordPendingDeletion = nil
        modelContext.delete(record)
        try? modelContext.save()
        
        if let photoID {
            Task {
                await PlantRecordPhotoStore.shared.deletePhoto(photoID: photoID)
            }
        }
        
        if shouldSyncNotifications, let plant {
            Task {
                _ = await PlantNotificationScheduler.shared.syncNotifications(for: plant)
            }
        }
    }
}
