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
        PixelRoundedRectangleCard(fill: .cardBackground, cornerRadius: 18) {
            HStack(spacing: 12) {
                PixelRectangleCard(fill: .pixelCream) {
                    plantImage
                        .frame(width: 72, height: 72)
                        .padding(6)
                }
                .frame(width: 84, height: 84)

                VStack(alignment: .leading, spacing: 6) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(info.displayCommonName)
                            .font(.pixel(.title3))
                            .foregroundStyle(.pixelInk)
                            .lineLimit(1)
                            .minimumScaleFactor(0.76)

                        Text(info.species)
                            .font(.pixel(.callout))
                            .foregroundStyle(Color.pixelInk.opacity(0.58))
                            .italic()
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                    }

                    HStack(spacing: 8) {
                        label(systemName: "sun.max.fill", text: info.lightLevel.capitalized)
                        label(systemName: "drop.fill", text: info.waterLevel.capitalized)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .trailing, spacing: 10) {
                    PixelTag(systemName: difficultyIcon, fill: difficultyColor)
                        .scaleEffect(0.82, anchor: .topTrailing)

                    Image(systemName: "chevron.right")
                        .font(.headline.weight(.black))
                        .foregroundStyle(Color.pixelInk.opacity(0.48))
                }
            }
            .padding(.vertical, 2)
        }
    }
}

#Preview {
    PlantInformationLibraryCard(info: .monstera)
        .padding()
}

private extension PlantInformationLibraryCard {
    var plantImage: some View {
        AsyncImage(url: info.imageURL) { phase in
            if case let .success(image) = phase {
                image
                    .pixelate()
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "leaf.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(18)
            }
        }
        .clipped()
    }

    func label(systemName: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: systemName)
                .font(.caption.weight(.black))
                .foregroundStyle(.pixelLeaf)

            Text(text)
                .font(.pixel(.caption))
                .foregroundStyle(Color.pixelInk.opacity(0.68))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
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
