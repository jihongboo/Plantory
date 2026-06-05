//
//  PlantRecordsView.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/5.
//

import SwiftUI

struct PlantRecordsView: View {
    let records: [PlantRecord]
    
    var body: some View {
        PixelRoundedRectangleCard(title: "Care Records", systemImage: "list.clipboard.fill") {
            if records.isEmpty {
                PixelContentUnavailableView(
                    "No Records Yet",
                    systemImage: "clock.arrow.circlepath",
                    description: "Watering, fertilizing, pest control, and photo records will appear here.") {
                        Button("Add Record", systemImage: "plus") {
                            
                        }
                        .buttonStyle(.pixelRoundedRectangle)
                    }
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(records.enumerated()), id: \.element.id) { index, record in
                        PlantRecordCard(record: record)
                        
                        if index < records.count - 1 {
                            PixelDashedDivider()
                        }
                    }
                }
            }
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
