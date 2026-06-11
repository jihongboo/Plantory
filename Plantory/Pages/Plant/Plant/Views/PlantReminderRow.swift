//
//  PixelReminderRow.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/5.
//

import SwiftUI
import NavigatorUI

struct PlantReminderRow: View {
    let plant: Plant
    
    var body: some View {
        NavigationLink(to: PlantoryDestination.plantNotifications(PlantRoute(plant: plant))) {
            PixelRoundedRectangleCard(fill: Color(.pixelPaper)) {
                HStack(spacing: 12) {
                    Image(systemName: "bell.badge.fill")
                        .font(.title2.weight(.black))
                        .foregroundStyle(Color(.pixelSun))
                        .frame(width: 42, height: 42)
                        .background(Color(.pixelCream), in: .rect(cornerRadius: 4))
                        .overlay {
                            Rectangle()
                                .stroke(Color(.pixelPaperShadow), lineWidth: 2)
                        }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Care Reminders")
                            .font(.pixel(.title2))
                            .foregroundStyle(Color(.pixelInk))
                        
                        Text(summary)
                            .font(.pixel(.subheadline))
                            .foregroundStyle(Color(.pixelInk).opacity(0.68))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer(minLength: 8)
                    
                    Image(systemName: "chevron.right")
                        .font(.headline.weight(.black))
                        .foregroundStyle(Color(.pixelInk).opacity(0.64))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PlantReminderRow(plant: .monstera)
        .padding()
}

private extension PlantReminderRow {
    var summary: String {
        let enabledCount = plant.notificationSettings?.count(where: \.isEnabled) ?? 0
        let totalCount = plant.notificationSettings?.count ?? PlantNotificationKind.allCases.count
        
        if enabledCount == 0 {
            return String(localized: "Set watering, fertilizing, and routine reminders.")
        }
        
        return String(localized: "\(enabledCount) of \(totalCount) reminders enabled")
    }
}
