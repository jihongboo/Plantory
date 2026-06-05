//
//  PlantInformationMiniMetric.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/5.
//

import SwiftUI

struct PlantInformationMiniMetric: View {
    let title: LocalizedStringKey
    let value: String
    let systemImage: String

    var body: some View {
        PixelRectangleCard(fill: .cardBackground) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.body.weight(.black))
                    .foregroundStyle(.pixelLeaf)
                    .frame(width: 22, height: 22)

                Text(value)
                    .font(.pixel(.body))
                    .foregroundStyle(.pixelInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)

                Text(title)
                    .font(.pixel(.caption))
                    .foregroundStyle(Color.pixelInk.opacity(0.58))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    PlantInformationMiniMetric(title: "title", value: "value", systemImage: "plus")
}
