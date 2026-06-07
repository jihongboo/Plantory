//
//  PixelPlantHeroCard.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/6/4.
//

import SwiftUI

struct PlantHeroCard: View {
    let plant: Plant

    var body: some View {
        PixelRoundedRectangleCard(fill: .buttonBackground) {
            VStack(spacing: 14) {
                ZStack(alignment: .bottomTrailing) {
                    PixelRectangleCard {
                        plantPhoto
                            .frame(height: 300)
                            .frame(maxWidth: .infinity)
                    }
                }

                HStack(spacing: 10) {
                    PixelMiniStat(
                        title: "Added",
                        value: plant.createdAt.formatted(.dateTime.month(.abbreviated).day()),
                        systemImage: "calendar"
                    )

                    PixelMiniStat(
                        title: "Records",
                        value: "\(plant.records?.count ?? 0)",
                        systemImage: "list.bullet.clipboard"
                    )
                }
            }
            .padding(4)
        }
    }

}

private struct PixelMiniStat: View {
    let title: LocalizedStringKey
    let value: String
    let systemImage: String

    var body: some View {
        PixelRectangleCard {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.title2.weight(.black))
                    .foregroundStyle(Color(.pixelLeaf))
                    .frame(height: 20)
                
                Text(value)
                    .font(.pixel(.title3))
                    .foregroundStyle(Color(.pixelInk))
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)

                Text(title)
                    .font(.pixel(.subheadline))
                    .foregroundStyle(Color(.pixelInk).opacity(0.6))
                    .lineLimit(1)
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    PlantHeroCard(plant: .monstera)
        .padding()
}

private extension PlantHeroCard {
    @ViewBuilder
    var plantPhoto: some View {
        if let photoData = plant.photoData,
           let image = Image(data: photoData) {
            image
                .resizable()
                .scaledToFit()
        } else {
            Image(.Plants.monsteraHealthy)
                .pixelate()
                .resizable()
                .scaledToFit()
        }
    }
}
