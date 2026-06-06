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
                PixelContentUnavailableView(error: AppError.empty, style: .plain)
            } else {
                VStack(spacing: 0) {
                    ForEach(records) { record in
                        PlantRecordCard(record: record)
                        
                        if record != records.last {
                            PixelDashedDivider()
                        }
                    }
                }
                .animation(.smooth, value: records)
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
