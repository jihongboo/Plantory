//
//  PlantInformationLibraryBadge.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/5.
//

import SwiftUI

struct PlantInformationLibraryBadge: View {
    let title: LocalizedStringKey
    let value: String
    let systemImage: String

    var body: some View {
        PixelRectangleCard(fill: .pixelLeafDark) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.caption.weight(.black))
                    .foregroundStyle(.pixelCream)

                VStack(alignment: .leading, spacing: 0) {
                    Text(value)
                        .font(.pixel(.headline))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(title)
                        .font(.pixel(.caption))
                        .foregroundStyle(Color.pixelCream.opacity(0.8))
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    PlantInformationLibraryBadge(title: "Title", value: "value", systemImage: "plus")
}
