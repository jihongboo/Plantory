//
//  PixelReminderRow.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/5.
//

import SwiftUI

struct PixelReminderRow: View {
    let summary: String
    
    var body: some View {
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
}

#Preview {
    PixelReminderRow(summary: "Summary")
        .padding()
}
