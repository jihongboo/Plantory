//
//  PlantInformationLibraryCard.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/5.
//

import SwiftUI

struct PlantInformationLibraryCard: View {
    let info: PlantInformation

    var body: some View {
        PixelRoundedRectangleCard {
            VStack(alignment: .leading, spacing: 12) {
                PixelRectangleCard(fill: .pixelCream) {
                    plantImage
                        .frame(height: 128)
                        .frame(maxWidth: .infinity)
                        .padding(8)
                }
                .overlay(alignment: .topTrailing) {
                    PixelTag(systemName: difficultyIcon, fill: difficultyColor)
                        .scaleEffect(0.78, anchor: .topTrailing)
                        .padding(6)
                }
                .frame(height: 144)

                VStack(alignment: .leading, spacing: 0) {
                    Text(info.commonName)
                        .font(.pixel(.title2))
                        .foregroundStyle(.pixelInk)
                        .lineLimit(2)
                        .minimumScaleFactor(0.76)

                    Text(info.species)
                        .font(.pixel(.callout))
                        .foregroundStyle(Color.pixelInk.opacity(0.58))
                        .italic()
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)
                }

                PixelDashedDivider()

                HStack(spacing: 8) {
                    PlantInformationMiniMetric(
                        title: "Light",
                        value: info.lightLevel.capitalized,
                        systemImage: "sun.max.fill"
                    )

                    PlantInformationMiniMetric(
                        title: "Water",
                        value: info.waterLevel.capitalized,
                        systemImage: "drop.fill"
                    )
                }
            }
        }
    }
}

#Preview {
    PlantInformationLibraryCard(info: .monstera)
        .containerRelativeFrame(.horizontal, count: 2, spacing: 16)
        .padding()
}

private extension PlantInformationLibraryCard {
    @ViewBuilder
    var plantImage: some View {
        if let imageData = info.imageData,
           let image = Image(data: imageData) {
            image
                .pixelate()
                .resizable()
                .scaledToFit()
        } else {
            Image("PixelMonsteraHealthy")
                .pixelate()
                .resizable()
                .scaledToFit()
        }
    }

    var difficultyIcon: String {
        switch info.careDifficulty {
        case "easy":
            "checkmark"
        case "hard":
            "exclamationmark"
        default:
            "leaf.fill"
        }
    }

    var difficultyColor: Color {
        switch info.careDifficulty {
        case "easy":
            .pixelLeaf
        case "hard":
            .pixelDanger
        default:
            .pixelSun
        }
    }
}
